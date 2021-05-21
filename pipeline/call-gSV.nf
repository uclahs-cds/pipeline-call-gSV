#!/usr/bin/env nextflow

nextflow.enable.dsl=2


log.info """\
=======================================
C A L L - G S V   N F   P I P E L I N E
            version: ${workflow.manifest.version}
=======================================
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

include { run_validate } from './modules/validation'
include { call_gSV_Delly; call_gCNV_Delly } from './modules/delly'
include { convert_BCF2VCF_BCFtools as convert_gSV_BCF2VCF_BCFtools; convert_BCF2VCF_BCFtools as convert_gCNV_BCF2VCF_BCFtools } from './modules/bcftools'
include { run_vcfstats_RTGTools } from './modules/rtgtools'
include { run_vcf_validator_VCFtools } from './modules/vcftools'
include { run_sha512sum } from './modules/sha512'

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
    run_validate(validation_channel)
    call_gSV_Delly(input_bam_ch, params.reference_fasta, reference_fasta_index, params.exclusion_file)
    call_gCNV_Delly(input_bam_ch, call_gSV_Delly.out.bcf_sv_file, params.reference_fasta, reference_fasta_index, params.mappability_map)
    convert_gSV_BCF2VCF_BCFtools(call_gSV_Delly.out.bcf_sv_file, call_gSV_Delly.out.bam_sample_name, 'SV')
    convert_gCNV_BCF2VCF_BCFtools(call_gCNV_Delly.out.bcf_cnv_file, call_gCNV_Delly.out.bam_sample_name, 'CNV')
    if (params.run_qc) {
        run_vcfstats_RTGTools(convert_gSV_BCF2VCF_BCFtools.out.vcf_file, call_gSV_Delly.out.bam_sample_name)
        run_vcf_validator_VCFtools(convert_gSV_BCF2VCF_BCFtools.out.vcf_file, call_gSV_Delly.out.bam_sample_name)
    }
    run_sha512sum(call_gSV_Delly.out.bcf_sv_file.mix(convert_gSV_BCF2VCF_BCFtools.out.vcf_file,call_gCNV_Delly.out.bcf_cnv_file,convert_gCNV_BCF2VCF_BCFtools.out.vcf_file))
}
