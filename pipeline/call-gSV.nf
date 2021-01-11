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
- output_dir            ${params.output_dir}


------------------------------------
Starting workflow...
------------------------------------
"""
.stripIndent()

include { validate_file } from './modules/validation'
include { delly_call_sv } from './modules/delly'
include { bcftools_vcf } from './modules/bcftools'

workflow {
    validate_file(channel.fromList([params.input_bam, params.input_bam_index]))
    delly_call_sv(params.exclusion_file, params.reference_fasta, [params.input_bam, params.input_bam_index])
    bcftools_vcf(params.bcftools_sv_file)
}
