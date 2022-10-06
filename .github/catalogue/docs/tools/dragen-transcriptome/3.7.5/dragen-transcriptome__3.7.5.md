
dragen-transcriptome 3.7.5 tool
===============================

## Table of Contents
  
- [Overview](#dragen-transcriptome-v375-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-transcriptome-v375-inputs)  
- [Outputs](#dragen-transcriptome-v375-outputs)  
- [ICA](#ica)  


## dragen-transcriptome v(3.7.5) Overview



  
> ID: dragen-transcriptome--3.7.5  
> md5sum: 01103e4fd6ce9fe7c9d95f5da93451fb

### dragen-transcriptome v(3.7.5) documentation
  
Run dragen transcriptome pipeline
v 3.7.5.
Workflow takes in two separate lists of object stor version of the fastq_list.csv equivalent
See the fastq_list_row schema definitions for more information.
More information on the documentation can be found [here](https://sapac.support.illumina.com/content/dam/illumina-support/help/Illumina_DRAGEN_Bio_IT_Platform_v3_7_1000000141465/Content/SW/Informatics/Dragen/GPipelineSomCom_appDRAG.htm)

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/dragen-transcriptome/3.7.5/dragen-transcriptome__3.7.5.cwl)  


### Used By
  
- [dragen-transcriptome-pipeline 3.7.5](../../../workflows/dragen-transcriptome-pipeline/3.7.5/dragen-transcriptome-pipeline__3.7.5.md)  

  


## dragen-transcriptome v(3.7.5) Inputs

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



  
> ID: rrna-filter-contig
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Specify the name of the rRNA sequences to use for filtering.

  


## dragen-transcriptome v(3.7.5) Outputs

### dragen bam out



  
> ID: dragen-transcriptome--3.7.5/dragen_bam_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
The output bam file, exists only if --enable-map-align-output is set to true
  


### dragen transcriptome output directory



  
> ID: dragen-transcriptome--3.7.5/dragen_transcriptome_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing all wts analysis output files
  

  

