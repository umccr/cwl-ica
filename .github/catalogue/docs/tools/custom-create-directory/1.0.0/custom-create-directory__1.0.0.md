
custom-create-directory 1.0.0 tool
==================================

## Table of Contents
  
- [Overview](#custom-create-directory-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-create-directory-v100-inputs)  
- [Outputs](#custom-create-directory-v100-outputs)  
- [ICA](#ica)  


## custom-create-directory v(1.0.0) Overview



  
> ID: custom-create-directory--1.0.0  
> md5sum: 76cecdd499a7db79c994373ff95c5862

### custom-create-directory v(1.0.0) documentation
  
Documentation for custom-create-directory v1.0.0
Create a directory based on a list of inputs generated as input files or input directories

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-create-directory/1.0.0/custom-create-directory__1.0.0.cwl)  


### Used By
  
- [dragen-transcriptome-pipeline 3.7.5](../../../workflows/dragen-transcriptome-pipeline/3.7.5/dragen-transcriptome-pipeline__3.7.5.md)  
- [dragen-transcriptome-pipeline 3.8.4](../../../workflows/dragen-transcriptome-pipeline/3.8.4/dragen-transcriptome-pipeline__3.8.4.md)  
- [dragen-transcriptome-pipeline 3.9.3](../../../workflows/dragen-transcriptome-pipeline/3.9.3/dragen-transcriptome-pipeline__3.9.3.md)  
- [dragen-transcriptome-pipeline 4.0.3](../../../workflows/dragen-transcriptome-pipeline/4.0.3/dragen-transcriptome-pipeline__4.0.3.md)  

  


## custom-create-directory v(1.0.0) Inputs

### input directories



  
> ID: input_directories
  
**Optional:** `True`  
**Type:** `.[]`  
**Docs:**  
List of input directories to go into the output directory


### input files



  
> ID: input_files
  
**Optional:** `True`  
**Type:** `.[]`  
**Docs:**  
List of input files to go into the output directory


### output directory name



  
> ID: output_directory_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The name of the output directory

  


## custom-create-directory v(1.0.0) Outputs

### output directory



  
> ID: custom-create-directory--1.0.0/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory with all of the outputs collected
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  
- [collab-illumina-dev_workflows](#project-collab-illumina-dev_workflows)  


### Project: development_workflows


> wfl id: wfl.d58562105cb74b67906be002c2f53bef  

  
**workflow name:** custom-create-directory_dev-wf  
**wfl version name:** 1.0.0  


### Project: collab-illumina-dev_workflows


> wfl id: wfl.261e0e22cfc842579d708d7a14134d4b  

  
**workflow name:** custom-create-directory_clb-ilmn-dev_wf  
**wfl version name:** 1.0.0  

  

