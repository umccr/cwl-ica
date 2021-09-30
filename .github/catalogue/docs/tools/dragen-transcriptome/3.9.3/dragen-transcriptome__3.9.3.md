
dragen-transcriptome 3.9.3 tool
===============================

## Table of Contents
  
- [Overview](#dragen-transcriptome-v393-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-transcriptome-v393-inputs)  
- [Outputs](#dragen-transcriptome-v393-outputs)  
- [ICA](#ica)  


## dragen-transcriptome v(3.9.3) Overview



  
> ID: dragen-transcriptome--3.9.3  
> md5sum: d0398bddeb3b145fbd7f67ba9542f762

### dragen-transcriptome v(3.9.3) documentation
  
Documentation for dragen-transcriptome v3.9.3

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/dragen-transcriptome/3.9.3/dragen-transcriptome__3.9.3.cwl)  


### Used By
  
- [dragen-transcriptome-pipeline 3.9.3](../../../workflows/dragen-transcriptome-pipeline/3.9.3/dragen-transcriptome-pipeline__3.9.3.md)  

  


## dragen-transcriptome v(3.9.3) Inputs

### annotation file



  
> ID: annotation_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to annotation transcript file.


### enable duplicate marking



  
> ID: enable_duplicate_marking
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Mark identical alignments as duplicates


### enable map align output



  
> ID: enable_map_align_output
  
**Optional:** `True`  
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


### fastq list



  
> ID: fastq_list
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
CSV file that contains a list of FASTQ files
to process.
Read1File and Read2File may be presigned urls or use this in conjunction with
the fastq_list_mount_paths inputs.


### fastq list mount paths



  
> ID: fastq_list_mount_paths
  
**Optional:** `True`  
**Type:** `predefined-mount-path[]`  
**Docs:**  
Path to fastq list mount path.


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

  


## dragen-transcriptome v(3.9.3) Outputs

### dragen bam out



  
> ID: dragen-transcriptome--3.9.3/dragen_bam_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
The output bam file, exists only if --enable-map-align-output is set to true
  


### dragen transcriptome output directory



  
> ID: dragen-transcriptome--3.9.3/dragen_transcriptome_directory  

  
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
**wfl version name:** 3.9.3  

  

