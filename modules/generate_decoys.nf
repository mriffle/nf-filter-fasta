
process GENERATE_DECOYS {
    publishDir "${params.result_dir}/fasta", failOnError: true, mode: 'copy'
    label 'process_low'
    container 'spctools/tpp:version6.2.0'

    input:
        val decoy_prefix
        path fixed_fasta

    output:
        path("*.stderr"), emit: stderr
        path("*.stdout"), emit: stdout
        path("${fixed_fasta.baseName}.plusdecoys.fasta"), emit: decoys_fasta

    script:
    """
    echo "Generating decoys using TPP..."
        decoyFastaGenerator.pl -d 2 ${fixed_fasta} ${decoy_prefix} ${fixed_fasta.baseName}.plusdecoys.fasta \
        >${fixed_fasta.baseName}.plusdecoys.fasta.stdout \
        2>${fixed_fasta.baseName}.plusdecoys.fasta.stderr

    echo "Done!" # Needed for proper exit
    """

    stub:
    """
    touch "${fixed_fasta.baseName}.plusdecoys.fasta"
    """
}
