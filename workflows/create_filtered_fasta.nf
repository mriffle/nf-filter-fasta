// Modules
include { MSCONVERT } from "../modules/msconvert"
include { COMET } from "../modules/comet"
include { PERCOLATOR } from "../modules/percolator"
include { FILTER_PIN } from "../modules/filter_pin"
include { COMBINE_PIN_FILES } from "../modules/combine_pin_files"
include { ADD_FASTA_TO_COMET_PARAMS } from "../modules/add_fasta_to_comet_params"
include { FILTER_FASTA } from "../modules/filter_fasta"
include { FIX_FASTA } from "../modules/fix_fasta"
include { GENERATE_DECOYS } from "../modules/generate_decoys"

workflow create_filtered_fasta {

    take:
        spectra_file_ch
        comet_params
        fasta
        from_raw_files
    
    main:

        // modify comet.params to specify search database
        ADD_FASTA_TO_COMET_PARAMS(comet_params, fasta)
        new_comet_params = ADD_FASTA_TO_COMET_PARAMS.out.comet_fasta_params

        // convert raw files to mzML files if necessary
        if(from_raw_files) {
            mzml_file_ch = MSCONVERT(spectra_file_ch)
        } else {
            mzml_file_ch = spectra_file_ch
        }

        // run comet
        COMET(mzml_file_ch, new_comet_params, fasta)
        // FILTER_PIN(COMET.out.pin)
        
        filtered_pin_files = COMET.out.pin.collect()

        // run percolator
        COMBINE_PIN_FILES(filtered_pin_files)
        PERCOLATOR(COMBINE_PIN_FILES.out.combined_pin)

        // run filterFasta
        FILTER_FASTA(
            PERCOLATOR.out.pout,
            fasta,
            params.peptide_qvalue_filter,
            params.psm_qvalue_filter,
            params.distinct_peptide_count
        )

        // run fastaFixer
        FIX_FASTA(FILTER_FASTA.out.filtered_pin)

        // create decoy version
        GENERATE_DECOYS(params.decoy_prefix, FIX_FASTA.out.fixed_fasta)

}
