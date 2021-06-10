#!/usr/bin/env nextflow

def docker_image_bcftools = "blcdsdockerregistry/bcftools:${params.bcftools_version}"

log.info """\
------------------------------------
          B C F T O O L S
------------------------------------
Docker Images:
- docker_image_bcftools:   ${docker_image_bcftools}
"""

process convert_BCF2VCF_BCFtools {
    container docker_image_bcftools

    publishDir params.output_dir,
        pattern: "*.vcf",
        mode: "copy",
        saveAs: { "BCFtools-${params.bcftools_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "convert_g${variant_type}_BCF2VCF_BCFtools/${bam_sample_name}.log${file(it).getName()}" }

    input:
    path bcf_file
    val bam_sample_name
    val variant_type

    output:
    path "DELLY-${params.delly_version}_${variant_type}_${params.dataset_id}_${bam_sample_name}.vcf", emit: vcf_file
    path ".command.*"

    """
    set -euo pipefail
    bcftools \
        view \
        $bcf_file \
        --output DELLY-${params.delly_version}_${variant_type}_${params.dataset_id}_${bam_sample_name}.vcf
    """
}