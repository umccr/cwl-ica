
dragen-transcriptome 4.0.3 tool
===============================

## Table of Contents
  
- [Overview](#dragen-transcriptome-v403-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-transcriptome-v403-inputs)  
- [Outputs](#dragen-transcriptome-v403-outputs)  
- [ICA](#ica)  


## dragen-transcriptome v(4.0.3) Overview



  
> ID: dragen-transcriptome--4.0.3  
> md5sum: f0a750758164b77f1109b83b97c49249

### dragen-transcriptome v(4.0.3) documentation
  
Documentation for dragen-transcriptome v4.0.3

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/dragen-transcriptome/4.0.3/dragen-transcriptome__4.0.3.cwl)  


### Used By
  
- [dragen-transcriptome-pipeline 4.0.3](../../../workflows/dragen-transcriptome-pipeline/4.0.3/dragen-transcriptome-pipeline__4.0.3.md)  
- [dragen-wts-qc-pipeline 4.0.3](../../../workflows/dragen-wts-qc-pipeline/4.0.3/dragen-wts-qc-pipeline__4.0.3.md)  

  


## dragen-transcriptome v(4.0.3) Inputs

### annotation file



  
> ID: annotation_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to annotation transcript file.


### bam input



  
> ID: bam_input
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Input a BAM file for the Dragen RNA options


### enable duplicate marking



  
> ID: enable_duplicate_marking
  
**Optional:** `False`  
**Type:** `boolean`  
**Docs:**  
Mark identical alignments as duplicates


### enable map align



  
> ID: enable_map_align
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enabled by default.
Set this value to false if using bam_input


### enable map align output



  
> ID: enable_map_align_output
  
**Optional:** `False`  
**Type:** `boolean`  
**Docs:**  
Do you wish to have the output bam files present


### enable rna gene fusion



  
> ID: enable_rna_gene_fusion
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable the DRAGEN Gene Fusion module. The default value is true.


### enable rna quantification



  
> ID: enable_rna_quantification
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable the quantification module. The default value is true.


### enable rrna filtering



  
> ID: enable_rrna_filter
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Use the DRAGEN RNA pipeline to filter rRNA reads during alignment. The default value is false.


### enable sort



  
> ID: enable_sort
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
True by default, only set this to false if using --bam-input parameters


### fastq list



  
> ID: fastq_list
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
CSV file that contains a list of FASTQ files
to process. read_1 and read_2 components in the CSV file must be presigned urls.


### fastq list rows



  
> ID: fastq_list_rows
  
**Optional:** `True`  
**Type:** `fastq-list-row[]`  
**Docs:**  
Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects


### license instance id location



  
> ID: lic_instance_id_location
  
**Optional:** `True`  
**Type:** `['File', 'string']`  
**Docs:**  
You may wish to place your own in.
Optional value, default set to /opt/instance-identity
which is a path inside the dragen container


### output directory



  
> ID: output_directory
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The directory where all output files are placed.


### output file prefix



  
> ID: output_file_prefix
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The prefix given to all output files.


### reference tar



  
> ID: reference_tar
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to ref data tarball.


### name of the rRNA sequences to use for filtering



  
> ID: rrna_filter_contig
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Specify the name of the rRNA sequences to use for filtering.

  


## dragen-transcriptome v(4.0.3) Outputs

### dragen bam out



  
> ID: dragen-transcriptome--4.0.3/dragen_bam_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
The output bam file, exists only if --enable-map-align-output is set to true
  


### dragen transcriptome output directory



  
> ID: dragen-transcriptome--4.0.3/dragen_transcriptome_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing all wts analysis output files
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.1bdb5d1976474c39b8290d8b5dc0520e  

  
**workflow name:** dragen-transcriptome_dev-wf  
**wfl version name:** 4.0.3  

  

