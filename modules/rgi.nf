process RGI {

    tag "$sample_id"

    publishDir "${params.outdir}/rgi", mode: 'copy'

    conda "${projectDir}/envs/rgi.yml"

    input:
    tuple val(sample_id), path(bin_dir)
    path card_db_dir

    output:
    tuple val(sample_id), path("${sample_id}_rgi")

    script:
    """
    mkdir ${sample_id}_rgi

    export CARD_DATA_PATH=${card_db_dir}

    for bin in ${bin_dir}/*.fa; do
        bin_name=\$(basename \$bin .fa)

        rgi main \
            --input_sequence \$bin \
            --output_file ${sample_id}_rgi/\${bin_name} \
            --input_type contig \
            --local \
            --num_threads ${task.cpus} \
            --clean
    done
    """
}
