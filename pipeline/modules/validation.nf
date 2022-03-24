#!/usr/bin/env nextflow

log.info """\
------------------------------------
         V A L I D A T I O N
------------------------------------
Docker Images:
- docker_image_validate: ${params.docker_image_validate}
"""

process run_validate {
    container params.docker_image_validate

    publishDir "${params.output_dir}/${params.docker_image_delly.split("/")[1].replace(':', '-').toUpperCase()}/validation/${task.process.replace(':', '/')}",
        pattern: "input-validation.txt",
        mode: "copy"

    publishDir "${params.log_output_dir}/process-log/${params.docker_image_delly.split("/")[1].replace(':', '-').toUpperCase()}/validation",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}-${task.index}/log${file(it).getName()}" }

    input:
        path(file_to_validate)

    output:
        path ".command.*"
        path "input-validation.txt", emit: val_file

    script:
        """
        set -euo pipefail
        python -m validate -t file-input ${file_to_validate} > 'input-validation.txt'
        """
    }
