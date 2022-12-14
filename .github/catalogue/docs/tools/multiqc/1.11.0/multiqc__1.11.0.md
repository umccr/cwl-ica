
multiqc 1.11.0 tool
===================

## Table of Contents
  
- [Overview](#multiqc-v1110-overview)  
- [Links](#related-links)  
- [Inputs](#multiqc-v1110-inputs)  
- [Outputs](#multiqc-v1110-outputs)  
- [ICA](#ica)  


## multiqc v(1.11.0) Overview



  
> ID: multiqc--1.11.0  
> md5sum: f97e8d47f754cb3daf7a10bd5b8e5eec

### multiqc v(1.11.0) documentation
  
Documentation for multiqc v1.11.0

### Categories
  
- qc  
- visual  


## Related Links
  
- [CWL File Path](../../../../../../tools/multiqc/1.11.0/multiqc__1.11.0.cwl)  


### Used By
  
- [bcl-conversion 3.7.5](../../../workflows/bcl-conversion/3.7.5/bcl-conversion__3.7.5.md)  
- [dragen-transcriptome-pipeline 3.8.4](../../../workflows/dragen-transcriptome-pipeline/3.8.4/dragen-transcriptome-pipeline__3.8.4.md)  

  


## multiqc v(1.11.0) Inputs

### cl config



  
> ID: cl_config
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Override config from the cli


### comment



  
> ID: comment
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Custom comment, will be printed at the top of the report.


### config



  
> ID: config
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Configuration file for bclconvert


### dummy file



  
> ID: dummy_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
testing inputs stream logic
If used will set input mode to stream on ICA which
saves having to download the entire input folder


### input directories



  
> ID: input_directories
  
**Optional:** `False`  
**Type:** `Directory[]`  
**Docs:**  
The list of directories to place in the analysis


### output directory



  
> ID: output_directory_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The output directory


### output filename



  
> ID: output_filename
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Report filename in html format.
Defaults to 'multiqc-report.html'


### replace names



  
> ID: replace_names
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
a tab-separated file with two columns. The first column contains the search strings and 
the second the replacement strings


### title



  
> ID: title
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Report title.
Printed as page header, used for filename if not otherwise specified.

  


## multiqc v(1.11.0) Outputs

### output directory



  
> ID: multiqc--1.11.0/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Directory that contains all multiqc analysis data
  


### output file



  
> ID: multiqc--1.11.0/output_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output html file
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.c2ca973c62a24066bf82f63715d66083  

  
**workflow name:** multiqc_dev-wf  
**wfl version name:** 1.11.0  

  

