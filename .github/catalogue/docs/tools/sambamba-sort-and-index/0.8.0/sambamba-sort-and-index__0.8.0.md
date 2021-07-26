
sambamba-sort-and-index 0.8.0 tool
==================================

## Table of Contents
  
- [Overview](#sambamba-sort-and-index-v080-overview)  
- [Links](#related-links)  
- [Inputs](#sambamba-sort-and-index-v080-inputs)  
- [Outputs](#sambamba-sort-and-index-v080-outputs)  
- [ICA](#ica)  


## sambamba-sort-and-index v(0.8.0) Overview



  
> ID: sambamba-sort-and-index--0.8.0  
> md5sum: 1a6a0ac845bfffcfb32242f7388315be

### sambamba-sort-and-index v(0.8.0) documentation
  
Sort a bam file and then index it.
Uses sambamba sort command.
More info can be found [here](https://lomereiter.github.io/sambamba/docs/sambamba-sort.html)

### Categories
  
- bam handler  


## Related Links
  
- [CWL File Path](../../../../../../tools/sambamba-sort-and-index/0.8.0/sambamba-sort-and-index__0.8.0.cwl)  


### Used By
  
- [optitype-pipeline 1.3.5](../../../workflows/optitype-pipeline/1.3.5/optitype-pipeline__1.3.5.md)  

  


## sambamba-sort-and-index v(0.8.0) Inputs

### bam unsorted



  
> ID: bam_unsorted
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Unsorted bam file


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


### memory limit



  
> ID: memory_limit
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
approximate total memory liimit for all threads


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
Name of sorted output bam


### sort by name



  
> ID: sort_by_name
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
sort by read name instead of coordinate (lexicographical order)


### uncompressed chunks



  
> ID: uncompressed_chunks
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
write sorted chunks as uncompressed BAM (default is writing with compression level 1),
that might be faster in some cases but uses more disk space

  


## sambamba-sort-and-index v(0.8.0) Outputs

### output bam



  
> ID: sambamba-sort-and-index--0.8.0/bam_sorted  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output indexed bam file
  

  


## ICA

### Project: development_workflows


> wfl id: wfl.68849cc2a7094f87abbd6e8483169bc2  

  
**workflow name:** sambamba-sort-and-index_dev-wf  
**wfl version name:** 0.8.0  

  

