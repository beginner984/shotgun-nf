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
    strainphlan \
      -s *.json.bz2 \
      -d ${params.strainphlan_pkl} \
      -o . \
      --print_clades_only
    """
}
