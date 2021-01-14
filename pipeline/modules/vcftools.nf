#!/usr/bin/env nextflow

def docker_image_vcftools = "biocontainers/vcftools:v0.1.16-1-deb_cv1"

log.info """\
------------------------------------
          V C F T O O L S
------------------------------------
Docker Images:
- docker_image_vcftools:   ${docker_image_vcftools}
"""

process vcftools_validator {
	container docker_image_vcftools
	publishDir params.output_dir, mode: "copy"

	input:
	path vcf_sv_file

	output:
	path "delly_sv_${params.sample_name}_validation.txt"

	"""
	set -euo pipefail

	vcf-validator -d -u $vcf_sv_file > delly_sv_${params.sample_name}_validation.txt;
	"""
}