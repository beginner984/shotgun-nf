process KRAKEN2 {

    tag "$sample_id"

    publishDir "${params.outdir}/kraken2", mode: 'copy'

    conda "${projectDir}/envs/kraken2.yml"

    input:
    tuple val(sample_id), path(reads)
    path kraken2_db

    output:
    tuple val(sample_id), path("${sample_id}.kraken2.report.txt"), emit: report
    tuple val(sample_id), path("${sample_id}.kraken2.output.txt"), emit: output

    script:
    def r1 = reads[0]
    def r2 = reads[1]

    """
    kraken2 \
        --db ${kraken2_db} \
        --paired ${r1} ${r2} \
        --threads ${task.cpus} \
        --report ${sample_id}.kraken2.report.txt \
        --output ${sample_id}.kraken2.output.txt
    """
}
