#!/usr/bin/env nextflow

log.info """\
------------------------------------
             M A N T A
------------------------------------
Docker Images:
- docker_image_manta: ${params.docker_image_manta}
"""

process call_gSV_Manta {
    container params.docker_image_manta

    publishDir "$params.output_dir/${params.docker_image_manta.split("/")[1].replace(':', '-').capitalize()}/output",
        pattern: "MantaWorkflow/results",
        mode: "copy"

    publishDir "$params.log_output_dir/process-log",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}-${task.index}/log${file(it).getName()}" }

    input:
        tuple val(patient), val(bam_sample_name), path(input_bam), path(input_bam_bai)
        path(reference_fasta)
        path(reference_fasta_fai)

    output:
        path("MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz"), emit: vcf_small_indel_sv_file
        path("MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz.tbi")
        path("MantaWorkflow/results/variants/diploidSV.vcf.gz"), emit: vcf_diploid_sv_file
        path("MantaWorkflow/results/variants/diploidSV.vcf.gz.tbi")
        path("MantaWorkflow/results/variants/candidateSV.vcf.gz"), emit: vcf_candidate_sv_file
        path("MantaWorkflow/results/variants/candidateSV.vcf.gz.tbi")
        path "MantaWorkflow/results"
        path ".command.*"
        val bam_sample_name, emit: bam_sample_name
    """
    set -euo pipefail
    configManta.py \
        --normalBam $input_bam \
        --referenceFasta $reference_fasta \
        --runDir MantaWorkflow
    MantaWorkflow/runWorkflow.py
    """
    }