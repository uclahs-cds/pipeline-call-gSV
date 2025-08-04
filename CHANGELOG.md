# Changelog

All notable changes to the call-gSV pipeline.

## Unreleased

### Changed

- Update DELLY `v1.2.6` to `v1.5.0`

## [5.3.0] - 2025-05-02

### Added

- Add circos plot module
- Add `convert_BCF2VCF` workflow

### Changed
- Replace `methods.modify_base_allocations()` with `resource_handler`

## [5.2.0] - 2024-07-03

### Added

- Add `methods.modify_base_allocations()` to update resource allocation

### Changed

- Use `methods.setup_process_afterscript()` for process logs
- Increase CPU allocation for Manta

## [5.1.0] - 2024-06-10

### Changed

- Use HG003 as test sample for NFTest
- Update Nextflow configuration test workflows

## [5.0.0] - 2024-03-15

### Added

- Add PlantUML diagram
- Add configtest-F16 for nextflow pipeline test
- Add processes to node configs
- Call `methods.setup_docker_cpus()` in `config/methods.config`
- `CODEOWNERS` file
- Add NFTest for gSV discovery
- Add workflow to create release bundles with submodules
- Add workflow to render PlantUML images to SVG
- Add workflow to build and deploy documentation to GitHub Pages
- Add workflow to run Nextflow configuration regression tests
- Add one regression test

### Changed

- Update version in render-puml action
- Add exit code 1 to Manta retry strategy
- Set up process retry mechanism
- Parameterize tool output dirs in `main.nf`
- Parameterize workflow log dir in `main.nf`
- Update DELLY `v1.1.3` to `v1.2.6`

### Removed

- `methods.set_docker_sudo()` from `config/methods.config`
- Remove `set_env` method code in `config/methods.config`
- Local copies of resource allocation functions

## [5.0.0-rc.1] - 2023-10-30

### Added

- Add schema for parameter validation
- Add YAML input

### Changed

- Standardize DELLY output filenames
- Enable `save_intermediate_files` in `bcftools.nf` and `rtgtools.nf`
- Standardize Manta output filenames
- Use strings `gSV` and `gCNV` as list for param `variant_type` in `template.config`
- Update README to reflect YAML support
- Parse sample ID from input BAM for output directory naming

### Removed

- Remove params `GSV` and `GCNV` from `template.config`
- Remove CSV input

## [4.0.1] - 2022-12-12

### Added

- Add PipeVal using `pipeline-Nextflow-module` to validate the input CSV file

### Changed

- Parameterize Docker registry
- Use `ghcr.io/uclahs-cds` as default registry

### Removed

- Remove `module/validation.nf` as PipeVal sub-module is used

## [4.0.0] - 2022-08-17

### Added

- Add `F16.config` to allow F16 compatibility for the pipeline

### Changed

- Update <http://README.md> for `4.0.0`
- Move `save_intermediate_files` from `default.config` to `template.config` and set it to `false`
- Update BCFtools 1.12 to 1.15.1
- Update Delly 1.0.3 to 1.1.3
- Update Delly 0.9.1 to 1.0.3
- Standardize repo structure and rename the NF script name from `call-gSV.nf` to `main.nf`

## [4.0.0-rc.1] - 2022-07-29

### Added

- Add the Issue Report template
- Add the Pull Request template
- Add GPL 2.0

### Changed

- Change the input file schema by removing variant_type,reference_fasta,reference_fasta_index, put them into template.config.
- Change partition types from lowmem/midmem/execute to F2/F32/F72/M64.
- Standardize the output structure.
- Standardize the configuration structure.

### Fixed

- Fix Issue #55: fix F2 detection
- Fix Issue #32: remove option '--exclude' in delly cnv
- Fix Issue #33: should pass the mappability_map file instead of the exclusion file to regenotype_gCNV_Delly

## [3.0.0] - 2021-07-01

### Added

- Add ability to call germline SVs with Manta
- Add parameters to control which SV caller is used (run_delly & run_manta)
- Add pipeline version from manifest to pipeline logging output
- Add CNV VCF outputs to QC processes
- Add two new processes to regenotype SVs or CNVs with Delly (regenotype_gSV_Delly & regenotype_gCNV_Delly)
- Add parameters and input variant_type to control which type of regenotyping is run (variant_type, run_regenotyping & run_discovery)

### Changed

- Change output directories to correspond with tool name casing

## [2.2.0] - 2021-05-07

### Changed

- Update modules to point to tool specific Docker Hub repos
- Update of BCFtools from 1.11 to 1.12
- Update of RTG-tools from 3.11 to 3.12

## [2.1.0] - 2021-04-01

### Added

- Add Validate-nf logging outputs to output logging directory

### Changed

- Update Validate-nf tool version from 1.0.0 to 2.1.0 (Resolves issue #18)

## [2.0.0] - 2021-03-30

### Added

- Implement of Delly CNV, with output file conversions and SHA512s
- Add mappability map to config inputs

### Changed

- Update Delly dockerfile to use bl-base
- Include a tag of "SV" or "CNV" in output files, as appropriate

## [1.0.1] - 2021-03-04

### Changed

- Change Docker run permissions (docker.sudo and docker.runOptions)
- Fix issue #9

## [1.0.0] - 2021-03-01

### Added

- Initial call-gSV pipeline release

[1.0.0]: https://github.com/uclahs-cds/pipeline-call-gSV/releases/tag/v1.0.0
[1.0.1]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v1.0.0...v1.0.1
[2.0.0]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v1.0.1...v2.0.0
[2.1.0]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v2.0.0...v2.1.0
[2.2.0]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v2.1.0...v2.2.0
[3.0.0]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v2.2.0...v3.0.0
[4.0.0]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v4.0.0-rc.1...v4.0.0
[4.0.0-rc.1]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v3.0.0...v4.0.0-rc.1
[4.0.1]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v4.0.0...v4.0.1
[5.0.0]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v5.0.0-rc.1...v5.0.0
[5.0.0-rc.1]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v4.0.1...v5.0.0-rc.1
[5.1.0]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v5.0.0...v5.1.0
[5.2.0]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v5.1.0...v5.2.0
[5.3.0]: https://github.com/uclahs-cds/pipeline-call-gSV/compare/v5.2.0...v5.3.0
