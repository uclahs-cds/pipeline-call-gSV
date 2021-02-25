#!/usr/bin/env nextflow

def docker_image_delly = "blcdsdockerregistry/call-gsv:delly-${params.delly_version}"

log.info """\
------------------------------------
             D E L L Y
------------------------------------
Docker Images:
- docker_image_delly:   ${docker_image_delly}
"""

process delly_call_sv {
    container docker_image_delly

    publishDir params.output_dir,
        enabled: params.save_intermediate_files,
        pattern: "*.bcf",
        mode: "copy"

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "delly_call_sv/log${file(it).getName()}" }

    input:
    tuple val(patient), val(sample), path(input_bam), path(input_bam_bai), path(reference_fasta), path(reference_fasta_fai), path(exclusion_file)


    output:
    path "DELLY-${params.delly_version}_${params.dataset_id}_${sample}.bcf", emit: bcf_sv_file
    path ".command.*"

    """
    set -euo pipefail
    delly \
        call \
        --exclude   $exclusion_file \
        --genome    $reference_fasta \
        --outfile   DELLY-${params.delly_version}_${params.dataset_id}_${sample}.bcf \
        --map-qual ${params.map_qual} \
        $input_bam
    """
}