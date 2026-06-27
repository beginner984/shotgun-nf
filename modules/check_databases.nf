process CHECK_DATABASES {

    publishDir "${params.outdir}/database_manifest", mode: 'copy'

    input:
    val dummy

    output:
    path "database_manifest.tsv"

    script:
    """
    set -euo pipefail

    echo -e "database\tpath\tstatus" > database_manifest.tsv

    check_path () {
      name=\$1
      path=\$2

      if [ "\$path" = "null" ] || [ -z "\$path" ]; then
        echo -e "\$name\tNA\tNOT_SET" >> database_manifest.tsv
      elif [ -e "\$path" ]; then
        echo -e "\$name\t\$path\tFOUND" >> database_manifest.tsv
      else
        echo -e "\$name\t\$path\tMISSING" >> database_manifest.tsv
        echo "ERROR: Required database path for \$name not found: \$path" >&2
        exit 1
      fi
    }

    check_path "checkm2_db" "${params.checkm2_db}"
check_path "card_db" "${params.card_db}"
check_path "kraken2_db" "${params.kraken2_db}"
check_path "metaphlan_db_dir" "${params.metaphlan_db_dir}"

if [ "${params.skip_krona}" != "true" ]; then
    check_path "krona_taxonomy" "${params.krona_taxonomy}"

    if [ ! -f "${params.krona_taxonomy}/taxonomy.tab" ] || [ ! -f "${params.krona_taxonomy}/accession2taxid" ]; then
        echo "ERROR: Krona taxonomy database is incomplete: ${params.krona_taxonomy}" >&2
        echo "Expected files include taxonomy.tab and accession2taxid." >&2
        echo "Create it with Krona updateTaxonomy.sh, or set --skip_krona true." >&2
        exit 1
    fi
fi

if [ "${params.run_humann}" = "true" ]; then
    check_path "humann_nucleotide_db" "${params.humann_nucleotide_db}"
    check_path "humann_protein_db" "${params.humann_protein_db}"
    check_path "humann_sif" "${params.humann_sif}"
fi

if [ "${params.run_strainphlan}" = "true" ]; then
    check_path "strainphlan_pkl" "${params.strainphlan_pkl}"
fi

if [ "${params.run_antismash}" = "true" ]; then
    check_path "antismash_sif" "${params.antismash_sif}"
fi

if [ "${params.run_gtdbtk}" = "true" ]; then
    check_path "gtdbtk_db" "${params.gtdbtk_db}"
fi

    echo "Database validation completed successfully."
    """
}
