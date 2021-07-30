
sambamba-view-and-index 0.8.0 tool
==================================

## Table of Contents
  
- [Overview](#sambamba-view-and-index-v080-overview)  
- [Links](#related-links)  
- [Inputs](#sambamba-view-and-index-v080-inputs)  
- [Outputs](#sambamba-view-and-index-v080-outputs)  
- [ICA](#ica)  


## sambamba-view-and-index v(0.8.0) Overview



  
> ID: sambamba-view-and-index--0.8.0  
> md5sum: 5e4f3c81211efefcf6bc23fb59bb2ab1

### sambamba-view-and-index v(0.8.0) documentation
  
Get specific reads through filter step.
Docs can be found [here](https://lomereiter.github.io/sambamba/docs/sambamba-view.html).

### Categories
  
- bam handler  


## Related Links
  
- [CWL File Path](../../../../../../tools/sambamba-view-and-index/0.8.0/sambamba-view-and-index__0.8.0.cwl)  


### Used By
  
- [optitype-pipeline 1.3.5](../../../workflows/optitype-pipeline/1.3.5/optitype-pipeline__1.3.5.md)  

  


## sambamba-view-and-index v(0.8.0) Inputs

### Bam Sorted



  
> ID: bam_sorted
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Input, sorted and indexed bam file we wish to filter on


### compression level



  
> ID: compression_level
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specify compression level (from 0 to 9, works only for bam output)


### filter



  
> ID: filter
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
set custom filter for alignments


### Number of threads



  
> ID: nthreads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
The number of threads used


### num filter



  
> ID: num_filter
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
filter flag bits; 'i1/i2' corresponds to -f i1 -F i2 samtools arguments;
either of the numbers can be omitted


### Output filename



  
> ID: output_filename
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Name of the output file


### Output file format



  
> ID: output_format
  
**Optional:** `True`  
**Type:** `<cwl_utils.parser_v1_1.CommandInputEnumSchema object at 0x7f26e5a9e5b0>`  
**Docs:**  
The output file format of the filtered bam file.
Can be bam, sam or cram. Sam by default.


### regions



  
> ID: regions
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
output only reads overlapping one of regions from the BED file


### subsample



  
> ID: subsample
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
subsample reads (read pairs)


### subsample seed



  
> ID: subsample_seed
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
set seed for subsampling


### valid



  
> ID: valid
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Output only valid alignments


### with header



  
> ID: with_header
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
print header before reads (always done for BAM output)

  


## sambamba-view-and-index v(0.8.0) Outputs

### bam indexed



  
> ID: sambamba-view-and-index--0.8.0/bam_indexed  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output indexed bam file
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.6304aa7f0fcb4a97a29ab27262383281  

  
**workflow name:** sambamba-view-and-index_dev-wf  
**wfl version name:** 0.8.0  

  

