process MEGAHIT {

    tag "$sample_id"

    publishDir "${params.outdir}/assembly", mode: 'copy'


    conda "${projectDir}/envs/megahit.yml"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}.contigs.fa")

    script:

    def r1 = reads[0]
    def r2 = reads[1]

    """
    megahit \
        -1 ${r1} \
        -2 ${r2} \
        -t ${task.cpus} \
        -o ${sample_id}

    cp ${sample_id}/final.contigs.fa ${sample_id}.contigs.fa
    """
}
