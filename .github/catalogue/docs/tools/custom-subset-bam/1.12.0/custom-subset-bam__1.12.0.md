
custom-subset-bam 1.12.0 tool
=============================

## Table of Contents
  
- [Overview](#custom-subset-bam-v1120-overview)  
- [Links](#related-links)  
- [Inputs](#custom-subset-bam-v1120-inputs)  
- [Outputs](#custom-subset-bam-v1120-outputs)  
- [ICA](#ica)  


## custom-subset-bam v(1.12.0) Overview



  
> ID: custom-subset-bam--1.12.0  
> md5sum: beccb4a5e29eed5de0be6dc7617f3602

### custom-subset-bam v(1.12.0) documentation
  
Use samtools v1.12.0 and shuf to take a random subset of a bam file

### Categories
  
- bam handler  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-subset-bam/1.12.0/custom-subset-bam__1.12.0.cwl)  


### Used By
  
- [optitype-pipeline 1.3.5](../../../workflows/optitype-pipeline/1.3.5/optitype-pipeline__1.3.5.md)  

  


## custom-subset-bam v(1.12.0) Inputs

### bam sorted



  
> ID: bam_sorted
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Sorted bam file to be truncated


### n lines



  
> ID: n_lines
  
**Optional:** `False`  
**Type:** `int`  
**Docs:**  
Number of lines to subset

  


## custom-subset-bam v(1.12.0) Outputs

### bam subset



  
> ID: custom-subset-bam--1.12.0/bam_indexed  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Subsetted bam file (sorted by chromosome)
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.18ab0d900ea0453384db086a4fbc5ed9  

  
**workflow name:** custom-subset-bam_dev-wf  
**wfl version name:** 1.12.0  

  

