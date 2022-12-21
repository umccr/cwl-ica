
custom-tsv-to-json 1.0.0 tool
=============================

## Table of Contents
  
- [Overview](#custom-tsv-to-json-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-tsv-to-json-v100-inputs)  
- [Outputs](#custom-tsv-to-json-v100-outputs)  
- [ICA](#ica)  


## custom-tsv-to-json v(1.0.0) Overview



  
> ID: custom-tsv-to-json--1.0.0  
> md5sum: aefe53976ee3432e0d5a1eba41918214

### custom-tsv-to-json v(1.0.0) documentation
  
Given a tsv file (or csv / text file), strip the first set of rows as indicated in 'skip_rows' and convert
the remainder to a compressed json file (in orient format).
Original cwl tool can be found [here](https://github.com/YinanWang16/tso500-ctdna-post-processing/blob/main/cwl/tools/tsv2json/tsv2json.cwl)

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-tsv-to-json/1.0.0/custom-tsv-to-json__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## custom-tsv-to-json v(1.0.0) Inputs

### skip rows



  
> ID: skip_rows
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
skip rows of the tsv file


### tsv file



  
> ID: tsv_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
TSV file to be converted into json format

  


## custom-tsv-to-json v(1.0.0) Outputs

### output json gzipped file



  
> ID: custom-tsv-to-json--1.0.0/json_gz_out  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The output gzipped json file
  

  

