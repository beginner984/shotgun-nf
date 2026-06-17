process METABAT {

    tag "$sample_id"

    publishDir "${params.outdir}/bins", mode: 'copy'

    conda "${projectDir}/envs/metabat.yml"

    input:
    tuple val(sample_id), path(contigs)

    output:
    tuple val(sample_id), path("${sample_id}_bins")

    script:
    """
    mkdir ${sample_id}_bins

    metabat2 \
        -i ${contigs} \
        -o ${sample_id}_bins/bin \
        -t ${task.cpus} \
        --minContig 1500
    """
}
