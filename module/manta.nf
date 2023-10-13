#!/usr/bin/env nextflow

log.info """\
------------------------------------
             M A N T A
------------------------------------
Docker Images:
- docker_image_manta: ${params.docker_image_manta}
"""

include { generate_standard_filename } from '../external/pipeline-Nextflow-module/modules/common/generate_standardized_filename/main.nf'

process call_gSV_Manta {
    container params.docker_image_manta

    publishDir "$params.output_dir_base/${params.docker_image_manta.split("/")[-1].replace(':', '-').capitalize()}/output",
        pattern: "*vcf.gz*",
        mode: "copy"

    publishDir "$params.output_dir_base/${params.docker_image_manta.split("/")[-1].replace(':', '-').capitalize()}/QC",
        pattern: "*Stats*",
        mode: "copy",
        saveAs: { "${output_filename}_${file(it).getName()}" }

    publishDir "$params.log_output_dir/process-log/${params.docker_image_manta.split("/")[-1].replace(':', '-').capitalize()}",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}-${task.index}/log${file(it).getName()}" }

    input:
        tuple val(bam_sample_name), path(input_bam), path(input_bam_bai)
        path(reference_fasta)
        path(reference_fasta_fai)

    output:
        path("${output_filename}_candidateSmallIndels.vcf.gz"), emit: vcf_small_indel_sv_file
        path("${output_filename}_candidateSmallIndels.vcf.gz.tbi"), emit: vcf_small_indel_sv_tbi
        path("${output_filename}_diploidSV.vcf.gz"), emit: vcf_diploid_sv_file
        path("${output_filename}_diploidSV.vcf.gz.tbi"), emit: vcf_diploid_sv_tbi
        path("${output_filename}_candidateSV.vcf.gz"), emit: vcf_candidate_sv_file
        path("${output_filename}_candidateSV.vcf.gz.tbi"), emit: vcf_candidate_sv_tbi
        path "*Stats*"
        path ".command.*"
        val bam_sample_name, emit: bam_sample_name

    script:
    output_filename = generate_standard_filename(
        "Manta-${params.manta_version}",
        params.dataset_id,
        bam_sample_name,
        [:]
        )

    """
    set -euo pipefail

    configManta.py \
        --normalBam $input_bam \
        --referenceFasta $reference_fasta \
        --runDir MantaWorkflow
    MantaWorkflow/runWorkflow.py

    # re-name Manta outputs based on output file name standardization - `output_filename`
    for variant_file in `ls MantaWorkflow/results/variants/*`
        do
            variant_file_base_name=`basename \${variant_file}`
            mv \${variant_file} ./${output_filename}_\${variant_file_base_name}
        done

    mv MantaWorkflow/results/stats/* ./
    """
    }
