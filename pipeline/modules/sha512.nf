#!/usr/bin/env nextflow

def docker_image_sha512 = "blcdsdockerregistry/call-gsv:sha512-${params.sha512_version}"

log.info """\
------------------------------------
          S H A - 5 1 2
------------------------------------
Docker Images:
- docker_image_sha512:   ${docker_image_sha512}
"""

process run_sha512sum {
    container docker_image_sha512

    publishDir params.output_dir,
        pattern: "*.vcf.sha512",
        mode: "copy",
        saveAs: { "BCFtools-${params.bcftools_version}/${file(it).getName()}" }

    publishDir params.output_dir,
        pattern: "*.bcf.sha512",
        mode: "copy",
        saveAs: { "Delly-${params.delly_version}/${file(it).getName()}" }

    publishDir params.output_dir,
        pattern: "*.vcf.gz*.sha512",
        mode: "copy",
        saveAs: { "Manta-${params.manta_version}/results/variants/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "run_sha512sum/${input_checksum_file}.log${file(it).getName()}" }

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