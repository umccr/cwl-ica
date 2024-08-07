
umccrise-pipeline 2.2.0--0 workflow
===================================

## Table of Contents
  
- [Overview](#umccrise-pipeline-v220--0-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#umccrise-pipeline-v220--0-inputs)  
- [Steps](#umccrise-pipeline-v220--0-steps)  
- [Outputs](#umccrise-pipeline-v220--0-outputs)  
- [ICA](#ica)  


## umccrise-pipeline v(2.2.0--0) Overview



  
> ID: umccrise-pipeline--2.2.0--0  
> md5sum: 57ea2962cdbb96e09c136019b1f6a35b

### umccrise-pipeline v(2.2.0--0) documentation
  
Documentation for umccrise-pipeline v2.2.0--0

### Categories
  


## Visual Workflow Overview
  
[![umccrise-pipeline__2.2.0--0.svg](../../../../images/workflows/umccrise-pipeline/2.2.0--0/umccrise-pipeline__2.2.0--0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/umccrise-pipeline/2.2.0--0/umccrise-pipeline__2.2.0--0.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/umccrise-pipeline/2.2.0--0/umccrise-pipeline__2.2.0--0.cwl)  


### Uses
  
- [umccrise 2.2.0--0](../../../tools/umccrise/2.2.0--0/umccrise__2.2.0--0.md)  

  


## umccrise-pipeline v(2.2.0--0) Inputs

### debug



  
> ID: debug
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Copy workspace to output directory if workflow fails


### dragen germline directory



  
> ID: dragen_germline_directory
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The dragen germline directory


### dragen normal id



  
> ID: dragen_normal_id
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
The name of the dragen normal sample


### dragen somatic directory



  
> ID: dragen_somatic_directory
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The dragen somatic directory


### dragen tumor id



  
> ID: dragen_tumor_id
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
The name of the dragen tumor sample


### dry run



  
> ID: dry_run
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Prints rules and commands to be run without actually executing them


### genomes tar



  
> ID: genomes_tar
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The reference umccrise tarball


### include stage



  
> ID: include_stage
  
**Optional:** `True`  
**Type:** `.[]`  
**Docs:**  
Optionally, specify stage(s) to run


### output directory name



  
> ID: output_directory_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The name of the output directory


### skip stage



  
> ID: skip_stage
  
**Optional:** `True`  
**Type:** `.[]`  
**Docs:**  
Runs all default stage(s) excluding the one selected


### subject identifier



  
> ID: subject_identifier
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The subject ID (used to name output files)


### threads



  
> ID: threads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Number of threads to use

  


## umccrise-pipeline v(2.2.0--0) Steps

### run umccrise


  
> ID: umccrise-pipeline--2.2.0--0/run_umccrise_step
  
**Step Type:** tool  
**Docs:**
  
Run the UMCCRise CommandLine Tool

#### Links
  
[CWL File Path](../../../../../../tools/umccrise/2.2.0--0/umccrise__2.2.0--0.cwl)  
[CWL File Help Page](../../../tools/umccrise/2.2.0--0/umccrise__2.2.0--0.md)  


## umccrise-pipeline v(2.2.0--0) Outputs

### umccrise output directory



  
> ID: umccrise-pipeline--2.2.0--0/umccrise_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing all umccrise output files
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.b10e715320844774b730b12c6e7fe185  

  
**workflow name:** umccrise-pipeline_dev-wf  
**wfl version name:** 2.2.0--0  

  

