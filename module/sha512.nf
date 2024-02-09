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

    publishDir "${params.log_output_dir}/process-log",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process}/${task.process}-${task.index}/log${file(it).getName()}" }

    input:
        path input_checksum_file

    output:
        path "${input_checksum_file}.sha512"
        path ".command.*"

    """
        set -euo pipefail
        sha512sum ${input_checksum_file} > ${input_checksum_file}.sha512
    """
    }
