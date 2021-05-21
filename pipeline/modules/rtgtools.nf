#!/usr/bin/env nextflow

def docker_image_rtgtools = "blcdsdockerregistry/rtg-tools:${params.rtgtools_version}"

log.info """\
------------------------------------
          R T G T O O L S
------------------------------------
Docker Images:
- docker_image_rtgtools:   ${docker_image_rtgtools}
"""

process run_vcfstats_RTGTools {
    container docker_image_rtgtools

    publishDir params.output_dir,
        pattern: "*_stats.txt",
        mode: "copy",
        saveAs: { "rtgtools-${params.rtgtools_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "run_vcfstats_RTGTools/${bam_sample_name}.log${file(it).getName()}" }

    input:
    path vcf_sv_file
    val bam_sample_name

    output:
    path "DELLY-${params.delly_version}_${params.dataset_id}_${bam_sample_name}_stats.txt"
    path ".command.*"

    """
    set -euo pipefail

    rtg vcfstats $vcf_sv_file > DELLY-${params.delly_version}_${params.dataset_id}_${bam_sample_name}_stats.txt
    """
}
