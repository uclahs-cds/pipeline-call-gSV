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
	//path exclusion_file
	//path reference_fasta
	//tuple path(input_bam), path(input_bam_index)
	tuple patient, sample, path(input-bam), path(input-bai), path(ref-fa), path(ref-fai), path(exclusion-tsv)

	output:
	//path "DELLY-0.8.6_${params.dataset_id}_${params.sample_name}.bcf", emit: bcf_sv_file
	path "DELLY-0.8.6_${params.dataset_id}_${sample}.bcf", emit: bcf_sv_file

	"""
	set -euo pipefail
	delly \
		call \
		--exclude   $exclusion-tsv \
		--genome    $ref-fa \
		--outfile   DELLY-0.8.6_${params.dataset_id}_${sample}.bcf \
		--map-qual 20 \
		$input-bam
	"""
}