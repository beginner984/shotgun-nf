process COVERM {

    tag "${sample_id}"

    publishDir "${params.outdir}/coverm", mode: 'copy'

    conda "${projectDir}/envs/coverm.yml"

    input:
    tuple val(sample_id), path(reads), path(bin_dir)

    output:
    tuple val(sample_id), path("${sample_id}.coverm_mag_abundance.tsv"), emit: abundance

    script:
    def r1 = reads[0]
    def r2 = reads[1]

    """
    mkdir -p coverm_bins

    for f in ${bin_dir}/*.fa; do
        base=\$(basename "\$f" .fa)
        ln -s "\$PWD/\$f" coverm_bins/\${base}.fna
    done

    coverm genome \
        --coupled ${r1} ${r2} \
        --genome-fasta-directory coverm_bins \
        --methods relative_abundance mean covered_fraction \
        --min-read-percent-identity 95 \
        --min-read-aligned-percent 75 \
        --threads ${task.cpus} \
        --output-file ${sample_id}.coverm_mag_abundance.tsv
    """
}
