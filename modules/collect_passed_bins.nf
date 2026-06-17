process COLLECT_PASSED_BINS {

    tag "$sample_id"

    publishDir "${params.outdir}/passed_bins", mode: 'copy'

    input:
    tuple val(sample_id), path(passed_tsv), path(bin_dir)

    output:
    tuple val(sample_id), path("${sample_id}_passed_bins")

    script:
    """
    mkdir ${sample_id}_passed_bins

    awk 'BEGIN{FS="\\t"} NR>1 {print \$1}' ${passed_tsv} | while read bin_name; do
        cp ${bin_dir}/\${bin_name}.fa ${sample_id}_passed_bins/
    done
    """
}
