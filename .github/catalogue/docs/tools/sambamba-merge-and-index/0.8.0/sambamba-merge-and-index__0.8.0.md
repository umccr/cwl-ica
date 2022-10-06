
sambamba-merge-and-index 0.8.0 tool
===================================

## Table of Contents
  
- [Overview](#sambamba-merge-and-index-v080-overview)  
- [Links](#related-links)  
- [Inputs](#sambamba-merge-and-index-v080-inputs)  
- [Outputs](#sambamba-merge-and-index-v080-outputs)  
- [ICA](#ica)  


## sambamba-merge-and-index v(0.8.0) Overview



  
> ID: sambamba-merge-and-index--0.8.0  
> md5sum: ecae41fe6c2238a8a475e936c115e2b1

### sambamba-merge-and-index v(0.8.0) documentation
  
Merge a list of bam files and then index the merged bam file
Uses sambamba merge command.
More info can be found [here](https://lomereiter.github.io/sambamba/docs/sambamba-merge.html)

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/sambamba-merge-and-index/0.8.0/sambamba-merge-and-index__0.8.0.cwl)  


### Used By
  
- [optitype-pipeline 1.3.5](../../../workflows/optitype-pipeline/1.3.5/optitype-pipeline__1.3.5.md)  

  


## sambamba-merge-and-index v(0.8.0) Inputs

### bams sorted



  
> ID: bams_sorted
  
**Optional:** `False`  
**Type:** `File[]`  
**Docs:**  
Array of sorted bam files


### compression level



  
> ID: compression_level
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
level of compression for sorted BAM, from 0 to 9


### filter



  
> ID: filter
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Keep only reads that satisfy FILTER


### nthreads



  
> ID: nthreads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Use specified number of threads


### output filename



  
> ID: output_filename
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Name of merged output bam

  


## sambamba-merge-and-index v(0.8.0) Outputs

### output bam



  
> ID: sambamba-merge-and-index--0.8.0/bam_indexed  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output indexed bam file
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.84d02a51ca1e4f4091a18ab73b1d3f73  

  
**workflow name:** sambamba-merge-and-index_dev-wf  
**wfl version name:** 0.8.0  

  

