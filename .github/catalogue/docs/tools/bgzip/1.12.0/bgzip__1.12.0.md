
bgzip 1.12.0 tool
=================

## Table of Contents
  
- [Overview](#bgzip-v1120-overview)  
- [Links](#related-links)  
- [Inputs](#bgzip-v1120-inputs)  
- [Outputs](#bgzip-v1120-outputs)  
- [ICA](#ica)  


## bgzip v(1.12.0) Overview



  
> ID: bgzip--1.12.0  
> md5sum: 8ff2a96c27f828caf120b0441c4d4fe2

### bgzip v(1.12.0) documentation
  
compress a file with bgzip. More info can be found [here](http://www.htslib.org/doc/bgzip.html)

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/bgzip/1.12.0/bgzip__1.12.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## bgzip v(1.12.0) Inputs

### compress level



  
> ID: compress_level
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Compression level to use when compressing; 0 to 9, or -1 for default [-1]


### index



  
> ID: index
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Compress and create BGZF index


### offset



  
> ID: offset
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Decompress at virtual file pointer (0-based uncompressed offset)


### threads



  
> ID: threads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
number of compression threads to use [1]


### uncompressed vcf file



  
> ID: uncompressed_vcf_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The input uncompressed vcf file

  


## bgzip v(1.12.0) Outputs

### compressed output vcf file



  
> ID: bgzip--1.12.0/compressed_output_vcf_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The bgzipped (and indexed?) vcf file
  

  

