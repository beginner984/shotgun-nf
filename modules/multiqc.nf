process MULTIQC {

    tag "multiqc"

    publishDir "${params.outdir}/multiqc", mode: 'copy'

    conda "bioconda::multiqc=1.19"

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
