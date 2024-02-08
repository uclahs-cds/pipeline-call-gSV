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

    publishDir "${params.workflow_output_dir}/output",
        pattern: "*vcf.gz*",
        mode: "copy"

    publishDir "${params.workflow_output_dir}/QC",
        pattern: "*Stats*",
        mode: "copy",
        saveAs: { "${params.output_filename}_${file(it).getName()}" }

    publishDir "${params.log_output_dir}/process-log",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process.replace(':', '/')}/log${file(it).getName()}" }

    input:
        tuple val(bam_sample_name), path(input_bam), path(input_bam_bai)
        path(reference_fasta)
        path(reference_fasta_fai)

    output:
        path("${params.output_filename}_candidateSmallIndels.vcf.gz"), emit: vcf_small_indel_sv_file
        path("${params.output_filename}_candidateSmallIndels.vcf.gz.tbi"), emit: vcf_small_indel_sv_tbi
        path("${params.output_filename}_diploidSV.vcf.gz"), emit: vcf_diploid_sv_file
        path("${params.output_filename}_diploidSV.vcf.gz.tbi"), emit: vcf_diploid_sv_tbi
        path("${params.output_filename}_candidateSV.vcf.gz"), emit: vcf_candidate_sv_file
        path("${params.output_filename}_candidateSV.vcf.gz.tbi"), emit: vcf_candidate_sv_tbi
        path "*Stats*"
        path ".command.*"
        val bam_sample_name, emit: bam_sample_name

    script:
    """
    set -euo pipefail

    configManta.py \
        --normalBam $input_bam \
        --referenceFasta $reference_fasta \
        --runDir MantaWorkflow
    MantaWorkflow/runWorkflow.py

    # re-name Manta outputs based on output file name standardization - `params.output_filename`
    for variant_file in `ls MantaWorkflow/results/variants/*`
        do
            variant_file_base_name=`basename \${variant_file}`
            mv \${variant_file} ./${params.output_filename}_\${variant_file_base_name}
        done

    mv MantaWorkflow/results/stats/* ./
    """
    }
