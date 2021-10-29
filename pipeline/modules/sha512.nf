#!/usr/bin/env nextflow

log.info """\
------------------------------------
          S H A - 5 1 2
------------------------------------
Docker Images:
- docker_image_validate: ${params.docker_image_validate}
"""

process run_sha512sum_Manta {
    container params.docker_image_validate

    publishDir "${params.output_dir}/${params.docker_image_manta.split("/")[1].replace(':', '-').toUpperCase()}/intermediate/${task.process.replace(':', '/')}",
        pattern: "*.bcf.sha512",
        mode: "copy"

    publishDir "$params.log_output_dir/process-log",
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
        python -m validate -t sha512-gen $input_checksum_file > ${input_checksum_file}.sha512
    """
    }

process run_sha512sum_Delly {
    container params.docker_image_validate

    publishDir "${params.output_dir}/${params.docker_image_delly.split("/")[1].replace(':', '-').toUpperCase()}/intermediate/${task.process.replace(':', '/')}",
        pattern: "*.bcf.sha512",
        mode: "copy"

    publishDir "$params.log_output_dir/process-log",
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
        python -m validate -t sha512-gen $input_checksum_file > ${input_checksum_file}.sha512
    """
    }