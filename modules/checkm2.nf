process CHECKM2 {

    tag "$sample_id"

    publishDir "${params.outdir}/checkm2", mode: 'copy'

    cpus 4
    memory '64 GB'
    time '12h'

    conda "${projectDir}/envs/checkm2.yml"

    input:
    tuple val(sample_id), path(bin_dir)

    output:
    tuple val(sample_id), path("${sample_id}_checkm2")

    script:
    """
    rm -rf ${sample_id}_checkm2

    checkm2 predict \\
      --threads ${task.cpus} \\
      --input ${bin_dir} \\
      --output-directory ${sample_id}_checkm2 \\
      --database_path ${params.checkm2_db} \\
      -x fa \\
      --lowmem
    """
}
