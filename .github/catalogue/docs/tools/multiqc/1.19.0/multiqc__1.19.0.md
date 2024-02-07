
multiqc 1.19.0 tool
===================

## Table of Contents
  
- [Overview](#multiqc-v1150-overview)  
- [Links](#related-links)  
- [Inputs](#multiqc-v1150-inputs)  
- [Outputs](#multiqc-v1150-outputs)  
- [ICA](#ica)  


## multiqc v(1.15.0) Overview



  
> ID: multiqc--1.15.0  
> md5sum: 12b0dc0d210b7a92ce8a35a49b50593b

### multiqc v(1.15.0) documentation
  
Documentation for multiqc v1.15.0
Use patch that includes https://github.com/ewels/MultiQC/pull/1969

### Categories
  
- qc  
- visual  


## Related Links
  
- [CWL File Path](../../../../../../tools/multiqc/1.19.0/multiqc__1.19.0.cwl)  


### Used By
  
- [bclconvert-interop-qc 1.3.1--1.19](../../../workflows/bclconvert-interop-qc/1.3.1--1.19/bclconvert-interop-qc__1.3.1--1.19.md)  

  


## multiqc v(1.15.0) Inputs

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


### input directories



  
> ID: input_directories
  
**Optional:** `False`  
**Type:** `.[]`  
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
Defaults to 'multiqc-report.html"


### title



  
> ID: title
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Report title.
Printed as page header, used for filename if not otherwise specified.

  


## multiqc v(1.15.0) Outputs

### output directory



  
> ID: multiqc--1.15.0/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Directory that contains all multiqc analysis data
  


### output file



  
> ID: multiqc--1.15.0/output_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output html file
  

  

