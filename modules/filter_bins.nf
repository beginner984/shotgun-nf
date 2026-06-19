process FILTER_BINS {

    tag "$sample_id"

    publishDir "${params.outdir}/filtered_bins", mode: 'copy'

    input:
    tuple val(sample_id), path(checkm2_dir)

    output:
    tuple val(sample_id), path("${sample_id}_passed_bins.tsv")

    script:
    """
    if [ -f ${checkm2_dir}/quality_report.tsv ]; then
        awk 'BEGIN{FS=OFS="\\t"}
         NR==1 {print \$0; next}
         \$2 >= ${params.min_completeness} && \$3 < ${params.max_contamination} {print \$0}' \
         ${checkm2_dir}/quality_report.tsv > ${sample_id}_passed_bins.tsv
    else
        echo -e "Name\\tCompleteness\\tContamination" > ${sample_id}_passed_bins.tsv
    fi
    """
}
