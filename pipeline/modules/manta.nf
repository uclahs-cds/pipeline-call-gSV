#!/usr/bin/env nextflow

def docker_image_manta = "blcdsdockerregistry/manta:${params.manta_version}"

log.info """\
------------------------------------
             M A N T A
------------------------------------
Docker Images:
- docker_image_manta:   ${docker_image_manta}
"""

process call_gSV_Manta {
    container docker_image_manta

    publishDir params.output_dir,
        pattern: "MantaWorkflow/results",
        mode: "copy",
        saveAs: { "Manta-${params.manta_version}/${file(it).getName()}" }

    publishDir params.output_log_dir,
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "call_gSV_Manta/${bam_sample_name}.log${file(it).getName()}" }

    input:
    tuple val(patient), val(bam_sample_name), path(input_bam), path(input_bam_bai), val(mode)
    path(reference_fasta)
    path(reference_fasta_fai)


    output:
    path("MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz"), emit: vcf_small_indel_sv_file
    path("MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz.tbi")
    path("MantaWorkflow/results/variants/diploidSV.vcf.gz"), emit: vcf_diploid_sv_file
    path("MantaWorkflow/results/variants/diploidSV.vcf.gz.tbi")
    path("MantaWorkflow/results/variants/candidateSV.vcf.gz"), emit: vcf_candidate_sv_file
    path("MantaWorkflow/results/variants/candidateSV.vcf.gz.tbi")
    //path "MANTA-${params.manta_version}_SV_${params.dataset_id}_${bam_sample_name}.vcf.gz", emit: vcf_sv_file
    //path "MANTA-${params.manta_version}_SV_${params.dataset_id}_${bam_sample_name}.vcf.gz.tbi"
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