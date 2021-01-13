#!/usr/bin/env nextflow

def docker_image_rtgtools = "realtimegenomics/rtg-tools:3.11"

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
	path vcf_sv_file

	output:
	path "delly_sv_${params.sample_name}_stats.txt"

	"""
	set -euo pipefail

	rtg vcfstats $vcf_sv_file > delly_sv_${params.sample_name}_stats.txt
	"""
}