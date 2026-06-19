process KRONA {

    tag "${sample_id}"

    publishDir "${params.outdir}/krona", mode: 'copy'

    conda "${projectDir}/envs/krona.yml"

    input:
    tuple val(sample_id), path(kraken_output)

    output:
    path("${sample_id}.krona.html"), emit: html

    script:
    """
    ktImportTaxonomy \
        -tax ${params.krona_taxonomy} \
        -t 3 \
        -m 4 \
        -o ${sample_id}.krona.html \
        ${kraken_output}
    """
}
