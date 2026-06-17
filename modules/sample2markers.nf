process SAMPLE2MARKERS {

    tag "$sample_id"

    publishDir "${params.outdir}/strainphlan/markers", mode: 'copy'

    conda "${projectDir}/envs/strainphlan.yml"

    input:
    tuple val(sample_id), path(sam_bz2), path(profile_txt)

    output:
    tuple val(sample_id), path("${sample_id}.json.bz2")

    script:
    """
    sample2markers.py \
      -i ${sam_bz2} \
      -o . \
      -d ${params.strainphlan_pkl}
    """
}
