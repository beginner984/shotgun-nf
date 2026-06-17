process EGGNOG {

    tag "$sample_id"

    publishDir "${params.outdir}/eggnog", mode: 'copy'

    conda "bioconda::eggnog-mapper=2.1.12"

    cpus 8
    memory '32 GB'
    time '12h'

    input:
    tuple val(sample_id), path(bin_dir)

    output:
    tuple val(sample_id), path("${sample_id}_eggnog")

    script:
    """
    mkdir -p ${sample_id}_eggnog

    emapper.py \
        -i ${bin_dir}/*.faa \
        --output ${sample_id} \
        --output_dir ${sample_id}_eggnog \
        --cpu ${task.cpus}
    """
}
