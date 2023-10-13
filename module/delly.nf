#!/usr/bin/env nextflow

log.info """\
------------------------------------
             D E L L Y
------------------------------------
Docker Images:
- docker_image_delly: ${params.docker_image_delly}
"""

include { generate_standard_filename } from '../external/pipeline-Nextflow-module/modules/common/generate_standardized_filename/main.nf'

output_filename = generate_standard_filename(
        "DELLY-${params.delly_version}",
        params.dataset_id,
        bam_sample_name,
        [:]
        )

process call_gSV_Delly {
    container params.docker_image_delly

    publishDir "$params.output_dir/${params.docker_image_delly.split("/")[-1].replace(':', '-').toUpperCase()}/output",
        pattern: "*.bcf*",
        mode: "copy"

    publishDir "$params.log_output_dir/process-log/${params.docker_image_delly.split("/")[-1].replace(':', '-').toUpperCase()}",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}-${task.index}/log${file(it).getName()}" }

    input:
        tuple val(bam_sample_name), path(input_bam), path(input_bam_bai)
        path(reference_fasta)
        path(reference_fasta_fai)
        path(exclusion_file)

    output:
        path "${output_filename}_${params.GSV}.bcf", emit: bcf_sv_file
        path "${output_filename}_${params.GSV}.bcf.csi", emit: bcf_sv_file_csi
        path ".command.*"
        val bam_sample_name, emit: bam_sample_name

    script:
    """
    set -euo pipefail
    delly \
        call \
        --exclude   $exclusion_file \
        --genome    $reference_fasta \
        --outfile   ${output_filename}_${params.GSV}.bcf \
        --map-qual ${params.map_qual} \
        $input_bam
    """
    }

process regenotype_gSV_Delly {
    container params.docker_image_delly

    publishDir "$params.output_dir/${params.docker_image_delly.split("/")[-1].replace(':', '-').toUpperCase()}/output",
        pattern: "*.bcf*",
        mode: "copy"

    publishDir "$params.log_output_dir/process-log/${params.docker_image_delly.split("/")[-1].replace(':', '-').toUpperCase()}",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}-${task.index}/log${file(it).getName()}" }

    input:
        tuple val(bam_sample_name), path(input_bam), path(input_bam_bai)
        path(reference_fasta)
        path(reference_fasta_fai)
        path(exclusion_file)
        path(sites)

    output:
        path "${output_filename}_${params.RGSV}.bcf", emit: regenotyped_sv_bcf
        path "${output_filename}_${params.RGSV}.bcf.csi", emit: regenotyped_sv_bcf_csi
        path ".command.*"

    script:
    """
    set -euo pipefail
    delly \
        call \
        --vcffile $sites \
        --exclude $exclusion_file \
        --genome $reference_fasta \
        --outfile "${output_filename}_${params.RGSV}.bcf" \
        --map-qual ${params.map_qual} \
        "$input_bam"
    """
    }

process call_gCNV_Delly {
    container params.docker_image_delly

    publishDir "$params.output_dir_base/${params.docker_image_delly.split("/")[-1].replace(':', '-').toUpperCase()}/output",
        pattern: "*.bcf*",
        mode: "copy"

    publishDir "$params.log_output_dir/process-log/${params.docker_image_delly.split("/")[-1].replace(':', '-').toUpperCase()}",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}-${task.index}/log${file(it).getName()}" }

    input:
        tuple val(bam_sample_name), path(input_bam), path(input_bam_bai)
        path(delly_sv_file)
        path(reference_fasta)
        path(reference_fasta_fai)
        path(mappability_file)

    output:
        path "${output_filename}_${params.GCNV}.bcf", emit: bcf_cnv_file
        path "${output_filename}_${params.GCNV}.bcf.csi", emit: bcf_cnv_file_csi
        path ".command.*"
        val bam_sample_name, emit: bam_sample_name

    script:
    """
    set -euo pipefail
    delly \
        cnv \
        --genome        $reference_fasta \
        --outfile       ${output_filename}_${params.GCNV}.bcf \
        --svfile        $delly_sv_file \
        --mappability   $mappability_file \
        $input_bam
    """
    }

process regenotype_gCNV_Delly {
    container params.docker_image_delly

    publishDir "$params.output_dir_base/${params.docker_image_delly.split("/")[-1].replace(':', '-').toUpperCase()}/output",
        pattern: "*.bcf*",
        mode: "copy"

    publishDir "$params.log_output_dir/process-log/${params.docker_image_delly.split("/")[-1].replace(':', '-').toUpperCase()}",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}-${task.index}/log${file(it).getName()}" }

    input:
        tuple val(bam_sample_name), path(input_bam), path(input_bam_bai)
        path(reference_fasta)
        path(reference_fasta_fai)
        path(mappability_file)
        path(sites)

    output:
        path "${output_filename}_${params.RGCNV}.bcf", emit: regenotyped_cnv_bcf
        path "${output_filename}_${params.RGCNV}.bcf.csi", emit: regenotyped_cnv_bcf_csi
        path ".command.*"

    script:
    """
    set -euo pipefail
    delly \
        cnv \
        -u \
        -v $sites \
        --genome $reference_fasta \
        -m $mappability_file \
        --outfile "${output_filename}_${params.RGCNV}.bcf" \
        "$input_bam"
    """
    }
