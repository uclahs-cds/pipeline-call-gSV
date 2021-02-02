#!/usr/bin/env nextflow

def docker_image_delly = "blcdsdockerregistry/call-gsv:delly-0.8.6"

log.info """\
------------------------------------
             D E L L Y
------------------------------------
Docker Images:
- docker_image_delly:   ${docker_image_delly}
"""

process delly_call_sv {
	container docker_image_delly
	publishDir params.output_dir, enabled: params.save_intermediate_files, mode: "copy"

	input:
	path exclusion_file
	path reference_fasta
	tuple path(input_bam), path(input_bam_index)

	output:
	path "DELLY-0.8.6_${params.dataset_id}_${params.sample_name}.bcf", emit: bcf_sv_file

	"""
	set -euo pipefail
	delly \
		call \
		--exclude   $exclusion_file \
		--genome    $reference_fasta \
		--outfile   DELLY-0.8.6_${params.dataset_id}_${params.sample_name}.bcf \
		--map-qual 20 \
		$input_bam
	"""
}