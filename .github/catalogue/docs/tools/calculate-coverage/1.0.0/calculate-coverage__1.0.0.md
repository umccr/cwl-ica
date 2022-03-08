
calculate-coverage 1.0.0 tool
=============================

## Table of Contents
  
- [Overview](#calculate-coverage-v100-overview)  
- [Links](#related-links)  
- [Inputs](#calculate-coverage-v100-inputs)  
- [Outputs](#calculate-coverage-v100-outputs)  
- [ICA](#ica)  


## calculate-coverage v(1.0.0) Overview



  
> ID: calculate-coverage--1.0.0  
> md5sum: ef3a46abbede91b27b2accd3944d9ded

### calculate-coverage v(1.0.0) documentation
  
Documentation for calculate-coverage v1.0.0
https://github.com/c-BIG/wgs-sample-qc/tree/main/example_implementations/sg-npm 

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/calculate-coverage/1.0.0/calculate-coverage__1.0.0.cwl)  


### Used By
  
- [ghif-qc 1.0.1](../../../workflows/ghif-qc/1.0.1/ghif-qc__1.0.1.md)  

  


## calculate-coverage v(1.0.0) Inputs

### log level



  
> ID: log_level
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Set logging level to INFO (default), WARNING or DEBUG.


### map quality



  
> ID: map_quality
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Mapping quality threshold. Default: 20.


### out directory



  
> ID: out_directory
  
**Optional:** `True`  
**Type:** `Directory`  
**Docs:**  
Path to scratch directory. Default: ./


### output json



  
> ID: output_json
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
output file


### ref seq



  
> ID: ref_seq
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Path to genome fasta. Required when providing an input CRAM


### sample bam



  
> ID: sample_bam
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to input BAM or CRAM


### script



  
> ID: script
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to PRECISE python script on GitHub


### input bed



  
> ID: target_regions
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Path to BED file to be used as a mask for metrics calculation. 
Only regions in the provided BED will be considered.

  


## calculate-coverage v(1.0.0) Outputs

### output file



  
> ID: calculate-coverage--1.0.0/output_filename  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
JSON output file containing QC metrics
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.de659694e0b04a4f88763674be6a74fe  

  
**workflow name:** calculate-coverage_dev-wf  
**wfl version name:** 1.0.0  

  

