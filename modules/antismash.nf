process ANTISMASH {

    tag "$sample_id"

    publishDir "${params.outdir}/antismash", mode: 'copy'

    input:
    tuple val(sample_id), path(bin_dir)

    output:
    tuple val(sample_id), path("${sample_id}_antismash")

    beforeScript '''
    source /etc/profile || true
    export PATH=/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH
    '''

    script:
    """
    mkdir -p ${sample_id}_antismash
    mkdir -p local_bins
    shopt -s nullglob

    cp -L ${bin_dir}/*.fa local_bins/

    APPTAINER_BIN=\$(command -v apptainer || command -v singularity || true)
    if [ -z "\$APPTAINER_BIN" ]; then
        echo "ERROR: neither apptainer nor singularity found in PATH" >&2
        echo "PATH=\$PATH" >&2
        hostname >&2
        exit 127
    fi

    for bin in local_bins/*.fa; do
        bin_name=\$(basename \$bin .fa)

        \$APPTAINER_BIN exec \\
            --bind \$PWD:/work \\
            ${params.antismash_sif} \\
            antismash \\
            /work/\$bin \\
            --output-dir /work/${sample_id}_antismash/\${bin_name} \\
            --taxon bacteria \\
            --genefinding-tool prodigal \\
            --cb-general \\
            --cb-knownclusters \\
            --cb-subclusters \\
            --fullhmmer \\
            --cpus 4
    done
    """
}
