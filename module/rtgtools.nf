#!/usr/bin/env nextflow

log.info """\
------------------------------------
          R T G T O O L S
------------------------------------
Docker Images:
- docker_image_rtgtools: ${params.docker_image_rtgtools}
"""

process run_vcfstats_RTGTools {
    container params.docker_image_rtgtools

    publishDir "${params.workflow_output_dir}/intermediate/${task.process.replace(':', '/')}",
        enabled: params.save_intermediate_files,
        pattern: "*_stats.txt",
        mode: "copy"

    publishDir "${params.workflow_log_dir}",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}/log${file(it).getName()}" }

    input:
        path vcf_sv_file
        val bam_sample_name
        val variant_type

    output:
        path "DELLY-${params.delly_version}_${variant_type}_${params.dataset_id}_${bam_sample_name}_stats.txt"
        path ".command.*"

    """
    set -euo pipefail
    rtg vcfstats $vcf_sv_file > DELLY-${params.delly_version}_${variant_type}_${params.dataset_id}_${bam_sample_name}_stats.txt
    """
    }
