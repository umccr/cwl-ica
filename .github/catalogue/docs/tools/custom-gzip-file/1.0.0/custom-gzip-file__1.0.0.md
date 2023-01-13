
custom-gzip-file 1.0.0 tool
===========================

## Table of Contents
  
- [Overview](#custom-gzip-file-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-gzip-file-v100-inputs)  
- [Outputs](#custom-gzip-file-v100-outputs)  
- [ICA](#ica)  


## custom-gzip-file v(1.0.0) Overview



  
> ID: custom-gzip-file--1.0.0  
> md5sum: b45042c3cbea47d896b757ecf348a677

### custom-gzip-file v(1.0.0) documentation
  
Compress a file with gzip. Output is the same name as the file but with '.gz' suffix

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-gzip-file/1.0.0/custom-gzip-file__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## custom-gzip-file v(1.0.0) Inputs

### compression level



  
> ID: compression_level
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Set the compression level


### uncompressed file



  
> ID: uncompressed_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Compressed file

  


## custom-gzip-file v(1.0.0) Outputs

### compressed out file



  
> ID: custom-gzip-file--1.0.0/compressed_out_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The compressed output file
  

  

