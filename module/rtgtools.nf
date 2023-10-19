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

    publishDir "${params.output_dir_base}/${params.docker_image_delly.split("/")[-1].replace(':', '-').toUpperCase()}/intermediate/${task.process.replace(':', '/')}",
        enabled: params.save_intermediate_files,
        pattern: "*_stats.txt",
        mode: "copy"

    publishDir "$params.log_output_dir/process-log/${params.docker_image_delly.split("/")[-1].replace(':', '-').toUpperCase()}",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}-${task.index}/log${file(it).getName()}" }

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
