
samtools-merge 1.12.0 tool
==========================

## Table of Contents
  
- [Overview](#samtools-merge-v1120-overview)  
- [Links](#related-links)  
- [Inputs](#samtools-merge-v1120-inputs)  
- [Outputs](#samtools-merge-v1120-outputs)  
- [ICA](#ica)  


## samtools-merge v(1.12.0) Overview



  
> ID: samtools-merge--1.12.0  
> md5sum: 74616cdd0859b396f3824c4f44976b05

### samtools-merge v(1.12.0) documentation
  
Merge multiple sorted alignment files, producing a single sorted output file that contains all the input records
and maintains the existing sort order.
If -h is specified the @SQ headers of input files will be merged into the specified header,
otherwise they will be merged into a composite header created from the input headers. If in the process of merging @SQ lines for coordinate sorted input files, a conflict arises as to the order (for example input1.bam has @SQ for a,b,c and input2.bam has b,a,c) then the resulting output file will need to be re-sorted back into coordinate order.
Unless the -c or -p flags are specified then when merging @RG and @PG records into the output header then any IDs
found to be duplicates of existing IDs in the output header will have a suffix appended to them to differentiate
them from similar header records from other files and the read records will be updated to reflect this.
The ordering of the records in the input files must match the usage of the -n and -t command-line options.
If they do not, the output order will be undefined. See sort for information about record ordering.

### Categories
  
- bam handlers  


## Related Links
  
- [CWL File Path](../../../../../../tools/samtools-merge/1.12.0/samtools-merge__1.12.0.cwl)  

  


## samtools-merge v(1.12.0) Inputs

### attach rg tag



  
> ID: attach_rg_tag
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Attach RG tag (inferred from file names)


### combine pg headers



  
> ID: combine_pg_headers
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Combine @PG headers with colliding IDs [alter IDs to be distinct]


### combine rg headers



  
> ID: combine_rg_headers
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Combine @RG headers with colliding IDs [alter IDs to be distinct]


### compress level



  
> ID: compress_level
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Integer from 0-9 on compression level (default is -1 or uncompressed)


### copy header



  
> ID: copy_header
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Copy the header in FILE to <out.bam> [in1.bam]


### customise index files



  
> ID: customise_index_files
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Use customized index files


### merge region



  
> ID: merge_region
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Merge file in the specified region STR [all]


### no pg line



  
> ID: no_pg_line
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
do not add a PG line


### output bam name



  
> ID: output_bam_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The output bam file


### override random seed



  
> ID: override_random_seed
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Override random seed


### reference



  
> ID: reference
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Reference sequence FASTA FILE [null]


### region filtering



  
> ID: region_filtering
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specify a bed file for multiple region filtering


### sorted bams



  
> ID: sorted_bams
  
**Optional:** `False`  
**Type:** `.[]`  
**Docs:**  
List of sorted bam files


### sorted by read name



  
> ID: sorted_by_read_name
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Input files are sorted by read name


### sorted by tag value



  
> ID: sorted_by_tag_value
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Input files are sorted by tag value


### threads



  
> ID: threads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Number of additional threads to use (set by runtime cores if not set here)


### uncompressed bam output



  
> ID: uncompressed_bam_output
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Write out BAM output as uncompressed BAM. Makes reading faster


### verbosity



  
> ID: verbosity
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Set level of verbosity


### write index



  
> ID: write_index
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Automatically index the output files

  


## samtools-merge v(1.12.0) Outputs

### output bam



  
> ID: samtools-merge--1.12.0/output_bam  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
The output bam file
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.a717e4b2ec484c4cab2910c813179738  

  
**workflow name:** samtools-merge_dev-wf  
**wfl version name:** 1.12.0  

  

