
get-faidx-file-from-reference-file 1.0.0 expression
===================================================

## Table of Contents
  
- [Overview](#get-faidx-file-from-reference-file-v100-overview)  
- [Links](#related-links)  
- [Inputs](#get-faidx-file-from-reference-file-v100-inputs)  
- [Outputs](#get-faidx-file-from-reference-file-v100-outputs)  


## get-faidx-file-from-reference-file v(1.0.0) Overview



  
> ID: get-faidx-file-from-reference-file--1.0.0  
> md5sum: 5537a7433792c92e63c11abe20e9ba78

### get-faidx-file-from-reference-file v(1.0.0) documentation
  
Given a reference fasta file (with a fasta index as a secondary file),
return the secondary file as an object

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../expressions/get-faidx-file-from-reference-file/1.0.0/get-faidx-file-from-reference-file__1.0.0.cwl)  


### Used By
  
- [dragen-qc-hla-pipeline 3.7.5--1.3.5](../../../workflows/dragen-qc-hla-pipeline/3.7.5--1.3.5/dragen-qc-hla-pipeline__3.7.5--1.3.5.md)  

  


## get-faidx-file-from-reference-file v(1.0.0) Inputs

### reference fasta file with faidx secondary file



  
> ID: reference_fasta
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Standard .fa reference fasta file

  


## get-faidx-file-from-reference-file v(1.0.0) Outputs

### fasta index file



  
> ID: get-faidx-file-from-reference-file--1.0.0/faidx_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Created with samtools faidx, must match reference_fasta + ".fai"
  

  

