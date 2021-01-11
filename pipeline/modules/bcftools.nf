#!/usr/bin/env nextflow

def docker_image_bcftools = "blcdsdockerregistry/call-gsv:bcftools-1.11"

log.info """\
------------------------------------
          B C F T O O L S
------------------------------------
Docker Images:
- docker_image_bcftools:   ${docker_image_bcftools}
"""

process bcftools_vcf {
	container docker_image_bcftools
	publishDir params.output_dir, mode: "copy"

	input:
	path bcf_sv_file

	output:
	path "delly_sv_${params.sample_name}.vcf" emit: vcf_sv_file

	"""
	set -euo pipefail
	bcftools \
		view \
		$bcf_sv_file \
		--output delly_sv_${params.sample_name}.vcf
	"""
}