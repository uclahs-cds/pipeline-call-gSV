#!/usr/bin/env nextflow

nextflow.enable.dsl=2


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
- run_qc                ${params.run_qc}
- output_dir            ${params.output_dir}


------------------------------------
Starting workflow...
------------------------------------
"""
.stripIndent()

include { validate_file } from './modules/validation'
include { delly_call_sv } from './modules/delly'
include { bcftools_vcf } from './modules/bcftools'
include { rtgtools_vcfstats } from './modules/rtgtools'

workflow {
    validate_file(channel.fromList([params.input_bam, params.input_bam_index]))
    delly_call_sv(params.exclusion_file, params.reference_fasta, [params.input_bam, params.input_bam_index])
    bcftools_vcf(delly_call_sv.out.bcf_sv_file)
    if (params.run_qc) {
        rtgtools_vcfstats(bcftools_vcf.out.vcf_sv_file)
    }
}
