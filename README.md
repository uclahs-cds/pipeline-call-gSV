# Call Germline Structural Variant Pipeline

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

> We will be performing benchmarking on our SLURM cluster.  Currently using 71 CPUs for structural variant calling gives the best performance, running in 3-8 hours per sample with ~10GB of memory.  <i>...Stay tuned for updates from further testing.</i>

### Execute Config File Settings

| Config File | Available Node cpus / memory | Designated Process 1; cpus / memory | Designated Process 2; cpus / memory |
|:------------|:---------|:-------------------------|:-------------------------|
| `lowmem.config` | 2 / 3 GB | delly_call_sv; 1 / 3 GB | validate_file; 1 / 1 GB |
| `midmem.config` | 72 / 136.8 GB | delly_call_sv; 71 / 130 GB | validate_file; 1 / 1 GB |
| `execute.config` | 64 / 950 GB | delly_call_sv; 63 / 940 GB | validate_file; 1 / 1 GB |
---

## How To Run

Pipelines should be run **WITH A SINGLE SAMPLE AT TIME**. Otherwise resource allocation and Nextflow errors could cause the pipeline to fail

1. Make sure the pipeline is already downloaded to your machine. You can either download the stable release or the dev version by cloning the repo.  

2. Update the nextflow.config file for input, output, and parameters. An example can be found [here](pipeline/config/nextflow.config). See [Inputs](#Inputs) for description of each variables in the config file.

3. Update the input csv. See [Inputs](#Inputs) for the columns needed. All columns must exist in order to run the pipeline. An example can be found [here](pipeline/inputs/call-gSV.inputs.csv). The example csv is a single-lane sample. All records must have the same value in the **sample** column.
 
4. See the submission script, [here](https://github.com/uclahs-cds/tool-submit-nf), to submit your pipeline

---

## Flow Diagram

A directed acyclic graph of your pipeline.

![call-gSV flow diagram](call-gSV-flowchart-diagram.drawio.svg?raw=true)

---

## Pipeline Steps

### 1. Calling Structural Variants

The first step of the pipeline requires an aligned and sorted BAM file and BAM index as an input for variant calling with [Delly.](https://github.com/dellytools/delly) Delly combines short-range and long-range paired-end mapping and split-read analysis for the discovery of balanced and unbalanced structural variants at single-nucleotide breakpoint resolution (deletions, tandem duplications, inversions and translocations.) Structural variants are called, annotated and merged into a single bcf file. A default exclude map of Delly can be incorporated as an input which removes the telomeric and centromeric regions of all human chromosomes since these regions cannot be accurately analyzed with short-read data.

Currently the following filters are applied and or considered for application and parameterization in subsequent releases:
* **map-qual:** >20 (Applied / Non-parameterized)    
* **pe:** >= 5 (Not yet Applied / Non-parameterized)
* **sr:** >= 5 (Not yet Applied / Non-parameterized)
* **keep_imprecise:** >= true (Not yet Applied / Non-parameterized)

### 2. Check Output Quality

Running vcf-validate from [VCFTools](https://vcftools.github.io/perl_module.html#vcf-validator) and vcfstats from [RTGtools](https://cdn.rawgit.com/RealTimeGenomics/rtg-tools/master/installer/resources/tools/RTGOperationsManual/rtg_command_reference.html#vcfstats) generates summary statistics that can be viewed and evaluated in preparation for downstream cohort-wide re-calling and re-genotyping.

---

## Inputs

### Input CSV

>The input csv should have all columns below and in the same order. An example of an input csv can be found [here](pipeline/inputs/call-gSV-inputs.csv).

| Field | Type | Description |
|:------|:-----|:------------|
| patient-name | string | The patient name to be passed to final BCF. No white space is allowed. |
| sample-name | string | The sample name to be passed to final BCF. No white space is allowed. |
| input_bam | path | Absolute path to the BAM file for the sample. |



### Nextflow Config File Parameters

| Input Parameter | Required | Type | Description |
|:----------------|:---------|:-----|:------------|
| `dataset_id` | yes | string | Boutros lab dataset id. |
| `blcds_registered_dataset` | yes | boolean | Affirms if dataset is registered in the Boutros Lab Data registry. Default value is false. |
| `sge_scheduler` | yes | boolean | Affirms whether job will be executed on the SGE cluster. Default value is false. |
| `input_csv` | yes | string | Absolute path to the input csv file for the pipeline. |
| `reference_fasta` | yes | path | Absolute path to the reference genome `fasta` file. The reference genome is used by Delly for structural variant calling. |
| `exclusion_file` | yes | path | Absolute path to the delly reference genome `exclusion` file utilized to remove suggested regions for structural variant calling. |
| `run_qc` | yes | boolean | Optional parameter to indicate whether subsequent quality checks should be run. Default value is false. |
| `save_intermediate_files` | yes | boolean | Optional parameter to indicate whether intermediate files will be saved. Default value is true. |
| `output_dir` | yes | path | Absolute path to the directory where the output files to be saved. |
| `output_log_dir` | yes | path | Absolute path to the directory where the output log files to be saved. |
| `temp_dir` | yes | path | Absolute path to the directory where the nextflow's intermediate files are saved. |

---

## Outputs

| Output | Required | Description |
|:-------|:---------|:------------|
| `.bcf` | yes | Binary VCF output format with structural variants if found. |
| `.vcf` | yes | VCF output format with structural variants if found. |
| `.bcf.csi` | yes | CSI-format index for BAM files. |
| `.validate.txt` | yes | output file from vcf-validator. |
| `.stats.txt` | yes | output file from rtgtools. |
| `report.html`, `timeline.html` and `trace.txt` | yes | A Nextflowreport, timeline and trace files. |
| `log.command.*` | yes | Process specific logging files created by nextflow. |

---

## Testing and Validation

### Test Data Set

Testing was performed leveraging aligned and sorted bams generated using bwa-mem2-2.1 against reference GRCh38:

* **amini:**    BWA-MEM2-2.1_TEST0000000_TWGSAMIN000001-T001-S01-F.bam and bai
* **apartial:** BWA-MEM2-2.1_TEST0000000_TWGSAPRT000001-T001-S01-F.bam and bai
* **afull:**    a-full-CPCG0196-B1.bam and bai
* **SMC-HET:**    HG002.N.bam and bai

### Performance Validation

|Test Case | Test Date | Node Type | Duration | CPU Hours | Virtual Memory Usage (RAM) -peak rss |
|:---------|:----------|:----------|:---------|:----------|:---------------------------|
| amini | 2021-02-12 | lowmem | 1m 29s | a few seconds | 208.8 MB |
| apartial | 2021-02-10 | midmem | 42m 5s | 48.8 | 8.9 GB |
| afull | 2021-02-10 | midmem | 7h 10m 43s | 509.0 | 10.9 GB |
| SMC-HET | 2021-02-12 | midmem | 3h 9m 60s | 223.5 |  8.9 GB |

### Quality Check Result Comparison

|Metric | amini | apartial | afull | SMC-HET | Source |
|:------|:------|:---------|:------|:--------|:-------|
| Count Pass | 3 | 2593 | 62704 | 15196 | `grep -c -w  "PASS" filename.vcf -1` |
| Count Deletion | 2 | 1475 | 49433 | 9317 | `grep -c -w  "SVTYPE=DEL" filename.vcf` |
| Count Duplication | 1 | 170 | 2311| 1705 | `grep -c -w  "SVTYPE=DUP" filename.vcf` |
| Count Inversion | 0 | 317 | 2801 | 2197 | `grep -c -w  "SVTYPE=INV" filename.vcf` |
| Count Translocation | 0 | 384 | 7439 | 0 | `grep -c -w  "SVTYPE=BND" filename.vcf` |
| Count Insertion | 0 | 267 | 1265 | 2059 | `grep -c -w  "SVTYPE=INS" filename.vcf` |
| PRECISE Calls | 3 | 1850 | 11541 | 8267 | `grep -c -w  "PRECISE" filename.vcf` |
| IMPRECISE Calls | 2 | 764 | 51709 | 7012 | `grep -c -w  "IMPRECISE" filename.vcf` |
| Failed Filters | 0 | 653 | 44991 | 2619 | `.stats.txt` |
| Passed Filters | 3 | 1959 | 18257 | 12658 | `.stats.txt` |
| Structural variant breakends | 0 | 219 | 1124 | 0 | `.stats.txt` |
| Symbolic structural variants | 2 | 1559 | 12500 | 11156 | `.stats.txt` |
| Same as reference | 1 | 263 | 4595 | 1471 | `.stats.txt` |
| Missing Genotype | 0 | 8 | 38 | 31 | `.stats.txt` | 
| Total Het/Hom ratio | (2/0) | 1.00 (843/845) | 2.37 (9580/4044) | 1.86 (7251/3905) | `.stats.txt` |
| Breakend Het/Hom ratio | (0/0) | 0.84 (59/70) | 13.41 (1046/78) | (0/0) | `.stats.txt` |
| Symbolic SV Het/Hom ratio | (2/0) | 1.01 (784/775) | 2.15 (8534/3966) | 1.86 (7251/3905) | `.stats.txt` |
| Duplicate entries | 0 errors total | 1 error chr8:3893339  | 1 error chr1:16050024 | 1 error chr1:187464829 | `.validate.txt` |

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
