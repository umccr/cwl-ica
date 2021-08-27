
mosdepth 0.3.1 tool
===================

## Table of Contents
  
- [Overview](#mosdepth-v031-overview)  
- [Links](#related-links)  
- [Inputs](#mosdepth-v031-inputs)  
- [Outputs](#mosdepth-v031-outputs)  
- [ICA](#ica)  


## mosdepth v(0.3.1) Overview



  
> ID: mosdepth--0.3.1  
> md5sum: e436b2ed4f540260fbe23d9083d4f9d4

### mosdepth v(0.3.1) documentation
  
Output per-base depth in an easy to read format.

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/mosdepth/0.3.1/mosdepth__0.3.1.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## mosdepth v(0.3.1) Inputs

### bam sorted



  
> ID: bam_sorted
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Sorted bam file


### by



  
> ID: by
  
**Optional:** `True`  
**Type:** `['File', 'string']`  
**Docs:**  
Optional BED file or (integer) window-sizes.


### chrom



  
> ID: chrom
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Chromosome to restrict depth calculation.


### fast mode



  
> ID: fast_mode
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Dont look at internal cigar operations or correct mate overlaps (recommended for most use-cases).


### flag



  
> ID: flag
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Exclude reads with any of the bits in FLAG set [default: 1796]


### include flag



  
> ID: include_flag
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Only include reads with any of the bits in FLAG set. default is unset. [default: 0]


### mapq



  
> ID: mapq
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Mapping quality threshold. reads with a quality less than this value are ignored [default: 0]


### no per base



  
> ID: no_per_base
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Dont output per-base depth. skipping this output will speed execution substantially.
Prefer quantized or thresholded values if possible.


### prefix



  
> ID: prefix
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Prefix for output files


### quantize



  
> ID: quantize
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Write quantized output see docs for description.


### read groups



  
> ID: read_groups
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Only calculate depth for these comma-separated read groups IDs.


### threads



  
> ID: threads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Number of BAM decompression threads [default: 0]


### thresholds



  
> ID: thresholds
  
**Optional:** `True`  
**Type:** `int[]`  
**Docs:**  
For each interval in --by, write number of bases covered by at least threshold bases.
Specify multiple integer values separated by ','.


### use median



  
> ID: use_median
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Output median of each region (in --by) instead of mean.

  


## mosdepth v(0.3.1) Outputs

### dist txt



  
> ID: mosdepth--0.3.1/global_dist_txt  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output Global Distributions
  


### per base bed gz



  
> ID: mosdepth--0.3.1/per_base_bed_gz  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Per base bed gz file (unless -n/--no-per-base is specified)
  


### per base bed gz



  
> ID: mosdepth--0.3.1/quantized_bed_gz  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Quantized bed gz file (if --quantize is specified)
  


### dist txt



  
> ID: mosdepth--0.3.1/region_dist  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Output Region Distributions (if --by is specified)
  


### regions bed gz



  
> ID: mosdepth--0.3.1/regions_bed_gz  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Regions bed gz file  (if --by is specified)
  


### summary txt



  
> ID: mosdepth--0.3.1/summary_txt  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Summary text file
  


### thresholds bed gz



  
> ID: mosdepth--0.3.1/thresholds_bed_gz  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Compressed output bed file with thresholds provided (if --thresholds is specified)
  

  

