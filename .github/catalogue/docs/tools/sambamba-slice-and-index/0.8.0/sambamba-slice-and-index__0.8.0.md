
sambamba-slice-and-index 0.8.0 tool
===================================

## Table of Contents
  
- [Overview](#sambamba-slice-and-index-v080-overview)  
- [Links](#related-links)  
- [Inputs](#sambamba-slice-and-index-v080-inputs)  
- [Outputs](#sambamba-slice-and-index-v080-outputs)  
- [ICA](#ica)  


## sambamba-slice-and-index v(0.8.0) Overview



  
> ID: sambamba-slice-and-index--0.8.0  
> md5sum: 85cb186f34a4c635c6a3ed9f5e1dc701

### sambamba-slice-and-index v(0.8.0) documentation
  
Slice a bam file (with a regions bed file for reference) and then index it.
Uses sambamba slice command.
More info can be found [here](https://lomereiter.github.io/sambamba/docs/sambamba-slice.html)

### Categories
  
- bam handler  


## Related Links
  
- [CWL File Path](../../../../../../tools/sambamba-slice-and-index/0.8.0/sambamba-slice-and-index__0.8.0.cwl)  


### Used By
  
- [optitype-pipeline 1.3.5](../../../workflows/optitype-pipeline/1.3.5/optitype-pipeline__1.3.5.md)  

  


## sambamba-slice-and-index v(0.8.0) Inputs

### bam sorted



  
> ID: bam_sorted
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Sorted bam file for input for slicing command


### output filename



  
> ID: output_filename
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Name of output bam


### regions bed



  
> ID: regions_bed
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
positions to subset
  


## sambamba-slice-and-index v(0.8.0) Outputs

### output bam



  
> ID: sambamba-slice-and-index--0.8.0/bam_indexed  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output indexed bam file
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.591b79cb43d0492380e3039ed5c517c0  

  
**workflow name:** sambamba-slice-and-index_dev-wf  
**wfl version name:** 0.8.0  

  

