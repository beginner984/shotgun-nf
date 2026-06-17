process STRAINPHLAN_RUN {

    tag "$clade"

    publishDir "${params.outdir}/strainphlan/final/${clade}", mode: 'copy'

    conda "${projectDir}/envs/strainphlan.yml"

    input:
    tuple val(clade), path(marker_jsons)

    output:
    path "${clade}", emit: result_dir
    path "${clade}_strainphlan_status.tsv", emit: status

    script:
    """
    mkdir -p ${clade}

    set +e
    strainphlan \
      -s *.json.bz2 \
      -d ${params.strainphlan_pkl} \
      -c ${clade} \
      -o ${clade} \
      -n ${task.cpus}

    status=\$?

    if [ \$status -eq 0 ]; then
        echo -e "clade\tstatus\texit_code" > ${clade}_strainphlan_status.tsv
        echo -e "${clade}\tSUCCESS\t0" >> ${clade}_strainphlan_status.tsv
    else
        echo -e "clade\tstatus\texit_code" > ${clade}_strainphlan_status.tsv
        echo -e "${clade}\tFAILED_NO_VALID_PHYLOGENY\t\$status" >> ${clade}_strainphlan_status.tsv
    fi

    exit 0
    """
}
