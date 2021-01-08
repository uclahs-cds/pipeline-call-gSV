#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Docker images here...
// def docker_image_delly = "blcdsdockerregistry/call-gsv:delly-0.8.6"
// def docker_image_bcftools = "blcdsdockerregistry/call-gsv:bcftools-1.11"
// def docker_image_validation = "blcdsdockerregistry/validate:1.0.0"

// Log info here
log.info """\
======================================
C A L L - G S V   N F  P I P E L I N E
======================================
Boutros Lab

Parameters:
- sample_name           ${params.sample_name}
- input_bam             ${params.input_bam}
- input_bam_index       ${params.input_bam_index}
- reference_fasta       ${params.reference_fasta}
- exclusion_file        ${params.exclusion_file}


------------------------------------
Starting workflow...
------------------------------------
"""
.stripIndent()

include { validate_file } from './modules/validation'
include { delly_call_sv } from './modules/delly'

workflow {
    validate_file(channel.fromList([params.input_bam, params.input_bam_index]))
    delly_call_sv()
}

// Channels here

// Validation
// Channel
//     .fromList([])
//     .set { ch_validate_inputs }

// // Reference FASTA channel
// Channel
//    .fromPath(params.reference_fasta)
//    .ifEmpty { error "Cannot find reference fasta: ${params.reference_fasta}" }
//    .into { input_ch_reference_fasta }

// // Reference exclusions
// Channel
//    .fromPath(params.reference_exclusion)
//    .ifEmpty { error "Cannot find reference exclusion: ${params.reference_exclusion}" }
//    .into { input_ch_reference_exclusion }

// // Input BAM
// Channel
//     .fromPath(params.input_bam)
//     .into { input_ch_bam }
//    //.fromPath(params.input_csv)
//    //.splitCsv(header:true)

// Input BAI


// process call_delly {
//    container docker_image_delly

//    publishDir params.output_dir, enabled: true, mode: 'copy'

//    label "resource_allocation_tool_name_command_name"

//    // Additional directives here
   
//    input: 
//       file(excl_tsv) from input_ch_reference_exclusion
//       file(ref_fasta) from input_ch_reference_fasta
//       file(bam) from input_ch_bam

//       tuple(val(row_1_name), 
//          path(row_2_name_file_extension),
//       ) from input_ch_input_csv
//       val(variable_name) from input_ch_variable_name

//    output:
//       file("${variable_name}.command_name.file_extension") into output_ch_tool_name_command_name

//    script:
//    """
//    # make sure to specify pipefail to make sure process correctly fails on error
//    set -euo pipefail

//    # the script should ideally only have call to a tool
//    # to make the command more human readable:
//    #  - seperate components of the call out on different lines
//    #  - when possible by explict with command options, spelling out their long names
//    delly \
//       call \
//       #--svtype ALL
//       --exclude   $excl_tsv \
//       --genome    $ref_fasta \
//       --outfile   sv.bcf \
//       #--vcffile 
//       $bam


//       --input ${row_2_name_file_extension} \
//       --output ${variable_name}.command_name.file_extension
//    """
// }
