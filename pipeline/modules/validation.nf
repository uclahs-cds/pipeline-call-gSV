def docker_image_validation = "blcdsdockerregistry/validate:1.0.0"

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
    tuple path(input_bam), path(input_bam_bai)

    """
    set -euo pipefail
    python -m validate -t file-input ${input_bam}
    """
}