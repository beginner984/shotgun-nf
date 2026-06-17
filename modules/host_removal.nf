process HOST_REMOVAL {

    tag "${sample_id}"

    publishDir "${params.outdir}/host_removed", mode: 'copy'

    conda "${projectDir}/envs/host_removal.yml"

    input:
    tuple val(sample_id), path(reads)
    path host_index

    output:
    tuple val(sample_id), path("${sample_id}_*.host_removed.fastq.gz"), emit: clean_reads
    path "${sample_id}.host_removal.log", emit: log

    script:
    def r1 = reads[0]
    def r2 = reads[1]

    """
    bowtie2 \
        -x ${host_index} \
        -1 ${r1} \
        -2 ${r2} \
        --very-sensitive \
        --threads ${task.cpus} \
        --un-conc-gz ${sample_id}_%.host_removed.fastq.gz \
        -S /dev/null \
        2> ${sample_id}.host_removal.log
    """
}
