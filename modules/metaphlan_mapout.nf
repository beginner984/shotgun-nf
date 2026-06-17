process METAPHLAN_MAPOUT {

    tag "$sample_id"

    publishDir "${params.outdir}/strainphlan/metaphlan", mode: 'copy'

    conda "${projectDir}/envs/strainphlan.yml"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}.sam.bz2"), path("${sample_id}_profile.txt")

    script:
    def r1 = reads[0]
    def r2 = reads[1]

    """
    metaphlan \
      --input_type fastq \
      --db_dir ${params.metaphlan_db_dir} \
      -x ${params.metaphlan_index} \
      -1 ${r1} \
      -2 ${r2} \
      --subsampling_paired 10000000 \
      --mapout ${sample_id}.map \
      -s ${sample_id}.sam.bz2 \
      -o ${sample_id}_profile.txt \
      --nproc ${task.cpus}
    """
}
