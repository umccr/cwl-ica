
custom-create-tso500-samplesheet 1.0.0 tool
===========================================

## Table of Contents
  
- [Overview](#custom-create-tso500-samplesheet-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-create-tso500-samplesheet-v100-inputs)  
- [Outputs](#custom-create-tso500-samplesheet-v100-outputs)  
- [ICA](#ica)  


## custom-create-tso500-samplesheet v(1.0.0) Overview



  
> ID: custom-create-tso500-samplesheet--1.0.0  
> md5sum: 4112791f8fe39341354c38e15149060f

### custom-create-tso500-samplesheet v(1.0.0) documentation
  
Given a v2 samplesheet updates the [<SampleSheet_Prefix"_Data] section to include the 'Sample_Type' and 'Pair_ID' attributes

### Categories
  
- tso500  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-create-tso500-samplesheet/1.0.0/custom-create-tso500-samplesheet__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna 1.1.0--120](../../../workflows/tso500-ctdna/1.1.0--120/tso500-ctdna__1.1.0--120.md)  

  


## custom-create-tso500-samplesheet v(1.0.0) Inputs

### coerce valid index



  
> ID: coerce_valid_index
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Coerce a valid index for ctTSO sample


### output file name



  
> ID: out_file
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Set to samplesheet.tso500.csv by default


### samplesheet



  
> ID: samplesheet
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The v2 samplesheet used for demultiplexing the tso500 samples with


### samplesheet_prefix



  
> ID: samplesheet_prefix
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
The samplesheet prefix for v2 samplesheets


### tso500 samples



  
> ID: tso500_samples
  
**Optional:** `False`  
**Type:** `tso500-sample[]`  
**Docs:**  
The tso500 sample objects

  


## custom-create-tso500-samplesheet v(1.0.0) Outputs

### tso500 samplesheet



  
> ID: custom-create-tso500-samplesheet--1.0.0/tso500_samplesheet  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The updated samplesheet with the Sample_Type and Pair_ID columns in the Data section
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  
- [collab-illumina-dev_workflows](#project-collab-illumina-dev_workflows)  


### Project: development_workflows


> wfl id: wfl.a754b24fde75444b8e97f67412b935fe  

  
**workflow name:** custom-create-tso500-samplesheet_dev-wf  
**wfl version name:** 1.0.0  


### Project: collab-illumina-dev_workflows


> wfl id: wfl.3d98d8f73eb4408084594a42fa227a89  

  
**workflow name:** custom-create-tso500-samplesheet_clb-ilmn-dev  
**wfl version name:** 1.0.0  

  

