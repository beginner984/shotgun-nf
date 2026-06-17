process HUMANN_TABLES {

    tag "humann_tables"

    publishDir "${params.outdir}/humann_tables", mode: 'copy'

    input:
    path genefamilies_tables
    path pathabundance_tables
    path pathcoverage_tables

    output:
    path "humann_genefamilies_joined.tsv", emit: genefamilies_joined
    path "humann_genefamilies_cpm.tsv", emit: genefamilies_cpm
    path "humann_pathabundance_joined.tsv", emit: pathabundance_joined
    path "humann_pathabundance_cpm.tsv", emit: pathabundance_cpm
    path "humann_pathcoverage_joined.tsv", emit: pathcoverage_joined

    script:
    """
    mkdir -p genefamilies pathabundance pathcoverage

    cp *_genefamilies.tsv genefamilies/ || true
    cp *_pathabundance.tsv pathabundance/ || true
    cp *_pathcoverage.tsv pathcoverage/ || true

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
        humann_join_tables \
            --input genefamilies \
            --file_name genefamilies \
            --output humann_genefamilies_joined.tsv

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
        humann_renorm_table \
            --input humann_genefamilies_joined.tsv \
            --output humann_genefamilies_cpm.tsv \
            --units cpm

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
        humann_join_tables \
            --input pathabundance \
            --file_name pathabundance \
            --output humann_pathabundance_joined.tsv

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
        humann_renorm_table \
            --input humann_pathabundance_joined.tsv \
            --output humann_pathabundance_cpm.tsv \
            --units cpm

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
        humann_join_tables \
            --input pathcoverage \
            --file_name pathcoverage \
            --output humann_pathcoverage_joined.tsv
    """
}
