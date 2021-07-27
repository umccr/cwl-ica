
tso500-ctdna-analysis-workflow 1.1.0--120 tool
==============================================

## Table of Contents
  
- [Overview](#tso500-ctdna-analysis-workflow-v110120-overview)  
- [Links](#related-links)  
- [Inputs](#tso500-ctdna-analysis-workflow-v110120-inputs)  
- [Outputs](#tso500-ctdna-analysis-workflow-v110120-outputs)  
- [ICA](#ica)  


## tso500-ctdna-analysis-workflow v(1.1.0.120) Overview



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120  
> md5sum: 26f06d67bc0c1b8569f4d03d91335b44

### tso500-ctdna-analysis-workflow v(1.1.0.120) documentation
  
Runs the ctDNA analysis workflow v(1.1.0.120)

### Categories
  
- tso500  


## Related Links
  
- [CWL File Path](../../../../../../tools/tso500-ctdna-analysis-workflow/1.1.0--120/tso500-ctdna-analysis-workflow__1.1.0--120.cwl)  


### Used By
  
- [tso500-ctdna 1.1.0--120](../../../workflows/tso500-ctdna/1.1.0--120/tso500-ctdna__1.1.0--120.md)  

  


## tso500-ctdna-analysis-workflow v(1.1.0.120) Inputs

### dragen license key



  
> ID: dragen_license_key
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
File containing the dragen license


### fastq list rows



  
> ID: fastq_list_rows
  
**Optional:** `False`  
**Type:** `fastq-list-row[]`  
**Docs:**  
A list of fastq list rows where each element has the following attributes
* rgid  # Not used
* rgsm
* rglb  # Not used
* read_1
* read_2


### fastq validation dsdm



  
> ID: fastq_validation_dsdm
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Output of demux workflow. Contains steps for each sample id to run


### output dirname



  
> ID: output_dirname
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Output directory name (optional)


### resources dir



  
> ID: resources_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The directory of resources


### tso500 samples



  
> ID: tso500_samples
  
**Optional:** `False`  
**Type:** `tso500-sample[]`  
**Docs:**  
A list of tso500 samples each element has the following attributes:
* sample_id
* sample_type
* pair_id

  


## tso500-ctdna-analysis-workflow v(1.1.0.120) Outputs

### contamination dsdm



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/contamination_dsdm  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Contamination dsdm json, used as input for Reporting task
  


### output directory



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/output_dir  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Output files
  

  


## ICA

### ToC
  
- [development_workflows](#development_workflows)  
- [collab-illumina-dev_workflows](#collab-illumina-dev_workflows)  


### Project: development_workflows


> wfl id: wfl.867aabc177344a40ae61ef868ddd3c98  

  
**workflow name:** tso500-ctdna-analysis-workflow_dev-wf  
**wfl version name:** 1.1.0--120  


### Project: collab-illumina-dev_workflows


> wfl id: wfl.544d209e70d1470b93ef0033ba201784  

  
**workflow name:** tso500-ctdna-analysis-workflow_clb-ilmn-dev  
**wfl version name:** 1.1.0--120  

  

