nextflow.enable.dsl=2

include { convert_BCF2VCF_BCFtools } from "../external/pipeline-Nextflow-module/modules/BCFtools/convert_BCF2VCF_BCFtools/main.nf" addParams(
    options: [
        docker_image: params.docker_image_bcftools,
        main_process: "DELLY-${params.delly_version}",
        output_dir: params.workflow_output_dir,
        log_output_dir: "${params.log_output_dir}",
        ]
    )
include { index_VCF_tabix } from "../external/pipeline-Nextflow-module/modules/common/index_VCF_tabix/main.nf" addParams(
    options: [
        docker_image: params.docker_image_bcftools,
        output_dir: params.workflow_output_dir,
        log_output_dir: "${params.log_output_dir}/process-log/DELLY-${params.delly_version}",
        ]
    )

workflow convert_BCF2VCF {
    take:
    delly_bcf_channel

    main:
    convert_BCF2VCF_BCFtools(
        sample,
        bcf_file,
        bcf_index
        )

    index_VCF_tabix(
        sample,
        convert_BCF2VCF_BCFtools.out.vcf
        )

    emit:
    gzvcf = index_VCF_tabix.out.index_out.map{ it -> ["${it[1]}"] }
    idx = index_VCF_tabix.out.index_out.map{ it -> ["${it[2]}"] }
}