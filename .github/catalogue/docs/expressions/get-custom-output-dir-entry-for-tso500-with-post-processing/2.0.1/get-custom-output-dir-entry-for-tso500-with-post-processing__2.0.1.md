
get-custom-output-dir-entry-for-tso500-with-post-processing 2.0.1 expression
============================================================================

## Table of Contents
  
- [Overview](#get-custom-output-dir-entry-for-tso500-with-post-processing-v201-overview)  
- [Links](#related-links)  
- [Inputs](#get-custom-output-dir-entry-for-tso500-with-post-processing-v201-inputs)  
- [Outputs](#get-custom-output-dir-entry-for-tso500-with-post-processing-v201-outputs)  


## get-custom-output-dir-entry-for-tso500-with-post-processing v(2.0.1) Overview



  
> ID: get-custom-output-dir-entry-for-tso500-with-post-processing--2.0.1  
> md5sum: f4bb08524b73b86293e8319e68f1dc33

### get-custom-output-dir-entry-for-tso500-with-post-processing v(2.0.1) documentation
  
Create a custom-output-dir-entry 2.0.1 schema for the files and directories in the tso500 post-processing pipeline.

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../expressions/get-custom-output-dir-entry-for-tso500-with-post-processing/2.0.1/get-custom-output-dir-entry-for-tso500-with-post-processing__2.0.1.cwl)  


### Used By
  
- [tso500-ctdna-with-post-processing-pipeline 1.1.0--1.0.0](../../../workflows/tso500-ctdna-with-post-processing-pipeline/1.1.0--1.0.0/tso500-ctdna-with-post-processing-pipeline__1.1.0--1.0.0.md)  

  


## get-custom-output-dir-entry-for-tso500-with-post-processing v(2.0.1) Inputs

### per sample post processing output dirs



  
> ID: per_sample_post_processing_output_dirs
  
**Optional:** `False`  
**Type:** `Directory[]`  
**Docs:**  
The per sample post processing output directories


### results dir



  
> ID: results_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The results directory from the tso500 workflow


### samplesheet



  
> ID: samplesheet_csv
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The intermediate samplesheet

  


## get-custom-output-dir-entry-for-tso500-with-post-processing v(2.0.1) Outputs

### tso500 output dir entry list



  
> ID: get-custom-output-dir-entry-for-tso500-with-post-processing--2.0.1/tso500_output_dir_entry_list  

  
**Optional:** `False`  
**Output Type:** `custom-output-dir-entry[]`  
**Docs:**  
The list of custom output dir entry schemas to use as input to custom-dir-entry list
  

  

