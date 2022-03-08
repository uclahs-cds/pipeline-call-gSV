# Changelog
All notable changes to the call-gSV pipeline.

## [Unreleased]
### Added
- Added the Issue Report template
- Added the Pull Request template
- Added GPL 2.0

### Fixed
- Fixed Issue #32: remove option '--exclude' in delly cnv
- Fixed Issue #33: should pass the mappability_map file instead of the exclusion file to regenotype_gCNV_Delly

### Changed
- Storing variant_type,reference_fasta,reference_fasta_index in the input file is rigid, also duplacating a same value many times. Now store these values in the nextflow.config. 
- Changed partition types from lowmem/midmem/execute to F2/F32/F72/M64.

---

## [3.0.0] - 2021-07-01
### Added
- Added ability to call germline SVs with Manta
- Added parameters to control which SV caller is used (run_delly & run_manta)
- Added pipeline version from manifest to pipeline logging output
- Added CNV VCF outputs to QC processes
- Added two new processes to regenotype SVs or CNVs with Delly (regenotype_gSV_Delly & regenotype_gCNV_Delly)
- Added parameters and input variant_type to control which type of regenotyping is run (variant_type, run_regenotyping & run_discovery)

### Changed
- Changed output directories to correspond with tool name casing

## [2.2.0] - 2021-05-07
### Changed
- Updated modules to point to tool specific Docker Hub repos
- Update of BCFtools from 1.11 to 1.12
- Update of RTG-tools from 3.11 to 3.12

## [2.1.0] - 2021-04-01
### Added
- Added Validate-nf logging outputs to output logging directory

### Changed
- Updated Validate-nf tool version from 1.0.0 to 2.1.0 (Resolves issue #18)

## [2.0.0] - 2021-03-30
### Added
- Implementation of Delly CNV, with output file conversions and SHA512s
- Added mappability map to config inputs

### Changed
- Updated Delly dockerfile to use bl-base
- Output files now include a tag of "SV" or "CNV", as appropriate

## [1.0.1] - 2021-03-04
### Changed
- Changed Docker run permissions (docker.sudo and docker.runOptions)
- Fixes issue #9

## [1.0.0] - 2021-03-01
### Added
- Initial call-gSV pipeline release
