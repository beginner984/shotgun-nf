process REPORT {
    tag "automated_report"

    errorStrategy 'ignore'

    conda "${projectDir}/envs/report.yml"

    publishDir "${params.report_outdir}", mode: 'copy'

    input:
    val results_dir
    path multiqc_report

    output:
    path "auto_report/*", optional: true, emit: report

    script:
    """
    mkdir -p auto_report

    Rscript --vanilla ${projectDir}/shotgunNFreports/run_report.R \
      --results ${projectDir}/${results_dir} \
      --outdir auto_report || true
    """
}
