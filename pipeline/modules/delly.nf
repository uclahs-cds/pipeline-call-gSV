#!/usr/bin/env nextflow

def docker_image_delly = "blcdsdockerregistry/delly:${params.delly_version}"

log.info """\
------------------------------------
             D E L L Y
------------------------------------
Docker Images:
- docker_image_delly:   ${docker_image_delly}
"""

process call_gSV_Delly {
    container docker_image_delly

    publishDir params.output_dir,
        enabled: params.save_intermediate_files,
        pattern: "*.bcf*",
        mode: "copy",
        saveAs: { "Delly-${params.delly_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "call_gSV_Delly/${bam_sample_name}.log${file(it).getName()}" }

    input:
    tuple val(patient), val(bam_sample_name), path(input_bam), path(input_bam_bai)
    path(reference_fasta)
    path(reference_fasta_fai)
    path(exclusion_file)


    output:
    path "DELLY-${params.delly_version}_SV_${params.dataset_id}_${bam_sample_name}.bcf", emit: bcf_sv_file
    path "DELLY-${params.delly_version}_SV_${params.dataset_id}_${bam_sample_name}.bcf.csi"
    path ".command.*"
    val bam_sample_name, emit: bam_sample_name

    """
    set -euo pipefail
    delly \
        call \
        --exclude   $exclusion_file \
        --genome    $reference_fasta \
        --outfile   DELLY-${params.delly_version}_SV_${params.dataset_id}_${bam_sample_name}.bcf \
        --map-qual ${params.map_qual} \
        $input_bam
    """
}

process regenotype_gSV_Delly {
    container docker_image_delly

    publishDir params.output_dir,
        enabled: params.save_intermediate_files,
        pattern: "*.bcf*",
        mode: "copy",
        saveAs: { "Delly-${params.delly_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "regenotype_gSV_Delly/${bam_sample_name}.log${file(it).getName()}" }

    input:
        tuple val(bam_sample_name), path(input_bam), path(input_bam_bai), val(mode)
        path(reference_fasta)
        path(reference_fasta_fai)
        path(exclusion_file_or_mappability_map)
        path(sites)

    when:
    mode == 'SV'

    output:
        path "DELLY-${params.delly_version}_RGSV_${params.dataset_id}_${bam_sample_name}.bcf", emit: regenotyped_sv_bcf
        path "DELLY-${params.delly_version}_RGSV_${params.dataset_id}_${bam_sample_name}.bcf.csi", emit: regenotyped_sv_bcf_csi
        path ".command.*"

    script:
    """
    set -euo pipefail
    delly \
        call \
        --vcffile $sites \
        --exclude $exclusion_file_or_mappability_map \
        --genome $reference_fasta \
        --outfile "DELLY-${params.delly_version}_RGSV_${params.dataset_id}_${bam_sample_name}.bcf" \
        --map-qual ${params.map_qual} \
        "$input_bam"
    """
}

process call_gCNV_Delly {
    container docker_image_delly

    publishDir params.output_dir,
        enabled: params.save_intermediate_files,
        pattern: "*.bcf*",
        mode: "copy",
        saveAs: { "Delly-${params.delly_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "call_gCNV_Delly/${bam_sample_name}.log${file(it).getName()}" }

    input:
    tuple val(patient), val(bam_sample_name), path(input_bam), path(input_bam_bai)
    path(delly_sv_file)
    path(reference_fasta)
    path(reference_fasta_fai)
    path(mappability_file)

    output:
    path "DELLY-${params.delly_version}_CNV_${params.dataset_id}_${bam_sample_name}.bcf", emit: bcf_cnv_file
    path "DELLY-${params.delly_version}_CNV_${params.dataset_id}_${bam_sample_name}.bcf.csi"
    path ".command.*"
    val bam_sample_name, emit: bam_sample_name

    """
    set -euo pipefail
    delly \
        cnv \
        --genome        $reference_fasta \
        --outfile       DELLY-${params.delly_version}_CNV_${params.dataset_id}_${bam_sample_name}.bcf \
        --svfile        $delly_sv_file \
        --mappability   ${params.mappability_map} \
        $input_bam
    """
}

process regenotype_gCNV_Delly {
    container docker_image_delly

    publishDir params.output_dir,
        enabled: params.save_intermediate_files,
        pattern: "*.bcf*",
        mode: "copy",
        saveAs: { "Delly-${params.delly_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "regenotype_gCNV_Delly/${bam_sample_name}.log${file(it).getName()}" }

    input:
        tuple val(bam_sample_name), path(input_bam), path(input_bam_bai), val(mode)
        path(reference_fasta)
        path(reference_fasta_fai)
        path(exclusion_file_or_mappability_map)
        path(sites)

    output:
        path "DELLY-${params.delly_version}_RGCNV_${params.dataset_id}_${bam_sample_name}.bcf", emit: regenotyped_cnv_bcf
        path "DELLY-${params.delly_version}_RGCNV_${params.dataset_id}_${bam_sample_name}.bcf.csi", emit: regenotyped_cnv_bcf_csi
        path ".command.*"

    when:
    mode == 'CNV'

    script:
    """
    set -euo pipefail
    delly \
        cnv \
        --segmentation \
        --vcffile       $sites \
        --exclude $exclusion_file_or_mappability_map \
        --genome $reference_fasta \
        --outfile "DELLY-${params.delly_version}_RGCNV_${params.dataset_id}_${bam_sample_name}.bcf" \
        "$input_bam"
    """
}