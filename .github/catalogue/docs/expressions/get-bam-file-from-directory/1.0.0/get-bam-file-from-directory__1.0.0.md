
get-bam-file-from-directory 1.0.0 expression
============================================

## Table of Contents
  
- [Overview](#get-bam-file-from-directory-v100-overview)  
- [Links](#related-links)  
- [Inputs](#get-bam-file-from-directory-v100-inputs)  
- [Outputs](#get-bam-file-from-directory-v100-outputs)  


## get-bam-file-from-directory v(1.0.0) Overview



  
> ID: get-bam-file-from-directory--1.0.0  
> md5sum: beca34eae934496b9672b53c0fd5c4dd

### get-bam-file-from-directory v(1.0.0) documentation
  
Collect a bam file from the top level of the directory.
Also find its index file and append it as a secondary file

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../expressions/get-bam-file-from-directory/1.0.0/get-bam-file-from-directory__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## get-bam-file-from-directory v(1.0.0) Inputs

### bam nameroot



  
> ID: bam_nameroot
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
nameroot of the bam file


### input dir



  
> ID: input_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
Input directory with the bam file present

  


## get-bam-file-from-directory v(1.0.0) Outputs

### bam file



  
> ID: get-bam-file-from-directory--1.0.0/bam_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The bam file output with the .bai attribute
  

  

