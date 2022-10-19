
umccrise 2.2.0--0 tool
======================

## Table of Contents
  
- [Overview](#umccrise-v220--0-overview)  
- [Links](#related-links)  
- [Inputs](#umccrise-v220--0-inputs)  
- [Outputs](#umccrise-v220--0-outputs)  
- [ICA](#ica)  


## umccrise v(2.2.0--0) Overview



  
> ID: umccrise--2.2.0--0  
> md5sum: 29bd6aa6205e7b68d9395771a6e62a9c

### umccrise v(2.2.0--0) documentation
  
Documentation for umccrise v2.2.0--0

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/umccrise/2.2.0--0/umccrise__2.2.0--0.cwl)  

  


## umccrise v(2.2.0--0) Inputs

### dragen germline directory



  
> ID: dragen_germline_directory
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The dragen germline directory


### dragen normal id



  
> ID: dragen_normal_id
  
**Optional:** `False`  
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
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The name of the dragen tumor sample


### genomes tar



  
> ID: genomes_tar
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The reference umccrise tarball


### output directory name



  
> ID: output_directory_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The name of the output directory


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

  


## umccrise v(2.2.0--0) Outputs

### output directory



  
> ID: umccrise--2.2.0--0/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing the umccrise data
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  
- [production_workflows](#project-production_workflows)  


### Project: development_workflows


> wfl id: wfl.af61d2b172e84cbfa85eaf184226db8b  

  
**workflow name:** umccrise_dev-wf  
**wfl version name:** 2.2.0--0  


### Project: production_workflows


> wfl id: wfl.714e9172f3674023b210ccc7c47db05a  

  
**workflow name:** umccrise_prod-wf  
**wfl version name:** 2.2.0--0--1ecf63c  

  

