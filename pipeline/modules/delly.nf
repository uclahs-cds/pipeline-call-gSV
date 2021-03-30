#!/usr/bin/env nextflow

def docker_image_delly = "blcdsdockerregistry/call-gsv:delly-${params.delly_version}"

log.info """\
------------------------------------
             D E L L Y
------------------------------------
Docker Images:
- docker_image_delly:   ${docker_image_delly}
"""

process delly_call_sv {
    container docker_image_delly

    publishDir params.output_dir,
        enabled: params.save_intermediate_files,
        pattern: "*.bcf*",
        mode: "copy",
        saveAs: { "delly-${params.delly_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "delly_call_sv/${bam_sample_name}.log${file(it).getName()}" }

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

process delly_call_cnv {
    container docker_image_delly

    publishDir params.output_dir,
        enabled: params.save_intermediate_files,
        pattern: "*.bcf*",
        mode: "copy",
        saveAs: { "delly-${params.delly_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "delly_call_cnv/${bam_sample_name}.log${file(it).getName()}" }

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