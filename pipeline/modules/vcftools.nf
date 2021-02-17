#!/usr/bin/env nextflow

def docker_image_vcftools = "blcdsdockerregistry/vcftools:${params.vcftools_version}"

log.info """\
------------------------------------
          V C F T O O L S
------------------------------------
Docker Images:
- docker_image_vcftools:   ${docker_image_vcftools}
"""

process vcftools_validator {
	container docker_image_vcftools

	publishDir params.output_dir,
		pattern: "*_validation.txt",
		mode: "copy"

	publishDir params.output_log_dir,
		pattern: ".command.*",
		mode: "copy",
		saveAs: { "vcftools_validator/log${file(it).getName()}" }

	input:
	tuple val(patient), val(sample), path(input_bam), path(input_bam_bai), path(reference_fasta), path(reference_fasta_fai), path(exclusion_file)
	path vcf_sv_file

	output:
	path "DELLY-${params.delly_version}_${params.dataset_id}_${sample}_validation.txt"
	path ".command.*"

	"""
	set -euo pipefail

	vcf-validator -d -u $vcf_sv_file > DELLY-${params.delly_version}_${params.dataset_id}_${sample}_validation.txt;
	"""
}