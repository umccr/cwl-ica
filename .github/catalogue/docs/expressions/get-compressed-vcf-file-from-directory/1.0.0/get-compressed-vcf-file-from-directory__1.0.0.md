
get-compressed-vcf-file-from-directory 1.0.0 expression
=======================================================

## Table of Contents
  
- [Overview](#get-compresed-vcf-file-from-directory-v100-overview)  
- [Links](#related-links)  
- [Inputs](#get-compresed-vcf-file-from-directory-v100-inputs)  
- [Outputs](#get-compresed-vcf-file-from-directory-v100-outputs)  


## get-compresed-vcf-file-from-directory v(1.0.0) Overview



  
> ID: get-compresed-vcf-file-from-directory--1.0.0  
> md5sum: 9bf177a6424362a27ea4a4d1d1392de0

### get-compresed-vcf-file-from-directory v(1.0.0) documentation
  
Collect a bgzipped vcf file from the top level of a directory.
Also collect the respective vcf index file.

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../expressions/get-compressed-vcf-file-from-directory/1.0.0/get-compressed-vcf-file-from-directory__1.0.0.cwl)  

  


## get-compresed-vcf-file-from-directory v(1.0.0) Inputs

### input dir



  
> ID: input_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
Input directory with the vcf file present


### vcf nameroot



  
> ID: vcf_nameroot
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
nameroot of the vcf file (excludes .vcf.gz)

  


## get-compresed-vcf-file-from-directory v(1.0.0) Outputs

### compressed vcf file



  
> ID: get-compresed-vcf-file-from-directory--1.0.0/compressed_vcf_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The compressed file output with the .tbi attribute
  

  

