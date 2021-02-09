#!/usr/bin/env nextflow

nextflow.enable.dsl=2


log.info """\
======================================
C A L L - G S V   N F  P I P E L I N E
======================================
Boutros Lab


------------------------------------
Starting workflow...
------------------------------------
"""
.stripIndent()

include { validate_file } from './modules/validation'
include { delly_call_sv } from './modules/delly'
include { bcftools_vcf } from './modules/bcftools'
include { rtgtools_vcfstats } from './modules/rtgtools'
include { vcftools_validator } from './modules/vcftools'

delly_bam_ch = Channel
    .fromPath(params.input_csv, checkIfExists:true)
    //.ifEmpty { error "Cannot find input csv: ${params.input_csv}"}
    .splitCsv(header:true)
    .map{ row -> tuple(
    				row.patient,
    				row.sample,
    				file(row.input_bam),
    				file(row.input_bai),
    				file(row.ref_fa),
    				file(row.ref_fai),
    				file(row.exclusion_tsv)
    				)
    	}

// Create channel for validation
validation_channel = Channel
	.fromPath(params.input_csv, checkIfExists:true)
	.splitCsv(header:true)
	.map{ row -> tuple(file(row.input_bam),file(row.input_bai))}
	.collect()

workflow {
    validate_file(validation_channel)
    delly_call_sv(delly_bam_ch)
    bcftools_vcf(delly_bam_ch, delly_call_sv.out.bcf_sv_file)
    if (params.run_qc) {
        rtgtools_vcfstats(delly_bam_ch, bcftools_vcf.out.vcf_sv_file)
        vcftools_validator(delly_bam_ch, bcftools_vcf.out.vcf_sv_file)
    }
}
