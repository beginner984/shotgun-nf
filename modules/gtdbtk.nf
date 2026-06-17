process GTDBTK {
    tag "$sample_id"

    cpus 8
    memory '120 GB'
    time '24h'
    maxForks 2

    publishDir "${params.outdir}/gtdbtk", mode: 'copy'

    conda "${projectDir}/envs/gtdbtk_r226.yml"

    input:
    tuple val(sample_id), path(bin_dir)

    output:
    tuple val(sample_id), path("${sample_id}_gtdbtk"), emit: results

    script:
    """
    export GTDBTK_DATA_PATH=${params.gtdbtk_db}

    mkdir -p ${sample_id}_gtdbtk
    mkdir -p gtdbtk_tmp

    export TMPDIR=\$PWD/gtdbtk_tmp
    export TEMP=\$PWD/gtdbtk_tmp
    export TMP=\$PWD/gtdbtk_tmp

    gtdbtk identify \
      --genome_dir ${bin_dir} \
      --out_dir ${sample_id}_gtdbtk \
      --extension fa \
      --cpus ${task.cpus}

    gtdbtk align \
      --identify_dir ${sample_id}_gtdbtk \
      --out_dir ${sample_id}_gtdbtk \
      --cpus ${task.cpus}

    gtdbtk classify \
      --genome_dir ${bin_dir} \
      --align_dir ${sample_id}_gtdbtk \
      --out_dir ${sample_id}_gtdbtk \
      --extension fa \
      --cpus ${task.cpus}
    """
}
