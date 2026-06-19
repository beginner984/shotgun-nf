process MULTIQC {

    tag "multiqc"

    publishDir "${params.outdir}/multiqc", mode: 'copy'

    conda "${projectDir}/envs/report.yml"

    input:
    val results_dir
    path trigger

    output:
    path "multiqc_report.html"

    script:
    """
    multiqc . -o .
    """
}
