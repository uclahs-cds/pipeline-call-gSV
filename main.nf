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
    sample: ${params.sample_to_process}
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
    validation tool: ${params.pipeval_version}

------------------------------------
Starting workflow...
------------------------------------
"""
.stripIndent()

include { generate_standard_filename } from './external/pipeline-Nextflow-module/modules/common/generate_standardized_filename/main.nf'

include { run_validate_PipeVal } from './external/pipeline-Nextflow-module/modules/PipeVal/validate/main.nf' addParams(
    options: [ docker_image_version: params.pipeval_version ]
    )
include { call_gSV_Delly; call_gCNV_Delly; regenotype_gSV_Delly; regenotype_gCNV_Delly } from './module/delly' addParams(
    output_filename: generate_standard_filename(
        "DELLY-${params.delly_version}",
        params.dataset_id,
        "${params.sample}",
        [:]
        ),
    workflow_output_dir: "${params.output_dir_base}/DELLY-${params.delly_version}",
    workflow_log_dir: "${params.log_output_dir}/process-log/DELLY-${params.delly_version}"
    )
include { call_gSV_Manta } from './module/manta' addParams(
    output_filename: generate_standard_filename(
        "Manta-${params.manta_version}",
        params.dataset_id,
        "${params.sample}",
        [:]
        ),
    workflow_output_dir: "${params.output_dir_base}/Manta-${params.manta_version}",
    workflow_log_dir: "${params.log_output_dir}/process-log/Manta-${params.manta_version}"
    )
include { convert_BCF2VCF as convert_gSV_BCF2VCF; convert_BCF2VCF as convert_gCNV_BCF2VCF } from './module/workflow-convert_BCF2VCF' addParams(
    workflow_output_dir: "${params.output_dir_base}/DELLY-${params.delly_version}",
    )
include { run_vcfstats_RTGTools as run_gSV_vcfstats_RTGTools; run_vcfstats_RTGTools as run_gCNV_vcfstats_RTGTools } from './module/rtgtools' addParams(
    workflow_output_dir: "${params.output_dir_base}/DELLY-${params.delly_version}",
    workflow_log_dir: "${params.log_output_dir}/process-log/DELLY-${params.delly_version}"
    )
include { run_vcf_validator_VCFtools as run_gSV_vcf_validator_VCFtools; run_vcf_validator_VCFtools as run_gCNV_vcf_validator_VCFtools } from './module/vcftools' addParams(
    workflow_output_dir: "${params.output_dir_base}/DELLY-${params.delly_version}",
    workflow_log_dir: "${params.log_output_dir}/process-log/DELLY-${params.delly_version}"
    )
include { plot_SV_circlize as plot_MantaSV_circlize } from './module/circos-plot.nf' addParams(
    workflow_output_dir: "${params.output_dir_base}/Manta-${params.manta_version}"
    )
include { plot_SV_circlize as plot_DellySV_circlize } from './module/circos-plot.nf' addParams(
    workflow_output_dir: "${params.output_dir_base}/DELLY-${params.delly_version}"
    )
include { run_sha512sum as run_sha512sum_gSV_Delly; run_sha512sum as run_sha512sum_gCNV_Delly; run_sha512sum as run_sha512sum_regeno_gSV_Delly; run_sha512sum as run_sha512sum_regeno_gCNV_Delly } from './module/sha512' addParams(
    workflow_output_dir: "${params.output_dir_base}/DELLY-${params.delly_version}",
    workflow_log_dir: "${params.log_output_dir}/process-log/DELLY-${params.delly_version}"
    )
include { run_sha512sum as run_sha512sum_Manta } from './module/sha512' addParams(
    workflow_output_dir: "${params.output_dir_base}/Manta-${params.manta_version}",
    workflow_log_dir: "${params.log_output_dir}/process-log/Manta-${params.manta_version}"
    )

// Returns the index file for the given bam
def indexFile(bam) {
    if (bam.endsWith('.bam')) {
        return "${bam}.bai"
    } else {
        throw new Exception("Index file for ${bam} file type not supported. Use .bam!")
    }
}

Channel.from(params.sample_to_process)
    .map{ sample -> ['index': indexFile(sample.path)] + sample }
    .set{ input_ch_samples_with_index }

input_ch_samples_with_index
    .map{ sample -> [sample.path, sample.index] }
    .flatten()
    .set{ input_validation }

input_ch_samples_with_index
    .map{ it -> [it.id, it.path, it.index] }
    .set { input_bam_ch }

reference_fasta_index = "${params.reference_fasta}.fai"

workflow {
    /**
    * Validate the input bams
    */
    run_validate_PipeVal(input_validation)
    // Collect and store input validation output
    run_validate_PipeVal.out.validation_result.collectFile(
        name: 'input_validation.txt',
        storeDir: "${params.output_dir_base}/validation/run_validate_PipeVal"
        )

    if (params.run_discovery) {
        if (params.run_manta) {
            call_gSV_Manta(input_bam_ch, params.reference_fasta, reference_fasta_index)

            call_gSV_Manta.out.vcf_candidate_sv_file
                .map{ ['Manta', it] }
                .set{ input_ch_plot_manta }

            plot_MantaSV_circlize(
                input_ch_plot_manta
                )

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

            convert_gSV_BCF2VCF(
                call_gSV_Delly.out.bam_sample_name,
                call_gSV_Delly.out.bcf_sv_file,
                call_gSV_Delly.out.bcf_sv_file_csi
                )

            convert_gSV_BCF2VCF.out.gzvcf
                .map{ ['DELLY', it] }
                .set{ input_ch_plot_delly }

            plot_DellySV_circlize(
                input_ch_plot_delly
                )

            run_sha512sum_gSV_Delly(
                call_gSV_Delly.out.bcf_sv_file
                .mix(call_gSV_Delly.out.bcf_sv_file_csi)
                .mix(convert_gSV_BCF2VCF.out.gzvcf)
                .mix(convert_gSV_BCF2VCF.out.idx)
                )

            if (params.variant_type.contains(params.GCNV)) {
                call_gCNV_Delly(input_bam_ch, call_gSV_Delly.out.bcf_sv_file.toList(), params.reference_fasta, reference_fasta_index, params.mappability_map)
                convert_gCNV_BCF2VCF(
                    call_gCNV_Delly.out.bam_sample_name,
                    call_gCNV_Delly.out.bcf_cnv_file,
                    call_gCNV_Delly.out.bcf_cnv_file_csi
                    )
                run_sha512sum_gCNV_Delly(
                    call_gCNV_Delly.out.bcf_cnv_file
                    .mix(call_gCNV_Delly.out.bcf_cnv_file_csi)
                    .mix(convert_gCNV_BCF2VCF.out.gzvcf)
                    .mix(convert_gCNV_BCF2VCF.out.idx)
                    )
                }

            if (params.run_qc) {
                run_gSV_vcfstats_RTGTools(convert_gSV_BCF2VCF.out.gzvcf, call_gSV_Delly.out.bam_sample_name, params.GSV)
                run_gSV_vcf_validator_VCFtools(convert_gSV_BCF2VCF.out.gzvcf, call_gSV_Delly.out.bam_sample_name, params.GSV)

                if (params.variant_type.contains(params.GCNV)) {
                    run_gCNV_vcfstats_RTGTools(convert_gCNV_BCF2VCF.out.gzvcf, call_gCNV_Delly.out.bam_sample_name, params.GCNV)
                    run_gCNV_vcf_validator_VCFtools(convert_gCNV_BCF2VCF.out.gzvcf, call_gCNV_Delly.out.bam_sample_name, params.GCNV)
                    }
                }
            }
        }
    // When 'run_regenotyping' is set to true, the variant_type specified in the input_csv will be used to determine which
    // regenotyping process to run. For example, if the variant_type contains 'gSV', regenotype_gSV_Delly will run, etc.
    if (params.run_regenotyping) {
        if (params.variant_type.contains(params.GSV)) {
            regenotype_gSV_Delly(input_bam_ch, params.reference_fasta, reference_fasta_index, params.exclusion_file, params.merged_sites_gSV)
            run_sha512sum_regeno_gSV_Delly(regenotype_gSV_Delly.out.regenotyped_sv_bcf.mix(regenotype_gSV_Delly.out.regenotyped_sv_bcf_csi))
        }

        if (params.variant_type.contains(params.GCNV)) {
            regenotype_gCNV_Delly(input_bam_ch, params.reference_fasta, reference_fasta_index, params.mappability_map, params.merged_sites_gCNV)
            run_sha512sum_regeno_gCNV_Delly(regenotype_gCNV_Delly.out.regenotyped_cnv_bcf.mix(regenotype_gCNV_Delly.out.regenotyped_cnv_bcf_csi))
        }
    }
}
