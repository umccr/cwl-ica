
illumina-interop 1.2.0 tool
===========================

## Table of Contents
  
- [Overview](#illumina-interop-v120-overview)  
- [Links](#related-links)  
- [Inputs](#illumina-interop-v120-inputs)  
- [Outputs](#illumina-interop-v120-outputs)  
- [ICA](#ica)  


## illumina-interop v(1.2.0) Overview



  
> ID: illumina-interop--1.2.0  
> md5sum: cfe5334a2e43b6ac9ad7b763f93e33d9

### illumina-interop v(1.2.0) documentation
  
Documentation for illumina-interop v1.2.0 can be found here: https://github.com/Illumina/interop

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/illumina-interop/1.2.0/illumina-interop__1.2.0.cwl)  


### Used By
  
- [bclconvert-with-qc-pipeline 4.0.3](../../../workflows/bclconvert-with-qc-pipeline/4.0.3/bclconvert-with-qc-pipeline__4.0.3.md)  
- [illumina-interop-qc 1.2.0--1.14.0](../../../workflows/illumina-interop-qc/1.2.0--1.14.0/illumina-interop-qc__1.2.0--1.14.0.md)  

  


## illumina-interop v(1.2.0) Inputs

### dummy file



  
> ID: dummy_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
testing inputs stream logic
If used will set input mode to stream on ICA which
saves having to download the entire input folder


### input run directory



  
> ID: input_run_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The bcl directory


### output directory



  
> ID: output_dir_name
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
The output directory, defaults to "interop_summary_files"

  


## illumina-interop v(1.2.0) Outputs

### multiqc output



  
> ID: illumina-interop--1.2.0/interop_outdir  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
output directory
  

  

