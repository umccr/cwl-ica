
multiqc-interop 1.14.0--1.2.0 tool
==================================

## Table of Contents
  
- [Overview](#multiqc-interop-v1140--120-overview)  
- [Links](#related-links)  
- [Inputs](#multiqc-interop-v1140--120-inputs)  
- [Outputs](#multiqc-interop-v1140--120-outputs)  
- [ICA](#ica)  


## multiqc-interop v(1.14.0--1.2.0) Overview



  
> ID: multiqc-interop--1.14.0--1.2.0  
> md5sum: 51124a92668705d8417ad48cc52eb6f8

### multiqc-interop v(1.14.0--1.2.0) documentation
  
Documentation for multiqc-interop v1.14.0--1.2.0

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/multiqc-interop/1.14.0--1.2.0/multiqc-interop__1.14.0--1.2.0.cwl)  


### Used By
  
- [bcl-conversion 3.7.5](../../../workflows/bcl-conversion/3.7.5/bcl-conversion__3.7.5.md)  

  


## multiqc-interop v(1.14.0--1.2.0) Inputs

### dummy file



  
> ID: dummy_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
testing inputs stream logic
If used will set input mode to stream on ICA which
saves having to download the entire input folder


### input directory



  
> ID: input_directory
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The bcl directory


### output directory



  
> ID: output_directory_name
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
The output directory, defaults to "multiqc-outdir"


### output filename



  
> ID: output_filename
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Report filename in html format.
Defaults to 'multiqc-report.html'


### title



  
> ID: title
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Report title.
Printed as page header, used for filename if not otherwise specified.

  


## multiqc-interop v(1.14.0--1.2.0) Outputs

### multiqc output



  
> ID: multiqc-interop--1.14.0--1.2.0/interop_multi_qc_out  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
output dircetory with interop multiQC matrices
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.d14e91dc019349afa57febf4034bc39b  

  
**workflow name:** multiqc-interop_dev-wf  
**wfl version name:** 1.14.0--1.2.0  

  

