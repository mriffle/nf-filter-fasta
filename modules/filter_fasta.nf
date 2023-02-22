def exec_java_command(mem) {
    def xmx = "-Xmx${mem.toGiga()-1}G"
    return "java -Djava.aws.headless=true ${xmx} -jar /usr/local/bin/filterFASTA.jar"
}

process FILTER_FASTA {
    publishDir "${params.result_dir}/fasta", failOnError: true, mode: 'copy'
    label 'process_low'
    label 'process_high_memory'
    container 'quay.io/protio/filter-fasta:1.3.2'

    input:
        path percolator_xml
        path unfiltered_fasta
        val peptide_cutoff
        val psm_cutoff
        val min_peptides_per_protein

    output:
        path("*.stderr"), emit: stderr
        path("${unfiltered_fasta.baseName}.filtered.fasta"), emit: filtered_pin

    script:
    """
    echo "Filtering FASTA using percolator scores..."
        ${exec_java_command(task.memory)} \
        -p ${peptide_cutoff} \
        -s ${psm_cutoff} \
        -n ${min_peptides_per_protein} \
        -x ${percolator_xml} \
        -f {$unfiltered_fasta} \
        >${unfiltered_fasta.baseName}.filtered.fasta \
        2>${unfiltered_fasta.baseName}.filtered.fasta.stderr

    echo "Done!" # Needed for proper exit
    """

    stub:
    """
    touch "${unfiltered_fasta.baseName}.filtered.fasta"
    """
}