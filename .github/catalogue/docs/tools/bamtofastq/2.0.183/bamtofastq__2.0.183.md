
bamtofastq 2.0.183 tool
=======================

## Table of Contents
  
- [Overview](#bamtofastq-v20183-overview)  
- [Links](#related-links)  
- [Inputs](#bamtofastq-v20183-inputs)  
- [Outputs](#bamtofastq-v20183-outputs)  
- [ICA](#ica)  


## bamtofastq v(2.0.183) Overview



  
> ID: bamtofastq--2.0.183  
> md5sum: 285f32824cf04c589b666e86fa17df0c

### bamtofastq v(2.0.183) documentation
  
bamtofastq reads a SAM, BAM or CRAM file from standard input and converts it to the FastQ format. 
The output can be split into multiple files according to the pair flags of the reads involved. 
bamtofastq can collate the source reads according to their read names, i.e. place pairs of reads 
next to each other in the output. bamtofastq writes its output to the standard output channel by 
default. All output channels can be compressed using gzip.

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/bamtofastq/2.0.183/bamtofastq__2.0.183.cwl)  

  


## bamtofastq v(2.0.183) Inputs

### col h log



  
> ID: colh_log
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Base 2 logarithm of hash table size used for collation [18]


### collate



  
> ID: collate
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Collate pairs


### cols bs



  
> ID: cols_bs
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Size of hash table overflow list in bytes [33554432]


### combs



  
> ID: combs
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Print some counts after collation based processing


### disable validation



  
> ID: disable_validation
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Disable validation of input data [0]


### exclude



  
> ID: exclude
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Exclude alignments matching any of the given flags [SECONDARY,SUPPLEMENTARY]


### fasta



  
> ID: fasta
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Output FastA instead of FastQ


### file name



  
> ID: filename
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Input filename


### F1



  
> ID: first_mate
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Matched pairs first mates


### gz



  
> ID: gzip
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Compress output streams in gzip format (default: 0)


### input buffer size



  
> ID: input_buffer_size
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Size of input buffer


### input format



  
> ID: input_format
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Input format: cram, bam or sam [bam]


### level



  
> ID: level
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Compression setting if gz=1 (-1=zlib default,0=uncompressed,1=fast,9=best)


### output_dir



  
> ID: output_dir
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Output directory if outputperreadgroup=1. By default the output files are generated in the current directory.


### output per read group



  
> ID: output_per_readgroup
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Split output per read group (for collate=1 only)


### output per read group prefix



  
> ID: output_per_readgroup_prefix
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Prefix added in front of file names if outputperreadgroup=1 (for collate=1 only)


### output per readgroup rgsm



  
> ID: output_per_readgroup_rgsm
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Add read group field SM ahead of read group id when outputperreadgroup=1 (for collate=1 only)


### output per read group suffix F1



  
> ID: output_per_readgroup_suffix_f1
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Suffix for F category when outputperreadgroup=1 [_1.fq]


### output per read group suffix F2



  
> ID: output_per_readgroup_suffix_f2
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Suffix for F2 category when outputperreadgroup=1 [_2.fq]


### output per read group suffix O



  
> ID: output_per_readgroup_suffix_o1
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Suffix for O category when outputperreadgroup=1 [_o1.fq]


### output per read group suffix O2



  
> ID: output_per_readgroup_suffix_o2
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Suffix for O2 category when outputperreadgroup=1 [_o2.fq]


### output per read group suffix S



  
> ID: output_per_readgroup_suffix_s
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Suffix for S category when outputperreadgroup=1 [_s.fq]


### ranges



  
> ID: ranges
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Input ranges (bam and cram input only, default: read complete file)


### reference



  
> ID: reference
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Iame of reference FastA in case of inputformat=cram


### F2



  
> ID: second_mate
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Matched pairs second mates


### single end



  
> ID: single_end
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Single end


### split



  
> ID: split
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Split named output files into chunks of this amount of reads (0: do not split)


### split prefix



  
> ID: split_prefix
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
File name prefix if collate=0 and split>0


### tags



  
> ID: tags
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
List of aux tags to be copied (default: do not copy any aux fields)


### t



  
> ID: tmp_file_name
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Temporary file name [bamtofastq_*]


### try oq



  
> ID: try_oq
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Use OQ field instead of quality field if present (collate={0,1} only) [0]


### unmatched pairs first mate



  
> ID: unmatched_pairs_first_mate
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Unmatched pairs first mates


### unmatched pairs mate2



  
> ID: unmatched_pairs_second_mate
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Unmatched pairs second mates

  


## bamtofastq v(2.0.183) Outputs

### output dircetory



  
> ID: bamtofastq--2.0.183/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Output dircetory containing the fastq files
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.3b09abee043645bca8d13040825b12b5  

  
**workflow name:** bamtofastq_dev-wf  
**wfl version name:** 2.0.183  

  

