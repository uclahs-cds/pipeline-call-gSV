#!/usr/bin/env nextflow

def docker_image_validation = "blcdsdockerregistry/validate:${params.validate_version}"

log.info """\
------------------------------------
         V A L I D A T I O N
------------------------------------
Docker Images:
- docker_image_validation: ${docker_image_validation}
"""

process run_validate {
    container docker_image_validation

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "run_validate/${file_to_validate}.log${file(it).getName()}" }

    input:
    path(file_to_validate)

    output:
    path ".command.*"

    """
    set -euo pipefail
    python -m validate -t file-input ${file_to_validate}
    """
}
