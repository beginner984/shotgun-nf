process STRAINPHLAN_CLADES {

    tag "strainphlan_clades"

    publishDir "${params.outdir}/strainphlan/clades", mode: 'copy'

    conda "${projectDir}/envs/strainphlan.yml"

    input:
    path marker_jsons

    output:
    path "print_clades_only.tsv"

    script:
    """
    set +e

    if ls *.json.bz2 >/dev/null 2>&1; then
        strainphlan \\
          -s *.json.bz2 \\
          -d ${params.strainphlan_pkl} \\
          -o . \\
          --print_clades_only
    fi

    if [ ! -s print_clades_only.tsv ]; then
        echo -e "clade\\tn_markers\\tn_samples\\tstatus" > print_clades_only.tsv
        echo -e "NA\\t0\\t0\\tNo eligible clades detected; skipping StrainPhlAn phylogeny" >> print_clades_only.tsv
    fi

    exit 0
    """
}
