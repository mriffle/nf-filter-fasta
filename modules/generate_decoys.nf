
process GENERATE_DECOYS {
    publishDir "${params.result_dir}/fasta", failOnError: true, mode: 'copy'
    label 'process_low'
    container 'mriffle/yarp:1.2.0'

    input:
        val decoy_prefix
        path fixed_fasta

    output:
        path("*.stderr"), emit: stderr
        path("*.stdout"), emit: stdout
        path("${fixed_fasta.baseName}.plusdecoys.fasta"), emit: decoys_fasta

    script:
    """
    echo "Generating decoys using YARP!..."
        yarp \
        --fasta-file ${fixed_fasta} \
        --decoy-prefix ${decoy_prefix} \
        --decoy-method reverse \
        --protease trypsin \
        --seed 42 \
        >${fixed_fasta.baseName}.plusdecoys.fasta \
        2>${fixed_fasta.baseName}.plusdecoys.fasta.stderr

    echo "Done!" # Needed for proper exit
    """
}
