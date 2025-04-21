#!/usr/bin/env nextflow

log.info """\
------------------------------------
          C I R C O S
------------------------------------
Docker Images:
- docker_image_circlize:   ${params.docker_image_circlize}
"""

include { generate_standard_filename } from '../external/pipeline-Nextflow-module/modules/common/generate_standardized_filename/main.nf'

process plot_SV_circlize {
    container params.docker_image_circlize
    containerOptions "-v ${projectDir}:${projectDir}"

    errorStrategy 'ignore'

    publishDir "${params.workflow_output_dir}/QC",
        pattern: "*.png",
        mode: "copy"

    publishDir "${params.log_output_dir}/process-log",
        pattern: ".command.*",
        mode: "copy",
        saveAs: { "${task.process}/${task.process}-${task.index}/log${file(it).getName()}" }

    input:
        tuple(
            val(caller),
            path(vcf)
            )

    output:
        path "*.png"
        path ".command.*"

    script:
    output_filename = generate_standard_filename(
        "circlize-${params.circlize_version.split('_')[0]}",
        params.dataset_id,
        params.sample,
        [:]
        )
    """
        Rscript ${projectDir}/script/CIRCOS/final-plotting.R \
            --input.vcf "${vcf}" \
            --output.dir ./ \
            --output.type png \
            --sample.name "${params.sample}" \
            --sv.caller "${caller}" \
            --plot.title TRUE \
            --output.filename "${output_filename}.png" \
            --script.source "${projectDir}/script/CIRCOS"
    """
}
