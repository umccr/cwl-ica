
umccrise 2.1.1--0 tool
======================

## Table of Contents
  
- [Overview](#umccrise-v211--0-overview)  
- [Links](#related-links)  
- [Inputs](#umccrise-v211--0-inputs)  
- [Outputs](#umccrise-v211--0-outputs)  
- [ICA](#ica)  


## umccrise v(2.1.1--0) Overview



  
> ID: umccrise----0  
> md5sum: 6f20fd7668e6f9408a5efe966cc16ce7

### umccrise v(2.1.1--0) documentation
  
Documentation for umccrise v2.1.1--0

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/umccrise/2.1.1--0/umccrise__2.1.1--0.cwl)  


### Used By
  
- [umccrise-with-dragen-germline-pipeline 2.1.1--3.9.3](../../../workflows/umccrise-with-dragen-germline-pipeline/2.1.1--3.9.3/umccrise-with-dragen-germline-pipeline__2.1.1--3.9.3.md)  

  


## umccrise v(2.1.1--0) Inputs

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

  


## umccrise v(2.1.1--0) Outputs

### output directory



  
> ID: umccrise----0/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing the umccrise data
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.af61d2b172e84cbfa85eaf184226db8b  

  
**workflow name:** umccrise_dev-wf  
**wfl version name:** 2.1.1--0  

  

