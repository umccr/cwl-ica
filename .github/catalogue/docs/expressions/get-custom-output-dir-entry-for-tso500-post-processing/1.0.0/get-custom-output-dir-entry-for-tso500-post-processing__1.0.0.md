
get-custom-output-dir-entry-for-tso500-post-processing 1.0.0 expression
=======================================================================

## Table of Contents
  
- [Overview](#get-custom-output-dir-entry-for-tso500-post-processing-v100-overview)  
- [Links](#related-links)  
- [Inputs](#get-custom-output-dir-entry-for-tso500-post-processing-v100-inputs)  
- [Outputs](#get-custom-output-dir-entry-for-tso500-post-processing-v100-outputs)  


## get-custom-output-dir-entry-for-tso500-post-processing v(1.0.0) Overview



  
> ID: get-custom-output-dir-entry-for-tso500-post-processing--1.0.0  
> md5sum: f5afc198579fa46d75969659d0680849

### get-custom-output-dir-entry-for-tso500-post-processing v(1.0.0) documentation
  
Create a custom-output-dir-entry 2.0.0 schema for the files and directories in the tso500 post-processing pipeline.

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../expressions/get-custom-output-dir-entry-for-tso500-post-processing/1.0.0/get-custom-output-dir-entry-for-tso500-post-processing__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## get-custom-output-dir-entry-for-tso500-post-processing v(1.0.0) Inputs

### align collapse fusion caller directory



  
> ID: align_collapse_fusion_caller_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The align collapse fusion caller directory
We collect the following outputs from this directory -
* The evidence bam file
* The raw bam file
* The clean-stitched bam file


### combined variant output dir



  
> ID: combined_variant_output_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
From this directory we collect the following outputs:
* CombinedVariantOutput.tsv


### compressed metrics tarball



  
> ID: compressed_metrics_tarball
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The tarball of compressed metrics files (and other csv files)
* tmb_trace_tsv
* fragment_length_hist_csv
* fusion csv
* output coverage qc file (compressed version)
* output target region qc file (compressed version)


### compressed reporting tarball



  
> ID: compressed_reporting_tarball
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The tarball of compressed reporting files
* msi_json
* tmb_json
* Sample analysis results json


### coverage qc file



  
> ID: coverage_qc_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The output from the make coverage qc step


### dragen metrics compressed json file



  
> ID: dragen_metrics_compressed_json_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Compressed dragen metrics file


### fusion csv



  
> ID: fusion_csv
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The fusion csv file


### merged annotation dir



  
> ID: merged_annotation_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The merged annotation dir
From this directory we collect the following outputs:
* The MergedSmallVariantsAnnotated compressed json file


### sample id



  
> ID: sample_id
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The sample id, important for extracting the bam files


### tmb dir



  
> ID: tmb_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The TMB directory
From this directory we collect the following outputs:
* The TMB Trace tsv


### Variant caller directory



  
> ID: variant_caller_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The variant caller directory
We collect the following outputs from this directory -
* The clean-stitched bam file


### vcf tarball



  
> ID: vcf_tarball
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The tarball of vcf files

  


## get-custom-output-dir-entry-for-tso500-post-processing v(1.0.0) Outputs

### tso500 output dir entry list



  
> ID: get-custom-output-dir-entry-for-tso500-post-processing--1.0.0/tso500_output_dir_entry_list  

  
**Optional:** `False`  
**Output Type:** `custom-output-dir-entry[]`  
**Docs:**  
The list of custom output dir entry schemas to use as input to custom-dir-entry list
  

  

