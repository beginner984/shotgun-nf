process FASTANI {
    tag "all_vs_all_MAGs"

    cpus 8
    memory '32 GB'
    time '12h'

    publishDir "${params.outdir}/fastani", mode: 'copy'

    conda "${projectDir}/envs/gtdbtk_r226.yml"

    input:
    path bin_dirs

    output:
    path "fastani_pairs.tsv", emit: pairs
    path "mags.list", emit: mags_list

    script:
    """
    find -L ${bin_dirs} -type f -name "*.fa" | sort > mags.list

    if [ ! -s mags.list ]; then
        echo "ERROR: mags.list is empty. No MAG fasta files received by FASTANI." >&2
        exit 1
    fi

    echo "Number of MAGs for FastANI:"
    wc -l mags.list

    fastANI \
      --ql mags.list \
      --rl mags.list \
      -t ${task.cpus} \
      -o fastani_pairs.tsv
    """
}
