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
    - [Human Genome Benchmarks](#human-genome-benchmarks)
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

>The input csv should have all columns below and in the same order. An example of an input csv can be found [here](pipeline/inputs/call-gSV.inputs.csv).     For more detail from the Broad Institute read more [here](https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups).

| Field | Type | Description |
|:------|:-----|:------------|
| patient | string | The patient name to be passed to final BCF. No white space is allowed. |
| sample | string | The sample name to be passed to final BCF. No white space is allowed. |
| input_bam | path | Absolute path to the BAM file for the sample. |
| input_bai | path | Absolute path to the BAI file for the sample. |
| ref-fa | path | Absolute path to the reference fasta file. |
| ref_fai | path | Absolute path to the reference fasta index file. |
| exclusion_tsv | path | Absolute path to the delly exclusion file. |

### Execute Config File Settings

| Config File | Available Node cpus / memory | Designated Process 1; cpus / memory | Designated Process 2; cpus / memory |
|:------------|:---------|:-------------------------|:-------------------------|
| `lowmem.config` | 2 / 3 GB | delly_call_sv; 1 / 3 GB | validate_file; 1 / 1 GB |
| `midmem.config` | 72 / 136.8 GB | delly_call_sv; 71 / 130 GB | validate_file; 1 / 1 GB |
| `execute.config` | 64 / 950 GB | delly_call_sv; 63 / 940 GB | validate_file; 1 / 1 GB |

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

|Test Case | Node Type | Duration | CPU Hours | Virtual Memory Usage (RAM) |
|:---------|:----------|:---------|:----------|:-------------------|
| amini | lowmem | XX hours | XX CPU | XX Memory |
| apartial | midmem | XX hours | XX CPU | XX Memory |
| afull | midmem | 5h 11m 10s | 366.8 | 10.89 GB |

### Quality Check Result Comparison

|Metric | amini | apartial | afull | Source |
|:------|:------|:---------|:------|:-------|
| PRECISE Calls | TBD | TBD | TBD | `grep -c -w  "PRECISE" filename.vcf` |
| IMPRECISE Calls | TBD | TBD | TBD | `grep -c -w  "IMPRECISE" filename.vcf` |
| Failed Filters | 3 | TBD | 44991 | `.stats.txt` |
| Passed Filters | 28 | TBD | 18257 | `.stats.txt` |
| Structural variant breakends | 2 | TBD | 1124 | `.stats.txt` |
| Symbolic structural variants | 24 | TBD | 12500 | `.stats.txt` |
| Total Het/Hom ratio | 3.33 (20/6) | TBD | 2.37 (9580/4044) | `.stats.txt` |
| Breakend Het/Hom ratio | 1.00 (1/1) | TBD | 13.41 (1046/78) | `.stats.txt` |
| Symbolic SV Het/Hom ratio | 3.80 (19/5) | TBD | 2.15 (8534/3966) | `.stats.txt` |
| Duplicate entries | chr21:42043166 | TBD  | chr1:16050024 | `.validate.txt` |

### Human Genome Benchmarks
Note, per Nature the following benchmarks exist for the human genome:
“Structural variants affect more bases: the typical genome contains an estimated **2,100 to 2,500 structural variants** (∼1,000 large deletions, ∼160 copy-number variants, ∼915 Alu insertions, ∼128 L1 insertions, ∼51 SVA insertions, ∼4 NUMTs, and ∼10 inversions), affecting ∼20 million bases of sequence.”

### Validation Tool

Included is a template for validating your input files. For more information on the tool check out: https://github.com/uclahs-cds/tool-validate-nf

---

## References

1. [Rausch T, Zichner T, Schlattl A, Stütz AM, Benes V, Korbel JO. DELLY: structural variant discovery by integrated paired-end and split-read analysis. Bioinformatics. 2012;28(18):i333-i339. doi:10.1093/bioinformatics/bts378](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3436805/)
2. [VCFtools - vcf-validator](https://vcftools.github.io/perl_module.html#vcf-validator)
3. [Real Time Genomics RTG Tools Operations Manual - vcfstats](https://cdn.rawgit.com/RealTimeGenomics/rtg-tools/master/installer/resources/tools/RTGOperationsManual/rtg_command_reference.html#vcfstats)
4. [Boutros Lab -CallSV Quality Control pipeline]()
5. [The 1000 Genomes Project Consortium., Corresponding authors., Auton, A. et al. A global reference for human genetic variation. Nature 526, 68–74 (2015). https://doi.org/10.1038/nature15393](https://www.nature.com/articles/nature15393)
