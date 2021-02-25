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
        pattern: "*.sha512",
        mode: "copy"

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "generate_sha512/log${file(it).getName()}" }

    input:
    path vcf_sv_file

    output:
    path "${vcf_sv_file.getName()}.sha512"
    path ".command.*"

    """
    set -euo pipefail

    sha512sum $vcf_sv_file > ${vcf_sv_file.getName()}.sha512
    """
}