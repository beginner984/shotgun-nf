process HUMANN {

    tag "${sample_id}"

    publishDir "${params.outdir}/humann", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "${sample_id}_humann/${sample_id}_genefamilies.tsv", emit: genefamilies
    path "${sample_id}_humann/${sample_id}_pathabundance.tsv", emit: pathabundance
    path "${sample_id}_humann/${sample_id}_pathcoverage.tsv", emit: pathcoverage

    script:
    def r1 = reads[0]
    def r2 = reads[1]

    """
    mkdir -p ${sample_id}_humann

    cat ${r1} ${r2} > ${sample_id}.merged.fastq.gz

    export PATH=/usr/bin:/bin:/usr/local/bin:\$PATH
    APPTAINER_BIN=\$(command -v apptainer || command -v singularity || true)
    if [ -z "\$APPTAINER_BIN" ]; then
        echo "ERROR: apptainer/singularity not found on this compute node"
        hostname
        echo "\$PATH"
        exit 127
    fi

    \$APPTAINER_BIN exec \
        -B \$PWD:\$PWD \
        ${params.apptainer_binds ?: ''} \
        ${params.humann_sif} \
        humann \
            --input ${sample_id}.merged.fastq.gz \
            --output ${sample_id}_humann \
            --output-basename ${sample_id} \
            --nucleotide-database ${params.humann_nucleotide_db} \
            --protein-database ${params.humann_protein_db} \
            --metaphlan-options "--bowtie2db ${params.humann_metaphlan_db_dir} -x ${params.humann_metaphlan_index}" \
            --threads ${task.cpus}
    """
}
