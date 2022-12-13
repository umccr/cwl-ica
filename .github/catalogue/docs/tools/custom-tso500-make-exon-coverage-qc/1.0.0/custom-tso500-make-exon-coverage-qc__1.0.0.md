
custom-tso500-make-exon-coverage-qc 1.0.0 tool
==============================================

## Table of Contents
  
- [Overview](#custom-tso500-make-exon-coverage-qc-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-tso500-make-exon-coverage-qc-v100-inputs)  
- [Outputs](#custom-tso500-make-exon-coverage-qc-v100-outputs)  
- [ICA](#ica)  


## custom-tso500-make-exon-coverage-qc v(1.0.0) Overview



  
> ID: custom-tso500-make-exon-coverage-qc--1.0.0  
> md5sum: e761277b9e28cf9b820471e217b72231

### custom-tso500-make-exon-coverage-qc v(1.0.0) documentation
  
Using the thresholds output from mosdepth, take in a tab delimited file of compressions and
reduce to those exons who've failed a fixed level of coverage.
The output of this cwl tool contains a header that is compatible with uploading the file to Pieriandx
Original CWL file [here](https://github.com/YinanWang16/tso500-ctdna-post-processing/blob/main/cwl/tools/mosdepth/mosdepth-thresholds-bed-to-coverage-QC-step.cwl)

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-tso500-make-exon-coverage-qc/1.0.0/custom-tso500-make-exon-coverage-qc__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## custom-tso500-make-exon-coverage-qc v(1.0.0) Inputs

### prefix



  
> ID: prefix
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Output prefix of the file


### threshhold bed file



  
> ID: threshold_bed_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Output from mosdepth

  


## custom-tso500-make-exon-coverage-qc v(1.0.0) Outputs

### failed qc coverage txt



  
> ID: custom-tso500-make-exon-coverage-qc--1.0.0/failed_coverage_txt  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The Failed QC exon coverage output file ready for upload to PierianDx
  

  

