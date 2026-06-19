process PROKKA {

    tag "$sample_id"

    publishDir "${params.outdir}/prokka", mode: 'copy'

    cpus 4
    memory '16 GB'
    time '12h'

    conda "${projectDir}/envs/prokka.yml"

    input:
    tuple val(sample_id), path(passed_bins_dir)

    output:
    tuple val(sample_id), path("${sample_id}_prokka")

    script:
    """
    rm -rf ${sample_id}_prokka
    mkdir -p ${sample_id}_prokka

    if ls ${passed_bins_dir}/*.fa >/dev/null 2>&1; then
        for bin in ${passed_bins_dir}/*.fa; do
            bin_name=\$(basename \$bin .fa)

            prokka \\
              --outdir ${sample_id}_prokka/\${bin_name} \\
              --prefix \${bin_name} \\
              --cpus ${task.cpus} \\
              \$bin
        done
    else
        echo "No passed MAG bins available for Prokka annotation for ${sample_id}" > ${sample_id}_prokka/NO_BINS_FOUND.txt
    fi
    """
}
