process BRACKEN {

    tag "${sample_id}"

    publishDir "${params.outdir}/bracken", mode: 'copy'

    conda "bioconda::bracken=2.9"

    input:
    tuple val(sample_id), path(kraken_report)

    output:
    path("${sample_id}.bracken.species.txt"), emit: species
    path("${sample_id}.bracken.genus.txt"), emit: genus

    script:
    """
    bracken \
        -d ${params.kraken2_db} \
        -i ${kraken_report} \
        -o ${sample_id}.bracken.species.txt \
        -r 150 \
        -l S \
        -t ${task.cpus}

    bracken \
        -d ${params.kraken2_db} \
        -i ${kraken_report} \
        -o ${sample_id}.bracken.genus.txt \
        -r 150 \
        -l G \
        -t ${task.cpus}
    """
}
