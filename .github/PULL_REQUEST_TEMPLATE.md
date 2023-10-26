# Description
<!--- Briefly describe the changes included in this pull request and the paths to the test cases below
 !--- starting with 'Closes #...' if appropriate --->

### Closes #...

## Testing Results

- Manta
    - sample:    <!-- e.g. A-mini TWGSAMIN000001-N001-S01-F -->
    - input YAML: <!-- path/to/input/call-gSV-inputs.yaml -->
    - config:    <!-- path/to/cpnfig/nextflow-test-amini.config -->
    - output:    <!-- path/to/output/Manta-1.6.0/ -->
- Delly - gSV
    - sample:    <!-- e.g. A-mini TWGSAMIN000001-N001-S01-F -->
    - input YAML: <!-- path/to/input/call-gSV-inputs.yaml -->
    - config:    <!-- path/to/config/nextflow-test-amini.config -->
    - output:    <!-- path/to/output/Delly-0.8.7/ -->
- Delly - gCNV
    - sample:    <!-- e.g. A-mini TWGSAMIN000001-N001-S01-F -->
    - input YAML: <!-- path/to/input/call-gSV-inputs.yaml -->
    - config:    <!-- path/to/config/nextflow-test-amini.config -->
    - output:    <!-- path/to/output/Delly-0.8.7/ -->
- Delly - gSV & gCNV
    - sample:    <!-- e.g. A-mini TWGSAMIN000001-N001-S01-F -->
    - input YAML: <!-- path/to/input/call-gSV-inputs.yaml -->
    - config:    <!-- path/to/config/nextflow-test-amini.config -->
    - output:    <!-- path/to/output/Delly-0.8.7/ -->

# Checklist
<!--- Please read each of the following items and confirm by replacing the [ ] with a [X] --->

- [ ] I have read the [code review guidelines](https://uclahs-cds.atlassian.net/wiki/spaces/BOUTROSLAB/pages/3187646/Code+Review+Guidelines) and the [code review best practice on GitHub check-list](https://uclahs-cds.atlassian.net/wiki/spaces/BOUTROSLAB/pages/3189956/Code+Review+Best+Practice+on+GitHub+-+Check+List).

- [ ] I have reviewed the [Nextflow pipeline standards](https://uclahs-cds.atlassian.net/wiki/spaces/BOUTROSLAB/pages/3193890/Nextflow+pipeline+standardization).

- [ ] The name of the branch is meaningful and well formatted following the [standards](https://uclahs-cds.atlassian.net/wiki/spaces/BOUTROSLAB/pages/3189956/Code+Review+Best+Practice+on+GitHub+-+Check+List), using \[AD_username (or 5 letters of AD if AD is too long)]-\[brief_description_of_branch].

- [ ] I have set up or verified the branch protection rule following the [github standards](https://uclahs-cds.atlassian.net/wiki/spaces/BOUTROSLAB/pages/3190380/GitHub+Standards#GitHubStandards-Branchprotectionrule) before opening this pull request.

- [ ] I have added my name to the contributors listings in the ``manifest`` block in the `nextflow.config` as part of this pull request, am listed
already, or do not wish to be listed. (*This acknowledgement is optional.*)

- [ ] I have added the changes included in this pull request to the `CHANGELOG.md` under the next release version or unreleased, and updated the date.

- [ ] I have updated the version number in the `metadata.yaml` and `manifest` block of the `nextflow.config` file following [semver](https://semver.org/), or the version number has already been updated. (*Leave it unchecked if you are unsure about new version number and discuss it with the infrastructure team in this PR.*)

- [ ] I have tested the pipeline on at least one A-mini sample with `run_delly = true`, `run_manta = true`, `run_qc = true`. For `run_delly = true`, I have tested 'variant_type' set to `gSV`, `gCNV`, and both. The paths to the test config files and output directories are captured above in the Testing Results section.
