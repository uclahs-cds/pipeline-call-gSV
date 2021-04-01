#!/usr/bin/env nextflow

nextflow.enable.dsl=2


log.info """\
======================================
C A L L - G S V   N F  P I P E L I N E
======================================
Boutros Lab


Current Configuration:
- input:
    input_csv: ${params.input_csv}
    reference_fasta: ${params.reference_fasta}
    reference_fasta_index: ${params.reference_fasta_index}
    reference_prefix: ${params.reference_prefix}
    exclusion_file: ${params.exclusion_file}
    mappability_map: ${params.mappability_map}

- output:
    output_dir: ${params.output_dir}
    output_log_dir: ${params.output_log_dir}
    temp_dir: ${params.temp_dir}

- options:
    save_intermediate_files: ${params.save_intermediate_files}
    run_qc: ${params.run_qc}
    map_qual: ${params.map_qual}

- tools:
    delly: ${params.delly_version}
    bcftools: ${params.bcftools_version}
    vcftools: ${params.vcftools_version}
    rtgtools: ${params.rtgtools_version}
    validation tool: ${params.validate_version}
    sha512: ${params.sha512_version}

------------------------------------
Starting workflow...
------------------------------------
"""
.stripIndent()

include { validate_file } from './modules/validation'
include { delly_call_sv; delly_call_cnv } from './modules/delly'
include { bcftools_sv_vcf; bcftools_cnv_vcf } from './modules/bcftools'
include { rtgtools_vcfstats } from './modules/rtgtools'
include { vcftools_validator } from './modules/vcftools'
include { generate_sha512 } from './modules/sha512'

input_bam_ch = Channel
    .fromPath(params.input_csv, checkIfExists:true)
    .splitCsv(header:true)
    .map{ row -> tuple(
                    row.patient,
                    row.sample,
                    row.input_bam,
                    "${row.input_bam}.bai"
                    )
        }

if (!params.reference_fasta) {
    // error out - must provide a reference FASTA file
    error "***Error: You must specify a reference FASTA file***"
}

if (!params.exclusion_file) {
    // error out - must provide exclusion file
    error "***Error: You must provide an exclusion file***"
}

if (params.reference_fasta_index) {
    reference_fasta_index = params.reference_fasta_index
}
else {
    reference_fasta_index = "${params.reference_fasta}.fai"
}

// Create channel for validation
validation_channel = Channel
    .fromPath(params.input_csv, checkIfExists:true)
    .splitCsv(header:true)
    .map{ row -> [ 
                row.input_bam,
                params.reference_fasta
                ]
        }
    .flatten()

workflow {
    validate_file(validation_channel)
    delly_call_sv(input_bam_ch, params.reference_fasta, reference_fasta_index, params.exclusion_file)
    delly_call_cnv(input_bam_ch, delly_call_sv.out.bcf_sv_file, params.reference_fasta, reference_fasta_index, params.mappability_map)
    bcftools_sv_vcf(delly_call_sv.out.bcf_sv_file, delly_call_sv.out.bam_sample_name)
    bcftools_cnv_vcf(delly_call_cnv.out.bcf_cnv_file, delly_call_cnv.out.bam_sample_name)
    if (params.run_qc) {
        rtgtools_vcfstats(bcftools_sv_vcf.out.vcf_sv_file, delly_call_sv.out.bam_sample_name)
        vcftools_validator(bcftools_sv_vcf.out.vcf_sv_file, delly_call_sv.out.bam_sample_name)
    }
    generate_sha512(delly_call_sv.out.bcf_sv_file.mix(bcftools_sv_vcf.out.vcf_sv_file,delly_call_cnv.out.bcf_cnv_file,bcftools_cnv_vcf.out.vcf_cnv_file))
}
