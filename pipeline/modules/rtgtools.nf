#!/usr/bin/env nextflow

def docker_image_rtgtools = "blcdsdockerregistry/call-gsv:rtgtools-3.11"

log.info """\
------------------------------------
          R T G T O O L S
------------------------------------
Docker Images:
- docker_image_rtgtools:   ${docker_image_rtgtools}
"""

process rtgtools_vcfstats {
	container docker_image_rtgtools
	publishDir params.output_dir, mode: "copy"

	input:
	tuple val(patient), val(sample), path(input_bam), path(input_bam_bai), path(reference_fasta), path(reference_fasta_fai), path(exclusion_file)
	path vcf_sv_file

	output:
	path "DELLY-0.8.6_${params.dataset_id}_${sample}_stats.txt"

	"""
	set -euo pipefail

	rtg vcfstats $vcf_sv_file > DELLY-0.8.6_${params.dataset_id}_${sample}_stats.txt
	"""
}