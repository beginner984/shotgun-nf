process PROKKA {

    tag "$sample_id"

    publishDir "${params.outdir}/prokka", mode: 'copy'

    conda "${projectDir}/envs/prokka.yml"

    input:
    tuple val(sample_id), path(bin_dir)

    output:
    tuple val(sample_id), path("${sample_id}_prokka")

    script:
    """
    mkdir ${sample_id}_prokka

    for bin in ${bin_dir}/*.fa; do
        bin_name=\$(basename \$bin .fa)

        prokka \
            --outdir ${sample_id}_prokka/\${bin_name} \
            --prefix \${bin_name} \
            --cpus ${task.cpus} \
            \$bin
    done
    """
}
