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
    reference_fasta_index: ${params.reference_fasta}.fai
    reference_prefix: ${params.reference_prefix}
    exclusion_file: ${params.exclusion_file}

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
include { delly_call_sv } from './modules/delly'
include { bcftools_vcf } from './modules/bcftools'
include { rtgtools_vcfstats } from './modules/rtgtools'
include { vcftools_validator } from './modules/vcftools'
include { generate_sha512 } from './modules/sha512'

delly_bam_ch = Channel
    .fromPath(params.input_csv, checkIfExists:true)
    .splitCsv(header:true)
    .map{ row -> tuple(
                    row.patient,
                    row.sample,
                    row.input_bam,
                    "${row.input_bam}.bai",
                    params.reference_fasta,
                    "${params.reference_fasta}.fai",
                    params.exclusion_file
                    )
        }

// Create channel for validation
validation_channel = Channel
    .fromPath(params.input_csv, checkIfExists:true)
    .splitCsv(header:true)
    .map{ row -> tuple(row.input_bam,"${row.input_bam}.bai")}

workflow {
    validate_file(validation_channel)
    delly_call_sv(delly_bam_ch)
    bcftools_vcf(delly_bam_ch, delly_call_sv.out.bcf_sv_file)
    if (params.run_qc) {
        rtgtools_vcfstats(delly_bam_ch, bcftools_vcf.out.vcf_sv_file)
        vcftools_validator(delly_bam_ch, bcftools_vcf.out.vcf_sv_file)
    }
    generate_sha512(delly_call_sv.out.bcf_sv_file.mix(bcftools_vcf.out.vcf_sv_file))
}
