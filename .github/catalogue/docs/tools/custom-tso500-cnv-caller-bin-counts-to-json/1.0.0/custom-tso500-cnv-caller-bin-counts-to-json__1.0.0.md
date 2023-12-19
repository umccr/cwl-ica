
custom-tso500-cnv-caller-bin-counts-to-json 1.0.0 tool
======================================================

## Table of Contents
  
- [Overview](#custom-tso500-cnv-caller-bin-counts-to-json-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-tso500-cnv-caller-bin-counts-to-json-v100-inputs)  
- [Outputs](#custom-tso500-cnv-caller-bin-counts-to-json-v100-outputs)  
- [ICA](#ica)  


## custom-tso500-cnv-caller-bin-counts-to-json v(1.0.0) Overview



  
> ID: custom-tso500-cnv-caller-bin-counts-to-json--1.0.0  
> md5sum: afaf45f340c857b9f92bba7d4638b4ca

### custom-tso500-cnv-caller-bin-counts-to-json v(1.0.0) documentation
  
Documentation for custom-tso500-cnv-caller-bin-counts-to-
json v1.0.0

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-tso500-cnv-caller-bin-counts-to-json/1.0.0/custom-tso500-cnv-caller-bin-counts-to-json__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## custom-tso500-cnv-caller-bin-counts-to-json v(1.0.0) Inputs

### output_prefix



  
> ID: output_prefix
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Required, output file is then <this>.CnvCallerBinCounts.json.gz


### csv metrics files



  
> ID: tsv_bin_count_files
  
**Optional:** `False`  
**Type:** `.[]`  
**Docs:**  
The list of csv metrics files file

  


## custom-tso500-cnv-caller-bin-counts-to-json v(1.0.0) Outputs

### metrics json gz out



  
> ID: custom-tso500-cnv-caller-bin-counts-to-json--1.0.0/bin_counts_gz_out  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output file in compressed json gz format
  

  

