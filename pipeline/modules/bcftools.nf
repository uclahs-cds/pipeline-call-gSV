#!/usr/bin/env nextflow

def docker_image_bcftools = "blcdsdockerregistry/call-gsv:bcftools-${params.bcftools_version}"

log.info """\
------------------------------------
          B C F T O O L S
------------------------------------
Docker Images:
- docker_image_bcftools:   ${docker_image_bcftools}
"""

process bcftools_vcf {
	container docker_image_bcftools

	publishDir params.output_dir,
		pattern: "*.vcf",
		mode: "copy"

	publishDir params.output_log_dir,
		pattern: ".command.*",
		mode: "copy",
		saveAs: { "bcftools_vcf/log${file(it).getName()}" }

	input:
	tuple val(patient), val(sample), path(input_bam), path(input_bam_bai), path(reference_fasta), path(reference_fasta_fai), path(exclusion_file)
	path bcf_sv_file

	output:
	path "DELLY-${params.delly_version}_${params.dataset_id}_${sample}.vcf", emit: vcf_sv_file
	path ".command.*"

	"""
	set -euo pipefail
	bcftools \
		view \
		$bcf_sv_file \
		--output DELLY-${params.delly_version}_${params.dataset_id}_${sample}.vcf
	"""
}