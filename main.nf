nextflow.enable.dsl=2

params.input = params.input ?: "samplesheet.csv"
params.outdir = params.outdir ?: "results"

if (params.help) {
    log.info """
Shotgun-NF

Usage:
  nextflow run . -profile <profile> -c <config> --input samplesheet.csv --outdir results

Required parameters:
  --input               Input samplesheet (sample, fastq_1, fastq_2)
  --outdir              Output directory

Common optional parameters:
  --skip_host_removal   Skip host read removal
  --skip_krona          Skip Krona visualisation
  --run_humann          Enable HUMAnN functional profiling
  --run_antismash       Enable antiSMASH
  --run_gtdbtk          Enable GTDB-Tk classification
  --run_fastani         Enable FastANI
  --run_strainphlan     Enable StrainPhlAn
  --run_eggnog          Enable eggNOG annotation
  --make_report         Generate automated HTML report

Profiles:
  local
  eureka2
  conda
  apptainer
  test

Example:
  nextflow run . -profile local -c my.config --input samplesheet.csv --outdir results --make_report true -resume

Documentation:
  README.md
  DATABASES.md
  docs/getting_started.md
"""
    System.exit(0)
}

// ---------------- INPUT CHANNEL ----------------

Channel
    .fromPath(params.input)
    .splitCsv(header:true)
    .map { row ->
        tuple(
            row.sample,
            [ file(row.fastq_1), file(row.fastq_2) ]
        )
    }
    .set { reads_ch }

