
custom-tso500-make-region-coverage-qc 1.0.0 tool
================================================

## Table of Contents
  
- [Overview](#custom-tso500-make-region-coverage-qc-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-tso500-make-region-coverage-qc-v100-inputs)  
- [Outputs](#custom-tso500-make-region-coverage-qc-v100-outputs)  
- [ICA](#ica)  


## custom-tso500-make-region-coverage-qc v(1.0.0) Overview



  
> ID: custom-tso500-make-region-coverage-qc--1.0.0  
> md5sum: a31623745d53062c937c0af1540bc26f

### custom-tso500-make-region-coverage-qc v(1.0.0) documentation
  
Collate the proportions of regions whose average coverage is greater than thresh 'x'
Original CWL file [here](https://github.com/YinanWang16/tso500-ctdna-post-processing/blob/main/cwl/tools/mosdepth/mosdepth-thresholds-bed-to-target-region-coverage.cwl)

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-tso500-make-region-coverage-qc/1.0.0/custom-tso500-make-region-coverage-qc__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## custom-tso500-make-region-coverage-qc v(1.0.0) Inputs

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

  


## custom-tso500-make-region-coverage-qc v(1.0.0) Outputs

### target region coverage metrics



  
> ID: custom-tso500-make-region-coverage-qc--1.0.0/target_region_coverage_metrics  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Trans region output per target coverage threshold
  

  

