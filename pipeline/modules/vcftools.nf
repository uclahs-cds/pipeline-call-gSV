#!/usr/bin/env nextflow

def docker_image_vcftools = "blcdsdockerregistry/vcftools:0.1.16"

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
	tuple val(patient), val(sample), path(input_bam), path(input_bam_bai), path(reference_fasta), path(reference_fasta_fai), path(exclusion_file)
	path vcf_sv_file

	output:
	path "DELLY-0.8.6_${params.dataset_id}_${sample}_validation.txt"

	"""
	set -euo pipefail

	vcf-validator -d -u $vcf_sv_file > DELLY-0.8.6_${params.dataset_id}_${sample}_validation.txt;
	"""
}