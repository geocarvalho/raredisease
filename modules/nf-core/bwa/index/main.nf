process BWA_INDEX {
    tag "$fasta"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-fe8faa35dbf6dc65a0f7f5d4ea12e31a79f73e40:a34558545ae1413d94bde4578787ebef08027945-0' :
        'biocontainers/mulled-v2-fe8faa35dbf6dc65a0f7f5d4ea12e31a79f73e40:a34558545ae1413d94bde4578787ebef08027945-0' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path(bwa) , emit: index
    path "versions.yml"        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${fasta.baseName}"
    def args   = task.ext.args ?: ''
    """
    mkdir bwa
    bwa \\
        index \\
        $args \\
        -p bwa/${prefix} \\
        $fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$(echo \$(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${fasta.baseName}"
    """
    mkdir bwa

    touch bwa/${prefix}.amb
    touch bwa/${prefix}.ann
    touch bwa/${prefix}.bwt
    touch bwa/${prefix}.pac
    touch bwa/${prefix}.sa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$(echo \$(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*\$//')
    END_VERSIONS
    """
}
