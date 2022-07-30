#!/usr/bin/env nextflow

nextflow.enable.dsl=2


log.info """\
=======================================
C A L L - G S V   N F   P I P E L I N E
=======================================
Boutros Lab


Current Configuration:
- pipeline:
    name: ${workflow.manifest.name}
    version: ${workflow.manifest.version}

- input:
    input_csv: ${params.input_csv}
    reference_fasta: ${params.reference_fasta}
    reference_fasta_index: "${params.reference_fasta}.fai"
    exclusion_file: ${params.exclusion_file}
    mappability_map: ${params.mappability_map}

- output:
    output_dir: ${params.output_dir}
    log_output_dir: ${params.log_output_dir}

- options:
    save_intermediate_files: ${params.save_intermediate_files}
    run_qc: ${params.run_qc}
    map_qual: ${params.map_qual}
    run_delly: ${params.run_delly}
    run_manta: ${params.run_manta}

- tools:
    delly: ${params.delly_version}
    manta: ${params.manta_version}
    bcftools: ${params.bcftools_version}
    vcftools: ${params.vcftools_version}
    rtgtools: ${params.rtgtools_version}
    validation tool: ${params.validate_version}

------------------------------------
Starting workflow...
------------------------------------
"""
.stripIndent()

include { run_validate } from './module/validation'
include { call_gSV_Delly; call_gCNV_Delly; regenotype_gSV_Delly; regenotype_gCNV_Delly } from './module/delly'
include { call_gSV_Manta } from './module/manta'
include { convert_BCF2VCF_BCFtools as convert_gSV_BCF2VCF_BCFtools; convert_BCF2VCF_BCFtools as convert_gCNV_BCF2VCF_BCFtools } from './module/bcftools'
include { run_vcfstats_RTGTools as run_gSV_vcfstats_RTGTools; run_vcfstats_RTGTools as run_gCNV_vcfstats_RTGTools } from './module/rtgtools'
include { run_vcf_validator_VCFtools as run_gSV_vcf_validator_VCFtools; run_vcf_validator_VCFtools as run_gCNV_vcf_validator_VCFtools } from './module/vcftools'
include { run_sha512sum as run_sha512sum_gSV_Delly; run_sha512sum as run_sha512sum_gCNV_Delly; run_sha512sum as run_sha512sum_regeno_gSV_Delly; run_sha512sum as run_sha512sum_regeno_gCNV_Delly } from './module/sha512' addParams(docker_image_name: "$params.docker_image_delly".toUpperCase())
include { run_sha512sum as run_sha512sum_Manta } from './module/sha512' addParams(docker_image_name: "$params.docker_image_manta")


checked_variant_type = []
if (params.run_delly || params.run_regenotyping) {
    for (vt in params.variant_type) {
        if ('gsv' == vt.toLowerCase() || 'sv' == vt.toLowerCase()) {
            checked_variant_type.add(params.GSV)
            }
        if ('gcnv' == vt.toLowerCase() || 'cnv' == vt.toLowerCase()) {
            checked_variant_type.add(params.GCNV)
            }
        }
    if (checked_variant_type.isEmpty()) {
        throw new Exception("ERROR: checked_variant_type cannot be empty")
        }
    }


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

if (!params.run_delly && !params.run_manta) {
    // error out - must specify a valid SV caller
    error "***Error: You must specify either Delly or Manta***"
    }

reference_fasta_index = "${params.reference_fasta}.fai"

validation_channel = Channel
    .fromPath(params.input_csv, checkIfExists:true)
    .splitCsv(header:true)
    .map{ row -> [row.input_bam, "${row.input_bam}.bai"]}
    .flatten()

workflow {
    run_validate(validation_channel)

    if (params.run_discovery) {
        if (params.run_manta) {
            call_gSV_Manta(input_bam_ch, params.reference_fasta, reference_fasta_index)
            run_sha512sum_Manta(call_gSV_Manta.out.vcf_small_indel_sv_file.mix(
                call_gSV_Manta.out.vcf_diploid_sv_file,
                call_gSV_Manta.out.vcf_candidate_sv_file,
                call_gSV_Manta.out.vcf_small_indel_sv_tbi,
                call_gSV_Manta.out.vcf_diploid_sv_tbi,
                call_gSV_Manta.out.vcf_candidate_sv_tbi
                ))
            }
        if (params.run_delly) {
            call_gSV_Delly(input_bam_ch, params.reference_fasta, reference_fasta_index, params.exclusion_file)
            convert_gSV_BCF2VCF_BCFtools(call_gSV_Delly.out.bcf_sv_file, call_gSV_Delly.out.bam_sample_name, params.GSV)
            run_sha512sum_gSV_Delly(call_gSV_Delly.out.bcf_sv_file.mix(call_gSV_Delly.out.bcf_sv_file_csi))

            if (checked_variant_type.contains(params.GCNV)) {
                call_gCNV_Delly(input_bam_ch, call_gSV_Delly.out.bcf_sv_file.toList(), params.reference_fasta, reference_fasta_index, params.mappability_map)
                convert_gCNV_BCF2VCF_BCFtools(call_gCNV_Delly.out.bcf_cnv_file, call_gCNV_Delly.out.bam_sample_name, params.GCNV)
                run_sha512sum_gCNV_Delly(call_gCNV_Delly.out.bcf_cnv_file.mix(call_gCNV_Delly.out.bcf_cnv_file_csi))
                }

            if (params.run_qc) {
                run_gSV_vcfstats_RTGTools(convert_gSV_BCF2VCF_BCFtools.out.vcf_file, call_gSV_Delly.out.bam_sample_name, params.GSV)
                run_gSV_vcf_validator_VCFtools(convert_gSV_BCF2VCF_BCFtools.out.vcf_file, call_gSV_Delly.out.bam_sample_name, params.GSV)

                if (checked_variant_type.contains(params.GCNV)) {
                    run_gCNV_vcfstats_RTGTools(convert_gCNV_BCF2VCF_BCFtools.out.vcf_file, call_gCNV_Delly.out.bam_sample_name, params.GCNV)
                    run_gCNV_vcf_validator_VCFtools(convert_gCNV_BCF2VCF_BCFtools.out.vcf_file, call_gCNV_Delly.out.bam_sample_name, params.GCNV)
                    }
                }
            }
        }
    // When 'run_regenotyping' is set to true, the variant_type specified in the input_csv will be used to determine which
    // regenotyping process to run. For example, if the variant_type contains 'gSV', regenotype_gSV_Delly will run, etc.
    if (params.run_regenotyping) {
        if (checked_variant_type.contains(params.GSV)) {
            regenotype_gSV_Delly(input_bam_ch, params.reference_fasta, reference_fasta_index, params.exclusion_file, params.merged_sites_gSV)
            run_sha512sum_regeno_gSV_Delly(regenotype_gSV_Delly.out.regenotyped_sv_bcf.mix(regenotype_gSV_Delly.out.regenotyped_sv_bcf_csi))
        }

        if (checked_variant_type.contains(params.GCNV)) {
            regenotype_gCNV_Delly(input_bam_ch, params.reference_fasta, reference_fasta_index, params.mappability_map, params.merged_sites_gCNV)
            run_sha512sum_regeno_gCNV_Delly(regenotype_gCNV_Delly.out.regenotyped_cnv_bcf.mix(regenotype_gCNV_Delly.out.regenotyped_cnv_bcf_csi))
        }
    }
}
