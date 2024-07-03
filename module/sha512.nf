#!/usr/bin/env nextflow

log.info """\
------------------------------------
          S H A - 5 1 2
------------------------------------
Docker Images:
- docker_image_validate: ${params.docker_image_validate}
"""

process run_sha512sum {
    container params.docker_image_validate

    publishDir "${params.workflow_output_dir}/output",
        pattern: "*.sha512",
        mode: "copy"

    ext log_dir_suffix: { "/${task.process.split(':')[-1]}-${task.index}" }

    input:
        path input_checksum_file

    output:
        path "${input_checksum_file}.sha512"

    """
        set -euo pipefail
        sha512sum ${input_checksum_file} > ${input_checksum_file}.sha512
    """
    }
