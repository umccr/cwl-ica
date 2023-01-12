
multiqc 1.12.0 tool
===================

## Table of Contents
  
- [Overview](#multiqc-v1120-overview)  
- [Links](#related-links)  
- [Inputs](#multiqc-v1120-inputs)  
- [Outputs](#multiqc-v1120-outputs)  
- [ICA](#ica)  


## multiqc v(1.12.0) Overview



  
> ID: multiqc--1.12.0  
> md5sum: e0b47899b72228c48907da94c3f798b3

### multiqc v(1.12.0) documentation
  
Documentation for multiqc v1.12.0

### Categories
  
- qc  
- visual  


## Related Links
  
- [CWL File Path](../../../../../../tools/multiqc/1.12.0/multiqc__1.12.0.cwl)  


### Used By
  
- [dragen-germline-pipeline 3.9.3](../../../workflows/dragen-germline-pipeline/3.9.3/dragen-germline-pipeline__3.9.3.md)  
- [dragen-germline-pipeline 4.0.3](../../../workflows/dragen-germline-pipeline/4.0.3/dragen-germline-pipeline__4.0.3.md)  
- [dragen-somatic-pipeline 3.9.3](../../../workflows/dragen-somatic-pipeline/3.9.3/dragen-somatic-pipeline__3.9.3.md)  
- [dragen-somatic-pipeline 4.0.3](../../../workflows/dragen-somatic-pipeline/4.0.3/dragen-somatic-pipeline__4.0.3.md)  
- [dragen-transcriptome-pipeline 3.9.3](../../../workflows/dragen-transcriptome-pipeline/3.9.3/dragen-transcriptome-pipeline__3.9.3.md)  
- [dragen-transcriptome-pipeline 4.0.3](../../../workflows/dragen-transcriptome-pipeline/4.0.3/dragen-transcriptome-pipeline__4.0.3.md)  
- [dragen-alignment-pipeline 3.9.3](../../../workflows/dragen-alignment-pipeline/3.9.3/dragen-alignment-pipeline__3.9.3.md)  
- [dragen-alignment-pipeline 4.0.3](../../../workflows/dragen-alignment-pipeline/4.0.3/dragen-alignment-pipeline__4.0.3.md)  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  
- [bclconvert-with-qc-pipeline 4.0.3](../../../workflows/bclconvert-with-qc-pipeline/4.0.3/bclconvert-with-qc-pipeline__4.0.3.md)  
- [dragen-somatic-with-germline-pipeline 4.0.3](../../../workflows/dragen-somatic-with-germline-pipeline/4.0.3/dragen-somatic-with-germline-pipeline__4.0.3.md)  

  


## multiqc v(1.12.0) Inputs

### cl config



  
> ID: cl_config
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Override config from the cli


### comment



  
> ID: comment
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Custom comment, will be printed at the top of the report.


### config



  
> ID: config
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Configuration file for bclconvert


### dummy file



  
> ID: dummy_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
testing inputs stream logic
If used will set input mode to stream on ICA which
saves having to download the entire input folder


### input directories



  
> ID: input_directories
  
**Optional:** `False`  
**Type:** `.[]`  
**Docs:**  
The list of directories to place in the analysis


### output directory



  
> ID: output_directory_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The output directory


### output filename



  
> ID: output_filename
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Report filename in html format.
Defaults to 'multiqc-report.html"


### title



  
> ID: title
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Report title.
Printed as page header, used for filename if not otherwise specified.

  


## multiqc v(1.12.0) Outputs

### output directory



  
> ID: multiqc--1.12.0/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Directory that contains all multiqc analysis data
  


### output file



  
> ID: multiqc--1.12.0/output_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output html file
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.c2ca973c62a24066bf82f63715d66083  

  
**workflow name:** multiqc_dev-wf  
**wfl version name:** 1.12.0  

  

