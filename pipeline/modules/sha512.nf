#!/usr/bin/env nextflow

def docker_image_sha512 = "blcdsdockerregistry/call-gsv:sha512-${params.sha512_version}"

log.info """\
------------------------------------
          S H A - 5 1 2
------------------------------------
Docker Images:
- docker_image_sha512:   ${docker_image_sha512}
"""

process generate_sha512 {
    container docker_image_sha512

    publishDir params.output_dir,
        pattern: "*.vcf.sha512",
        mode: "copy",
        saveAs: { "bcftools-${params.bcftools_version}/${file(it).getName()}" }

    publishDir params.output_dir,
        pattern: "*.bcf.sha512",
        mode: "copy",
        saveAs: { "delly-${params.delly_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "generate_sha512/${input_checksum_file}.log${file(it).getName()}" }

    input:
    path input_checksum_file

    output:
    path "${input_checksum_file}.sha512"
    path ".command.*"

    """
    set -euo pipefail

    sha512sum $input_checksum_file > ${input_checksum_file}.sha512
    """
}