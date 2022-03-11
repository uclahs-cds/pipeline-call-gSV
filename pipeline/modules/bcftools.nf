#!/usr/bin/env nextflow

log.info """\
------------------------------------
          B C F T O O L S
------------------------------------
Docker Images:
- docker_image_bcftools: ${params.docker_image_bcftools}
"""

process convert_BCF2VCF_BCFtools {
    container params.docker_image_bcftools

    publishDir "${params.output_dir}/${params.docker_image_delly.split("/")[1].replace(':', '-').toUpperCase()}/intermediate/${task.process.replace(':', '/')}",
        pattern: "*.vcf",
        mode: "copy"

    publishDir "${params.log_output_dir}/process-log",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}/log${file(it).getName()}" }

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
