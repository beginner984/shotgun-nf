process QUAST {

    tag "${sample_id}"

    publishDir "${params.outdir}/quast", mode: 'copy'

    conda "${projectDir}/envs/quast.yml"

    input:
    tuple val(sample_id), path(contigs)

    output:
    tuple val(sample_id), path("${sample_id}_quast"), emit: report_dir
    path "${sample_id}_quast/report.tsv", emit: report_tsv
    path "${sample_id}_quast/report.html", emit: report_html

    script:
    """
    quast.py \
        ${contigs} \
        -o ${sample_id}_quast \
        -t ${task.cpus}
    """
}
