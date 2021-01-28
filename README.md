# Call germline Structural Variant Pipeline

- [call-gSV](#pipeline-name)
  - [Overview](#overview)
  - [How To Run](#how-to-run)
  - [Flow Diagram](#flow-diagram)
  - [Pipeline Steps](#pipeline-steps)
    - [1. Calling Structural Variants](#1-calling-structural-variants)
    - [2. Check Output Quality](#2-check-output-quality)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Testing and Validation](#testing-and-validation)
    - [Test Data Set](#test-data-set)
    - [Performance Validation](#performance-validation)
    - [Quality Check Result Comparison](#quality-check-result-comparison)    
    - [Validation Tool](#validation-tool)
  - [References](#references)

## Overview

The call-gSV nextflow pipeline, calls structural variants utilizing [Delly](https://github.com/dellytools/delly), suitable for detecting copy-number variable deletion and tandem duplication events as well as balanced rearrangements such as inversions or reciprocal translocations and validates the output quality with [BCFtools](https://github.com/samtools/bcftools).  The pipeline has been engineered to run in a 4 layer stack in a cloud-based scalable environment of CycleCloud, Slurm, Nextflow and Docker.  Additionally it has been validated with the SMC-HET dataset and reference GRCh38, where paired-end fastq's were created with BAM Surgeon.

The pipeline should be run **WITH A SINGLE SAMPLE AT A TIME.**  Otherwise resource allocation and Nextflow errors could cause the pipeline to fail.

<b><i>Developer's Notes:</i></b>

> TBD - We performed a benchmarking on our SLURM cluster.  Using XX CPUs for structural variant calling (`delly_number_of_cpus`) gives the best performance.

---

## How To Run

Pipelines should be run **WITH A SINGLE SAMPLE AT TIME**. Otherwise resource allocation and Nextflow errors could cause the pipeline to fail

1. Make sure the pipeline is already downloaded to yoru machine. You can either download the stable release or the dev version by cloning the repo.  

2. Create a config file for input, output, and parameters. An example can be found [here](pipeline/config/call-gSV.config). See [Inputs](#Inputs) for description of each variables in the config file.

3. Update the input csv. See [Inputs](#Inputs) for the columns needed. All columns must exist in order to run the pipeline. An example can be found [here](pipeline/inputs/call-gSV.inputs.csv). The example csv is a single-lane sample. All records must have the same value in the **sample** column.
 
4. See the submission script, [here](https://github.com/uclahs-cds/tool-submit-nf), to submit your pipeline

---

## Flow Diagram

A directed acyclic graph of your pipeline.

![call-gSV flow diagram](call-gSV-flowchart-diagram.drawio.svg?raw=true)

---

## Pipeline Steps

### 1. Calling Structural Variants

The first step of the pipeline utilizes an input BAM file and leverages [Delly](https://github.com/dellytools/delly) which combines short-range and long-range paired-end mapping and split-read analysis for the discovery of balanced and unbalanced structural variants at single-nucleotide breakbpoint resolution (deletions, tandem duplications, inversions and translocations), to call structural variants, annotate and merge calls into a single bcf file. A default exclude map of Delly can be incorporated as an input which removes the telomeric and centromeric regions of all human chromosomes since these regions cannot be accurately analyzed with short-read data.

### 2. Check Output Quality

Running vcf-validate from [VCFTools](https://vcftools.github.io/perl_module.html#vcf-validator) and vcfstats from [RTGtools](https://cdn.rawgit.com/RealTimeGenomics/rtg-tools/master/installer/resources/tools/RTGOperationsManual/rtg_command_reference.html#vcfstats) generates summary statistics that can be viewed and evaluated in preparation for downstream cohort-wide re-calling and re-genotyping.

---

## Inputs

### Input CSV Fields

>The input csv should have all columns below and in the same order. An example of an input csv can be found [here](pipeline/inputs/call-gSV.inputs.csv)

| Field | Type | Description |
|:------|:-----|:------------|
| index -? | integer | The index of input fastq pairs, starting from 1 - confirm if needed |
| read_group_identifier | string | The read group each read blongs to. This is concatenated with the `lane` column (see below) and then passed to the `ID` field of the final BAM. No white space is allowed. For more detail see [here](https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups). |
| sequencing_center | string | The sequencing center where the data were produced. This is passed to the `CN` field of the final BAM. No white space is allowed. For more detail see [here](https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups) |
| library_identifier | string | The library identifier to be passed to the `LB` field of the final BAM. No white space is allowed. For more detail see [here](https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups) |
| platform_technology | string | The platform or technology used to produce the reads. This is passed to the `PL` field of the final BAM. No white space is allowed. For more detail see [here](https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups) |
| platform_unit | string | The platform unit to be passed to the `PU` field of the final BAM. No white space is allowed. For more detail see [here](https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups) |
| sample | string | The sample name to be passed to the `SM` field of the final BAM. No white space is allowed. For more detail see [here](https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups) |
| lane | string | The lane name or index. This is concatenated with the `read_group_identifier` column (see above) and then passed to the `ID` field of the final BAM. No white space is allowed. For more detail see [here](https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups) |
| sorted_bam | path | Absolute path to the BAM file for the sample. |


### Execute Config File Settings

| Config File | Available Node cpus / memory | Designated Process 1; cpus / memory | Designated Process 2; cpus / memory |
|:------------|:---------|:-------------------------|:-------------------------|
| `lowmem.config` | 2 / 3 GB | delly_call_sv; 1 / 3.GB | validate_file; 1 / 1.GB |
| `midmem.config` | 72 / 136.8 GB | delly_call_sv; 71 / 130.GB | validate_file; 1 / 1.GB |
| `execute.config` | 64 / 950 GB | delly_call_sv; 1 / 3.GB | validate_file; 1 / 1.GB |

### Methods Config File Parameters

| Input Parameter | Required | Type | Description |
|:----------------|:---------|:-----|:------------|
| `dataset_id` | yes | string | Boutros lab dataset id. |
| `blcds_registered_dataset` | yes | boolean | Affirms if dataset is registered in the Boutros Lab Data registry. Default value is false. |
| `sge_scheduler` | yes | boolean | Affirms whether job will be executed on the SGE cluster. Default value is false. |
| `sample_name` | yes | string | The sample name. This is ignored if the output files are directly saved to the Boutros Lab data storage registry, by setting `blcds_registered_dataset_output = true` |
| `input_bam` | yes | path | Absolute path to the input `bam` file which should be aligned and sorted |
| `input_bam_index` | yes | path | Absolute path to the input bam index. |
| `reference_fasta` | yes | path | Absolute path to the reference genome `fasta` file. The reference genome is used by Delly for structural variant calling. |
| `exclusion_file` | yes | path | Absolute path to the delly reference genome `exclusion` file utilized to remove suggested regions for structural variant calling. |
| `run_qc` | yes | boolean | Optional parameter to indicate whether subsequent quality checks should be run. Default value is false. |
| `output_dir` | yes | path | Absolute path to the directory where the output files to be saved. |
| `output_log_dir` | yes | path | Absolute path to the directory where the output log files to be saved. |
| `temp_dir` | yes | path | Absolute path to the directory where the nextflow's intermediate files are saved. |
| `reference_genome_version` | no | string | The genome build version. This is only used when the output files are directly saved to the Boutros Lab data storage registry, by setting `blcds_registered_dataset_output = true`. |
| `temp_dir` | yes | path | Absolute path to the directory where the nextflow's intermediate files are saved. |
| `save_intermediate_files` | yes | boolean | Save intermediate files. If yes, not only the final BAM, but also the unmerged, unsorted, and duplicates unmarked BAM files will also be saved. |
| `cache_intermediate_pipeline_steps` | yes | boolean | Enable cahcing to resume pipeline and the end of the last successful process completion when a pipeline fails (if true the default submission script must be modified). |
| `max_number_of_parallel_jobs` | yes | int | The maximum number of jobs or steps of the pipeline that can be ran in parallel. |
| `bwa_mem_number_of_cpus` | no | int | Number of cores to use for BWA-MEM2. If not set, this will be calculated to ensure at least 2.5Gb memory per core. |
| `blcds_registered_dataset_input` | yes | boolean | Input BAMss are from the Boutros Lab data registry. |
| `blcds_registered_dataset_output` | yes | boolean | Enable saving final files and logging files directory to the Boutros Lab Data registry. |
| `blcds_cluster_slurm` | no | boolean | Pipeline is to run on the Slurm cluster. Set to `false` if it is to run on the SGE cluster. This is used only when `blcds_registered_dataset_output = true` and `blcds_registered_dataset_input = false`. It is also ignored if `blcds_mount_dir` is set. |
| `blcds_disease_id` | no | string | The registered disease ID of this dataset from the Boutros Lab data registry. Ignored if `blcds_registered_data_input = true` or `blcds_registered_output = false` |
| `blcds_dataset_id` | no | string | The registered dataset ID of this dataset from the Boutros Lab data registry. Ignored if `blcds_registered_data_input = true` or `blcds_registered_output = false` |
| `blcds_patient_id` | no | string | The registered patient ID of this sample from the Boutros Lab data registry. Ignored if `blcds_registered_data_input = true` or `blcds_registered_output = false` |
| `blcds_sample_id` | no | string | The registered sample ID from the Boutros Lab data registry. Ignored if `blcds_registered_data_input = true` or `blcds_registered_output = false` |
| `blcds_mount_dir` | no | string | The directory that the storage is mounted to (e.g., /hot, /data). |

---

## Outputs

| Output | Required | Description |
|:-------|:---------|:------------|
| `.bcf` | yes | Binary VCF output format with structural variants if found. |
| `.bcf.csi` | yes | CSI-format index for BAM files. |
| `.validate.txt` | yes | output file from vcf-validator. |
| `.stats.txt` | yes | output file from rtgtools. |
| `report.html`, `timeline.html` and `trace.txt` | yes | A Nextflowreport, timeline and trace files. |
| `log.command.*` | yes | Process specific logging files created by nextflow. |

---

## Testing and Validation

### Test Data Set

Testing was performed leveraging aligned and sorted bams generated using bwa-mem2-2.1 against reference GRCh38:

* **amini:**    BWA-MEM2-2.1_TEST0000000_TWGSAMIN000001-T002-S02-F.bam and bai
* **apartial:** BWA-MEM2-2.1_TEST0000000_TWGSAPRT000001-T001-S01-F.bam and bai
* **afull:**    a-full-CPCG0196-B1.bam and bai

### Performance Validation

|Test Case | Node Type | Duration | Max CPU | Max Memory |
|:---------|:----------|:---------|:--------|:-----------|
| amini | lowmem | XX hours | XX CPU | XX Memory |
| apartial | midmem | XX hours | XX CPU | XX Memory |
| afull | midmem | XX hours | XX CPU | XX Memory |

### Quality Check Result Comparison
|Metric | amini | apartial | afull | Source |
|:------|:------|:---------|:------|:-------|
| Failed Filters | 3 | TBD | 44991 | `.stats.txt` |
| Passed Filters | 28 | TBD | 18257 | `.stats.txt` |
| Structural variant breakends | 2 | TBD | 1124 | `.stats.txt` |
| Symbolic structural variants | 24 | TBD | 12500 | `.stats.txt` |
| Total Het/Hom ratio | 3.33 (20/6) | TBD | 2.37 (9580/4044) | `.stats.txt` |
| Breakend Het/Hom ratio | 1.00 (1/1) | TBD | 13.41 (1046/78) | `.stats.txt` |
| Symbolic SV Het/Hom ratio | 3.80 (19/5) | TBD | 2.15 (8534/3966) | `.stats.txt` |
| Duplicate entries | chr21:42043166 | TBD  | chr1:16050024 | `.validate.txt` |

### Validation Tool

Included is a template for validating your input files. For more information on the tool check out: https://github.com/uclahs-cds/tool-validate-nf

---

## References

1. [Rausch T, Zichner T, Schlattl A, Stütz AM, Benes V, Korbel JO. DELLY: structural variant discovery by integrated paired-end and split-read analysis. Bioinformatics. 2012;28(18):i333-i339. doi:10.1093/bioinformatics/bts378](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3436805/)
2. [VCFtools - vcf-validator](https://vcftools.github.io/perl_module.html#vcf-validator)
3. [Real Time Genomics RTG Tools Operations Manual - vcfstats](https://cdn.rawgit.com/RealTimeGenomics/rtg-tools/master/installer/resources/tools/RTGOperationsManual/rtg_command_reference.html#vcfstats)
4. [Boutros Lab -CallSV Quality Control pipeline]()
5. [https://tobiasrausch.com/courses/vc/sv/#introduction](https://tobiasrausch.com/courses/vc/sv/#introduction)
