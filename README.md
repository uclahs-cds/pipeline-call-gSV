# Call Germline Structural Variant Pipeline

- [call-gSV](#pipeline-name)
  - [Overview](#overview)
  - [How To Run](#how-to-run)
  - [Flow Diagram](#flow-diagram)
  - [Pipeline Steps](#pipeline-steps)
    - [Discovery](#discovery)
      - [1. Calling Structural Variants](#1-calling-structural-variants)
      - [2. Calling Copy Number Variants](#2-calling-copy-number-variants)
      - [3. Check Output Quality](#3-check-output-quality)
    - [Regenotyping](#regenotyping)
      - [1. Regenotyping Structural Variants](#1-regenotyping-structural-variants)
      - [2. Regenotyping Copy Number Variants](#2-regenotyping-copy-number-variants)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Testing and Validation](#testing-and-validation)
    - [Test Data Set](#test-data-set)
    - [Performance Validation](#performance-validation)
    - [Quality Check Result Comparison](#quality-check-result-comparison)
    - [Human Genome Benchmarks](#human-genome-benchmarks)
    - [Validation Tool](#validation-tool)
  - [References](#references)
  - [License](#license)

## Overview

The call-gSV nextflow pipeline, calls structural variants and copy number variants utilizing [Delly](https://github.com/dellytools/delly) and [Manta](https://github.com/Illumina/manta). Additionally, the pipeline can also regenotype previously identified structural variants or copy number variants with Delly. It is suitable for detecting copy-number variable deletion and tandem duplication events as well as balanced rearrangements such as inversions or reciprocal translocations and validates the output quality with [BCFtools](https://github.com/samtools/bcftools).  The pipeline has been engineered to run in a 4 layer stack in a cloud-based scalable environment of CycleCloud, Slurm, Nextflow and Docker.  Additionally it has been validated with the SMC-HET dataset and the GRCh38 reference genome, using paired-end FASTQ's that were back-extracted from BAMs created by BAM Surgeon.

<b><i>Developer's Notes:</i></b>

> We will be performing benchmarking on our SLURM cluster.  Currently using 71 CPUs for structural variant calling gives the best performance, running in 3-8 hours per sample with ~10GB of memory.  <i>...Stay tuned for updates from further testing.</i>

### Node Specific Config File Settings

| Config File | Available Node cpus / memory | Designated Process 1; cpus / memory | Designated Process 2; cpus / memory | Designated Process 3; cpus / memory |
|:------------|:---------|:-------------------------|:-------------------------|:-------------------------|
| `F2.config` | 2 / 3 GB | call_gSV_Delly; 1 / 2 GB | call_gSV_Manta; 1 / 2 GB | validate_file; 1 / 1 GB |
| `F72.config` | 72 / 136.8 GB | call_gSV_Delly; 35 / 65 GB | call_gSV_Manta; 35 / 65 GB | validate_file; 1 / 1 GB |
| `M64.config` | 64 / 950 GB | call_gSV_Delly; 31 / 470 GB | call_gSV_Manta; 31 / 470 GB | validate_file; 1 / 1 GB |
---

## How To Run

Pipelines should be run **WITH A SINGLE SAMPLE AT TIME**. Otherwise resource allocation and Nextflow errors could cause the pipeline to fail

1. Make sure the pipeline is already downloaded to your machine. You can either download the stable release or the dev version by cloning the repo.  

2. Update the nextflow.config file for input, output, and parameters. An example can be found [Here](pipeline/config/nextflow.config). See [Inputs](#Inputs) for description of each variables in the config file.

3. Update the input csv. See [Inputs](#Inputs) for the columns needed. All columns must exist in order to run the pipeline. An example can be found [Here](pipeline/inputs/call-gSV.inputs.csv). The example csv is a single germline sample.
 
4. See the submission script, [Here](https://github.com/uclahs-cds/tool-submit-nf), to submit your pipeline

---

## Flow Diagram

A directed acyclic graph of your pipeline.

![call-gSV flow diagram](call-gSV-flowchart-diagram.drawio.svg?raw=true)

---

## Pipeline Steps

### Discovery

The "discovery" branch of the call-gSV pipeline allows you to identify germline structural variants and copy number variants utilizing either Delly or Manta. After variants are identified, basic quality checks are performed on the outputs of the processes.

### 1. Calling Structural Variants

The first step of the pipeline requires an aligned and sorted BAM file and BAM index as an input for variant calling with [Delly](https://github.com/dellytools/delly) or [Manta](https://github.com/Illumina/manta). Delly combines short-range and long-range paired-end mapping and split-read analysis for the discovery of balanced and unbalanced structural variants at single-nucleotide breakpoint resolution (deletions, tandem duplications, inversions and translocations.) Structural variants are called, annotated and merged into a single BCF file. A default exclude map of Delly can be incorporated as an input which removes the telomeric and centromeric regions of all human chromosomes since these regions cannot be accurately analyzed with short-read data.
Manta calls structural variants (SVs) and indels from mapped paired-end sequencing reads. It is optimized for analysis of germline variation in small sets of individuals and somatic variation in tumor/normal sample pairs. Manta discovers, assembles and scores large-scale SVs, medium-sized indels and large insertions within a single efficient workflow.

Currently the following filters are applied by Delly when calling structural variants. Parameters with a "call-gSV default" can be updated in the nextflow.config file.
<br>
| Parameter | Delly default | call-gSV default | Description |
|:------------|:----------|:-------------------------|-------------|
| `svtype` | ALL | | SV type to compute (DEL, INS, DUP, INV, BND, ALL) |
| `map-qual` | 1 | 20 | Minimum paired-end (PE) mapping quality |
| `qual-tra` | 20 |  | Minimum PE quality for translocation |
| `mad-cutoff` | 9 |  | Insert size cutoff, median+s*MAD (deletions only) |
| `minclip` | 25 |  | Minimum clipping length |
| `min-clique-size` | 2 |  | Minimum PE/SR clique size |
| `minrefsep` | 25 |  | Minimum reference separation |
| `maxreadsep` | 40 |  | Maximum read separation |
<br>

### 2. Calling Copy Number Variants

The second step of the pipeline identifies any found copy number variants (CNVs). To do this, Delly requires an aligned and sorted BAM file and BAM index as an input, as well as the BCF output from the initial structural variant calling (to refine breakpoints) and a mappability map. Any CNVs identified are annotated and output as a single BCF file. 

Currently the following filters are applied by Delly when calling copy  number variants. Parameters with a "call-gSV default" can be updated in the nextflow.config file.
<br>
| Parameter | Delly default | call-gSV default | Description |
|:------------|:----------|:-------------------------|-------------|
| `quality` | 10 |  | Minimum mapping quality |
| `ploidy` | 2 | | Baseline ploidy |
| `sdrd` | 2 | | Minimum SD read-depth shift |
| `cn-offset` | 0.100000001 | | Minimum CN offset |
| `cnv-size` | 1000 | | Minimum CNV size |
| `window-size` | 10000 | | Window size |
| `window-offset` | 10000 | | Window offset |
| `fraction-window` | 0.25 | | Minimum callable window fraction [0,1] |
| `scan-window` | 10000 | | Scanning window size |
| `fraction-unique` | 0.800000012 | | Uniqueness filter for scan windows [0,1] |
| `mad-cutoff` | 3 | | Median + 3 * mad count cutoff |
| `percentile` | 0.000500000024 | | Excl. extreme GC fraction |
<br>

### 3. Check Output Quality

For Delly, VCF files are generated from the BCFs to run the vcf-validate command from [VCFTools](https://vcftools.github.io/perl_module.html#vcf-validator) and vcfstats from [RTGTools](https://cdn.rawgit.com/RealTimeGenomics/rtg-tools/master/installer/resources/tools/RTGOperationsManual/rtg_command_reference.html#vcfstats).  Outputs from both provide preliminary summary statistics that can be viewed and evaluated in preparation for downstream cohort-wide re-calling and re-genotyping. In the Manta branch of the pipeline, a stats directory is generated under the specific output directory <outputDirectory>/Manta-<version number>/results/stats where information can be found regarding the SVs identified.
<br>

### Regenotyping

The "regenotyping" branch of the call-gSV pipeline allows you to regenotype previously identified structural variants or copy number variants using Delly. 

### 1. Regenotyping Structural Variants

Similar to the "discovery" process, the first step of the regenotyping pipeline requires an aligned and sorted BAM file, BAM index, and a merged sites BCF (from the merge-SVsites pipeline) as inputs for structural variant regenotyping with [Delly](https://github.com/dellytools/delly). The provided sample is genotyped with the merged sites list. Structural variants are annotated and merged into a single BCF file. A default exclude map of Delly can be incorporated as an input which removes the telomeric and centromeric regions of all human chromosomes since these regions cannot be accurately analyzed with short-read data.
<br>

### 2. Regenotyping Copy Number Variants

The second possible step of the regenotyping pipeline requires an aligned and sorted BAM file, BAM index, and a merged sites BCF as an input, as well as the BCF output from the initial structural variant calling (to refine breakpoints) and a mappability map. Any CNVs identified are annotated and output as a single BCF file.
<br>

---

## Inputs

### Input CSV

The input csv should have all columns below and in the same order. An example of an input csv can be found [here](pipeline/inputs/call-gSV-inputs.csv).

| Field | Type | Description |
|:------|:-----|:------------|
| patient | string | The patient name to be passed to final BCF/VCF. No white space is allowed. |
| sample | string | The sample name to be passed to final BCF/VCF. No white space is allowed. |
| input_bam | path | Absolute path to the BAM file for the sample. |

### Nextflow Config File Parameters

| Input Parameter | Required | Type | Description |
|:----------------|:---------|:-----|:------------|
| `dataset_id` | yes | string | Boutros lab dataset id. |
| `blcds_registered_dataset` | yes | boolean | Affirms if dataset should be registered in the Boutros Lab Data registry. Default value is false. |
| `sge_scheduler` | yes | boolean | Affirms whether job will be executed on the SGE cluster. Default value is false. |
| `run_discovery` | yes | boolean | Specifies whether or not to run the "disovery" branch of the pipeline. Default value is true. (either run_discovery or run_regenotyping must be true) |
| `run_regenotyping` | yes | boolean | Specifies whether or not to run the "regenotyping" branch of the pipeline. Default value is false. (either run_discovery or run_regenotyping must be true) |
| `merged_sites` | yes | path | The path to the merged sites.bcf file. Must be populated if running the regenotyping branch. |
| `input_csv` | yes | string | Absolute path to the input csv file for the pipeline. |
| `reference_fasta` | yes | path | Absolute path to the reference genome `fasta` file. The reference genome is used by Delly for structural variant calling. |
| `reference_fasta_index` | no | path | Absolute path to the reference genome `fasta` index file. The reference genome is used by Delly for structural variant calling. If this path is not specified, call-gSV will assume the index file exists in the same directory as the `reference_fasta` |
| `reference_prefix` | yes | path | Absolute path to the reference genome `fasta` prefix. The reference genome is used by Delly for structural variant calling. |
| `exclusion_file` | yes | path | Absolute path to the delly reference genome `exclusion` file utilized to remove suggested regions for structural variant calling. On Slurm/SGE, an HG38 exclusion file is located at /[hot\|data]/ref/hg38/delly/human.hg38.excl.tsv |
| `mappability_map` | yes | path | Absolute path to the delly mappability map to support GC and mappability fragment correction in CNV calling |
| `map_qual` | no | path | minimum paired-end (PE) mapping quaility threshold for Delly). |
| `run_delly` | true | boolean | Whether or not the workflow should run Delly (either run_delly or run_manta must be set to true) |
| `run_manta` | true | boolean | Whether or not the workflow should run Manta (either run_delly or run_manta must be set to true) |
| `run_qc` | no | boolean | Optional parameter to indicate whether subsequent quality checks should be run on Delly outputs. Default value is false. |
| `save_intermediate_files` | yes | boolean | Optional parameter to indicate whether intermediate files will be saved. Default value is true. |
| `output_dir` | yes | path | Absolute path to the directory where the output files to be saved. 
| `temp_dir` | yes | path | Absolute path to the directory where the nextflow's intermediate files are saved. |

---

## Outputs

| Output | Output Type | Description |
|:-------|:---------|:------------|
| `.bcf` | final | Binary VCF output format with structural variants if found. |
| `.vcf` | intermediate | VCF output format with structural variants if found. If output by Manta, these VCFs will be compressed. |
| `.bcf.csi` | final | CSI-format index for BAM files. |
| `.validate.txt` | final | output file from vcf-validator. |
| `.stats.txt` | final | output file from RTG Tools. |
| `report.html`, `timeline.html` and `trace.txt` | log | A Nextflow report, timeline and trace files. |
| `*.log.command.*` | log | Process and sample specific logging files created by nextflow. |
| `*.sha512` | checksum| generates SHA-512 hash to validate file integrity. |
---

## Testing and Validation

### Test Data Set

Testing was performed leveraging aligned and sorted bams generated using bwa-mem2-2.1 against reference GRCh38 (SMC-HET was aligned against hs37d5):

* **A-mini:**    BWA-MEM2-2.1_TEST0000000_TWGSAMIN000001-T001-S01-F.bam and bai
* **A-partial:** BWA-MEM2-2.1_TEST0000000_TWGSAPRT000001-T001-S01-F.bam and bai
* **A-full:**    a-full-CPCG0196-B1.bam and bai
* **SMC-HET:**    HG002.N.bam and bai

Test runs for the A-mini/partial/full samples were performed using the following reference files

* **reference_fasta:** /hot/ref/reference/GRCh38-BI-20160721/Homo_sapiens_assembly38.fasta
* **reference_fasta_index:** /hot/ref/reference/GRCh38-BI-20160721/Homo_sapiens_assembly38.fasta.fai
* **exclusion_file:** /hot/ref/tool-specific-input/Delly/GRCh38/human.hg38.excl.tsv
* **mappability_map:** /hot/ref/tool-specific-input/Delly/GRCh38/Homo_sapiens.GRCh38.dna.primary_assembly.fa.r101.s501.blacklist.gz

### Performance Validation

Testing was performed primarily in the Boutros Lab SLURM Development cluster but additional functional tests were performed on the SGE cluster on 2/26/2021 and the SLURM Covid cluster.  Metrics below will be updated where relevant with additional testing and tuning outputs.

|Test Case | Test Date | Node Type | Duration | CPU Hours | Virtual Memory Usage (RAM) -peak rss |
|:---------|:----------|:----------|:---------|:----------|:---------------------------|
| A-mini | 2021-02-12 | lowmem | 1m 29s | a few seconds | 208.8 MB |
| A-partial | 2021-02-10 | midmem | 42m 5s | 48.8 | 8.9 GB |
| A-full | 2021-02-10 | midmem | 7h 10m 43s | 509.0 | 10.9 GB |
| SMC-HET | 2021-02-12 | midmem | 3h 9m 60s | 223.5 |  8.9 GB |

### Quality Check Result Comparison

|Metric | A-mini | A-partial | A-full | SMC-HET | Source |
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

## References

1. [Rausch T, Zichner T, Schlattl A, Stütz AM, Benes V, Korbel JO. DELLY: structural variant discovery by integrated paired-end and split-read analysis. Bioinformatics. 2012;28(18):i333-i339. doi:10.1093/bioinformatics/bts378](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3436805/)
2. Chen, X. et al. (2016) Manta: rapid detection of structural variants and indels for germline and cancer sequencing applications. Bioinformatics, 32, 1220-1222. [doi:10.1093/bioinformatics/btv710](https://academic.oup.com/bioinformatics/article/32/8/1220/1743909)
3. [VCFtools - vcf-validator](https://vcftools.github.io/perl_module.html#vcf-validator)
4. [Real Time Genomics RTG Tools Operations Manual - vcfstats](https://cdn.rawgit.com/RealTimeGenomics/rtg-tools/master/installer/resources/tools/RTGOperationsManual/rtg_command_reference.html#vcfstats)
5. [Boutros Lab -CallSV Quality Control pipeline]()
6. [The 1000 Genomes Project Consortium., Corresponding authors., Auton, A. et al. A global reference for human genetic variation. Nature 526, 68–74 (2015). https://doi.org/10.1038/nature15393](https://www.nature.com/articles/nature15393)

## License

Authors: Tim Sanders (TSanders@mednet.ucla.edu), Yu Pan (YuPan@mednet.ucla.edu), Yael Berkovich (YBerkovich@mednet.ucla.edu)

The pipeline-call-gSV is licensed under the GNU General Public License version 2. See the file LICENSE for the terms of the GNU GPL license.

The pipeline-call-gSV takes BAM and BCF files and utilizes Delly to call/regenotype gSV/gCNV.

Copyright (C) 2021 University of California Los Angeles ("Boutros Lab") All rights reserved.

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.