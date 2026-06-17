process SELECT_STRAINPHLAN_CLADES {

    tag "select_strainphlan_clades"

    publishDir "${params.outdir}/strainphlan/clades", mode: 'copy'

    input:
    path clade_table

    output:
    path "strainphlan_candidate_clades.tsv"

    script:
    """
    awk -F '\\t' -v min_samples=${params.strainphlan_min_samples} '
    NR==1 { print "clade\\tNumber_of_samples\\tSamples"; next }
    \$2 >= min_samples { print \$1"\\t"\$2"\\t"\$3 }
    ' ${clade_table} > strainphlan_candidate_clades.tsv

    if [ ! -s strainphlan_candidate_clades.tsv ]; then
        echo -e "clade\\tNumber_of_samples\\tSamples" > strainphlan_candidate_clades.tsv
    fi
    """
}
