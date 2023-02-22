def exec_java_command(mem) {
    def xmx = "-Xmx${mem.toGiga()-1}G"
    return "java -Djava.aws.headless=true ${xmx} -jar /usr/local/bin/fastaFixer.jar"
}

process FIX_FASTA {
    publishDir "${params.result_dir}/fasta", failOnError: true, mode: 'copy'
    label 'process_low'
    label 'process_high_memory'
    container 'quay.io/protio/fasta-fixer:1.0.0'

    input:
        path filtered_fasta

    output:
        path("*.stderr"), emit: stderr
        path("${filtered_fasta.baseName}.fixed.fasta"), emit: filtered_pin

    script:
    """
    echo "Fixing FASTA (removing duplicates and invalid residues)"
        ${exec_java_command(task.memory)} \
        -f {$filtered_fasta} \
        -r X \
        >${filtered_fasta.baseName}.fixed.fasta \
        2>${filtered_fasta.baseName}.fixed.fasta.stderr

    echo "Done!" # Needed for proper exit
    """

    stub:
    """
    touch "${filtered_fasta.baseName}.fixed.fasta"
    """
}
