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

    publishDir "$params.output_dir/${params.docker_image_manta.split("/")[-1].replace(':', '-').capitalize()}/output",
        pattern: "*vcf.gz*",
        mode: "copy"

    publishDir "$params.output_dir/${params.docker_image_manta.split("/")[-1].replace(':', '-').capitalize()}/QC",
        pattern: "*Stats*",
        mode: "copy"

    publishDir "$params.log_output_dir/process-log/${params.docker_image_manta.split("/")[-1].replace(':', '-').capitalize()}",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}-${task.index}/log${file(it).getName()}" }

    input:
        tuple val(bam_sample_name), path(input_bam), path(input_bam_bai)
        path(reference_fasta)
        path(reference_fasta_fai)

    output:
        path("MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz"), emit: vcf_small_indel_sv_file
        path("MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz.tbi"), emit: vcf_small_indel_sv_tbi
        path("MantaWorkflow/results/variants/diploidSV.vcf.gz"), emit: vcf_diploid_sv_file
        path("MantaWorkflow/results/variants/diploidSV.vcf.gz.tbi"), emit: vcf_diploid_sv_tbi
        path("MantaWorkflow/results/variants/candidateSV.vcf.gz"), emit: vcf_candidate_sv_file
        path("MantaWorkflow/results/variants/candidateSV.vcf.gz.tbi"), emit: vcf_candidate_sv_tbi
        path "*vcf.gz*"
        path "*Stats*"
        path ".command.*"
        val bam_sample_name, emit: bam_sample_name
    """
    set -euo pipefail
    configManta.py \
        --normalBam $input_bam \
        --referenceFasta $reference_fasta \
        --runDir MantaWorkflow
    MantaWorkflow/runWorkflow.py

    cp MantaWorkflow/results/variants/* ./
    cp MantaWorkflow/results/stats/* ./
    """
    }
