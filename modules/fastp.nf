process FASTP {

    tag "$sample_id"

    publishDir "${params.outdir}/fastp", mode: 'copy'

    conda "bioconda::fastp=0.23.4"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_*.fastp.fastq.gz"), emit: cleaned_reads
    path("${sample_id}.fastp.html"), emit: html
    path("${sample_id}.fastp.json"), emit: json
    path("${sample_id}.fastp.log"), emit: log

    script:
    def r1 = reads[0]
    def r2 = reads[1]

    """
    fastp \
        --in1 ${r1} \
        --in2 ${r2} \
        --out1 ${sample_id}_1.fastp.fastq.gz \
        --out2 ${sample_id}_2.fastp.fastq.gz \
        --html ${sample_id}.fastp.html \
        --json ${sample_id}.fastp.json \
        --thread ${task.cpus} \
        --detect_adapter_for_pe \
        --length_required 15 \
        2> ${sample_id}.fastp.log
    """
}
