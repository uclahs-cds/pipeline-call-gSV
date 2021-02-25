#!/usr/bin/env nextflow

def docker_image_rtgtools = "blcdsdockerregistry/call-gsv:rtgtools-${params.rtgtools_version}"

log.info """\
------------------------------------
          R T G T O O L S
------------------------------------
Docker Images:
- docker_image_rtgtools:   ${docker_image_rtgtools}
"""

process rtgtools_vcfstats {
    container docker_image_rtgtools

    publishDir params.output_dir,
        pattern: "*_stats.txt",
        mode: "copy",
        saveAs: { "rtgtools-${params.rtgtools_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "rtgtools_vcfstats/log${file(it).getName()}" }

    input:
    tuple val(patient), val(sample), path(input_bam), path(input_bam_bai), path(reference_fasta), path(reference_fasta_fai), path(exclusion_file)
    path vcf_sv_file

    output:
    path "DELLY-${params.delly_version}_${params.dataset_id}_${sample}_stats.txt"
    path ".command.*"

    """
    set -euo pipefail

    rtg vcfstats $vcf_sv_file > DELLY-${params.delly_version}_${params.dataset_id}_${sample}_stats.txt
    """
}