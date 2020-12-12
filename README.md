# Call germline Structural Variant Pipeline of Paired End and Split Reads

- [Pipeline Name](#pipeline-name)
  - [Overview](#overview)
  - [How To Run](#how-to-run)
  - [Flow Diagram](#flow-diagram)
  - [Pipeline Steps](#pipeline-steps)
    - [1. Step/Proccess 1](#1-stepproccess-1)
    - [2. Step/Proccess 2](#2-stepproccess-2)
    - [3. Step/Proccess n](#3-stepproccess-n)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Testing and Validation](#testing-and-validation)
    - [Test Data Set](#test-data-set)
    - [Validation <version number\>](#validation-version-number)
    - [Validation Tool](#validation-tool)
  - [References](#references)

## Overview

The call-gSV nextflow pipeline, calls structural variants including deletions, insertions, translocations utilizing [Delly] (https://github.com/dellytools/delly) and [BCFtools](https://github.com/samtools/bcftools).  The pipeline has been engineered to run in a 4 layer stack in a cloud-based scalable environment of CycleCloud, Slurm, Nextflow and Docker.  Additionally it has been validated with the SMC-HET dataset and reference GRCh38, where paired-end fastq's were created with BAM Surgeon.

The pipeline should be run **WITH A SINGLE SAMPLE AT A TiME.**  Otherwise resource allocation and Nextflow errors could cause the pipeline to fail.

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

The first step of the pipeline utilizes [Delly] (https://github.com/dellytools/delly) to call structural variants and output results to a single bcf file. A default exclude map of Delly can be incorporated which removes the telomeric and centromeric regions of all human chromosomes since these regions cannot be accurately analyzed with short-read data.

### 2. Step/Proccess 2

> A 2-3 sentence description of each step/proccess in your pipeline that includes the purpose of the step/process, the tool(s) being used and their version, and the expected scientific inputs/outputs (e.g: FASTQs and BAMs) of the pipeline.

### 3. Step/Proccess n

> A 2-3 sentence description of each step/proccess in your pipeline that includes the purpose of the step/process, the tool(s) being used and their version, and the expected scientific inputs/outputs (e.g: FASTQs and BAMs) of the pipeline.

---

## Inputs

 Input and Input Parameter/Flag | Required | Description |
| ------------ | ------------ | ------------------------ |
| input/ouput 1 | yes/no | 1 - 2 sentence description of the input/output. |
| input/ouput 2 | yes/no | 1 - 2 sentence description of the input/output. |
| input/ouput n | yes/no | 1 - 2 sentence description of the input/output. |

---

## Outputs

 Output and Output Parameter/Flag | Required | Description |
| ------------ | ------------ | ------------------------ |
| input/ouput 1 | yes/no | 1 - 2 sentence description of the input/output. |
| input/ouput 2 | yes/no | 1 - 2 sentence description of the input/output. |
| input/ouput n | yes/no | 1 - 2 sentence description of the input/output. |

---

## Testing and Validation

### Test Data Set

A 2-3 sentence description of the test data set(s) used to validate and test this pipeline. If possible, include references and links for how to access and use the test dataset

### Validation <version number\>

 Input/Output | Description | Result  
 | ------------ | ------------------------ | ------------------------ |
| metric 1 | 1 - 2 sentence description of the metric | quantifiable result |
| metric 2 | 1 - 2 sentence description of the metric | quantifiable result |
| metric n | 1 - 2 sentence description of the metric | quantifiable result |

- [Reference/External Link/Path 1 to any files/plots or other validation results](<link>)
- [Reference/External Link/Path 2 to any files/plots or other validation results](<link>)
- [Reference/External Link/Path n to any files/plots or other validation results](<link>)

### Validation Tool

Included is a template for validating your input files. For more information on the tool check out: https://github.com/uclahs-cds/tool-validate-nf

---

## References

1. [https://tobiasrausch.com/courses/vc/sv/#introduction](https://tobiasrausch.com/courses/vc/sv/#introduction)
2. [Reference 2](<links-to-papers/external-code/documentation/metadata/other-repos/or-anything-else>)
3. [Reference n](<links-to-papers/external-code/documentation/metadata/other-repos/or-anything-else>)