// INCLUDE MODULES
include { FASTP } from './modules/fastp.nf'
include { MEGAHIT } from './modules/megahit.nf'
include { METABAT } from './modules/metabat.nf'
include { CHECKM2 } from './modules/checkm2.nf'
include { FILTER_BINS } from './modules/filter_bins.nf'
include { COLLECT_PASSED_BINS } from './modules/collect_passed_bins.nf'
include { PROKKA } from './modules/prokka.nf'
include { EGGNOG } from './modules/eggnog.nf'
include { RGI } from './modules/rgi.nf'
include { ANTISMASH } from './modules/antismash.nf'
include { METAPHLAN_MAPOUT } from './modules/metaphlan_mapout.nf'
include { SAMPLE2MARKERS } from './modules/sample2markers.nf'
include { STRAINPHLAN_CLADES } from './modules/strainphlan_clades.nf'
include { STRAINPHLAN_RUN } from './modules/strainphlan_run.nf'
include { SELECT_STRAINPHLAN_CLADES } from './modules/select_strainphlan_clades.nf'
include { KRAKEN2 } from './modules/kraken2.nf'
include { BRACKEN } from './modules/bracken.nf'
include { KRONA } from './modules/krona.nf'
include { MULTIQC } from './modules/multiqc.nf'
include { PROVENANCE } from './modules/provenance.nf'
include { CHECK_DATABASES } from './modules/check_databases.nf'
include { HUMANN } from './modules/humann.nf'
include { HUMANN_TABLES } from './modules/humann_tables.nf'
include { QUAST } from './modules/quast.nf'
include { COVERM } from './modules/coverm.nf'
include { HOST_REMOVAL } from './modules/host_removal.nf'
include { REPORT } from './modules/report.nf'
include { GTDBTK } from './modules/gtdbtk.nf'
include { FASTANI } from './modules/fastani.nf'
// WORKFLOW
workflow {

    db_check_out = CHECK_DATABASES('start')

    fastp_out = FASTP(reads_ch)

host_removed_reads = fastp_out.cleaned_reads

if( !params.skip_host_removal && params.host_index ) {

    host_index_ch = Channel.value(file(params.host_index))

    host_removal_out = HOST_REMOVAL(
        fastp_out.cleaned_reads,
        host_index_ch
    )

    host_removed_reads = host_removal_out.clean_reads
}

    humann_multiqc_ch = Channel.empty()
    humann_tables_genefamilies_ch = Channel.empty()
    humann_tables_pathabundance_ch = Channel.empty()

    if (params.run_humann) {
        humann_out = HUMANN(host_removed_reads)

        humann_tables_out = HUMANN_TABLES(
            humann_out.genefamilies.collect(),
            humann_out.pathabundance.collect(),
            humann_out.pathcoverage.collect()
        )

        humann_multiqc_ch = humann_out.genefamilies.map { gf -> gf }
        humann_tables_genefamilies_ch = humann_tables_out.genefamilies_cpm
        humann_tables_pathabundance_ch = humann_tables_out.pathabundance_cpm
    }

    if (params.run_kraken2 && !params.kraken2_db) {
        error "Missing required parameter: --kraken2_db. Provide it in a config file or on the command line."
    }

    kraken_db_ch = Channel.value(file(params.kraken2_db))
    kraken_out = KRAKEN2(host_removed_reads, kraken_db_ch)

    bracken_out = BRACKEN(kraken_out.report)

    krona_html_for_multiqc = Channel.empty()

    if( !params.skip_krona ) {
        krona_out = KRONA(kraken_out.output)
        krona_html_for_multiqc = krona_out.html
    }

    megahit_out = MEGAHIT(host_removed_reads)

    quast_out = QUAST(megahit_out)
    
    metabat_out = METABAT(megahit_out)

    checkm2_out = CHECKM2(metabat_out)

    filtered_bins_out = FILTER_BINS(checkm2_out)

    passed_bins_input = filtered_bins_out.join(metabat_out)

    passed_bins_out = COLLECT_PASSED_BINS(passed_bins_input)

    if (params.run_gtdbtk) {
        gtdbtk_out = GTDBTK(passed_bins_out)
    }

    if (params.run_fastani) {
        fastani_input = passed_bins_out.map { sample_id, bin_dir -> bin_dir }.collect()
        fastani_out = FASTANI(fastani_input)
    }

    coverm_input = host_removed_reads.join(passed_bins_out)
        .map { sample_id, reads, bin_dir -> tuple(sample_id, reads, bin_dir) }

    coverm_out = COVERM(coverm_input)
    
    prokka_out = PROKKA(passed_bins_out)

    if (params.run_eggnog) {
        eggnog_out = EGGNOG(passed_bins_out)
    }

    if (!params.card_db) {
        error "Missing required parameter: --card_db. Provide it in a config file or on the command line."
    }

    card_db_ch = Channel.value(file(params.card_db))
    rgi_out = RGI(passed_bins_out, card_db_ch)
    
    if (params.run_antismash) {
        antismash_out = ANTISMASH(passed_bins_out)
    }

    metaphlan_out = METAPHLAN_MAPOUT(host_removed_reads)

    if (params.run_strainphlan) {
        markers_out = SAMPLE2MARKERS(metaphlan_out)

        strainphlan_input = markers_out.map { sample_id, json_bz2 -> json_bz2 }.collect()

        strainphlan_clades_out = STRAINPHLAN_CLADES(strainphlan_input)

        if (params.strainphlan_clade) {
            strainphlan_run_input = strainphlan_input.map { marker_files ->
                tuple(params.strainphlan_clade, marker_files)
            }
        } else {
            candidate_clades_file = SELECT_STRAINPHLAN_CLADES(strainphlan_clades_out)

            candidate_clades = candidate_clades_file
                .splitCsv(header:true, sep:'\t')
                .map { row -> row.clade }

            strainphlan_run_input = candidate_clades
                .cross(strainphlan_input)
                .map { clade, marker_files -> tuple(clade, marker_files) }
        }

        strainphlan_final_out = STRAINPHLAN_RUN(strainphlan_run_input)
    }

    multiqc_trigger = Channel
    .empty()
    .mix(
        fastp_out.html,
        fastp_out.json,
        fastp_out.log,
        kraken_out.report.map { sample_id, report -> report },
        bracken_out.species.map { species -> species },
        krona_html_for_multiqc,
        humann_multiqc_ch,
        humann_tables_genefamilies_ch,
        humann_tables_pathabundance_ch,
        quast_out.report_dir.map { sample_id, qdir -> qdir },
        coverm_out.abundance.map { sample_id, abundance -> abundance }
    )
    .collect()

multiqc_out = MULTIQC(params.outdir, multiqc_trigger)

provenance_out = PROVENANCE(params.outdir)
    if (params.make_report) {
        report_out = REPORT(params.outdir, multiqc_out.report)
    }

}
