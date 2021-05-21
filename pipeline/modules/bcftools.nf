#!/usr/bin/env nextflow

def docker_image_bcftools = "blcdsdockerregistry/bcftools:${params.bcftools_version}"

log.info """\
------------------------------------
          B C F T O O L S
------------------------------------
Docker Images:
- docker_image_bcftools:   ${docker_image_bcftools}
"""

process convert_gSV_BCF2VCF_BCFtools {
    container docker_image_bcftools

    publishDir params.output_dir,
        pattern: "*.vcf",
        mode: "copy",
        saveAs: { "bcftools-${params.bcftools_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "convert_gSV_BCF2VCF_BCFtools/${bam_sample_name}.log${file(it).getName()}" }

    input:
    path bcf_sv_file
    val bam_sample_name

    output:
    path "DELLY-${params.delly_version}_SV_${params.dataset_id}_${bam_sample_name}.vcf", emit: vcf_sv_file
    path ".command.*"

    """
    set -euo pipefail
    bcftools \
        view \
        $bcf_sv_file \
        --output DELLY-${params.delly_version}_SV_${params.dataset_id}_${bam_sample_name}.vcf
    """
}

process convert_gCNV_BCF2VCF_BCFtools {
    container docker_image_bcftools

    publishDir params.output_dir,
        pattern: "*.vcf",
        mode: "copy",
        saveAs: { "bcftools-${params.bcftools_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "convert_gCNV_BCF2VCF_BCFtools/${bam_sample_name}.log${file(it).getName()}" }

    input:
    path bcf_cnv_file
    val bam_sample_name

    output:
    path "DELLY-${params.delly_version}_CNV_${params.dataset_id}_${bam_sample_name}.vcf", emit: vcf_cnv_file
    path ".command.*"

    """
    set -euo pipefail
    bcftools \
        view \
        $bcf_cnv_file \
        --output DELLY-${params.delly_version}_CNV_${params.dataset_id}_${bam_sample_name}.vcf
    """
}