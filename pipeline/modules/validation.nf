#!/usr/bin/env nextflow

def docker_image_validation = "blcdsdockerregistry/validate:${params.validate_version}"

log.info """\
------------------------------------
         V A L I D A T I O N
------------------------------------
Docker Images:
- docker_image_validation: ${docker_image_validation}
"""

process validate_file {
    container docker_image_validation

    input:
    path(file_to_validate)

    """
    set -euo pipefail
    python -m validate -t file-input ${file_to_validate}
    """
}