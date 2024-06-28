#!/usr/bin/env nextflow

log.info """\
------------------------------------
          V C F T O O L S
------------------------------------
Docker Images:
- docker_image_vcftools: ${params.docker_image_vcftools}
"""

process run_vcf_validator_VCFtools {
    container params.docker_image_vcftools

    publishDir "${params.workflow_output_dir}/QC/${task.process.replace(':', '/')}",
        pattern: "*_validation.txt",
        mode: "copy"

    input:
        path vcf_sv_file
        val bam_sample_name
        val variant_type

    output:
        path "DELLY-${params.delly_version}_${variant_type}_${params.dataset_id}_${bam_sample_name}_validation.txt"

    """
    set -euo pipefail
    vcf-validator -d -u $vcf_sv_file > DELLY-${params.delly_version}_${variant_type}_${params.dataset_id}_${bam_sample_name}_validation.txt;
    """
    }
