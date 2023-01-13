
dragen-wts-qc-pipeline 3.9.3 workflow
=====================================

## Table of Contents
  
- [Overview](#dragen-wts-qc-pipeline-v393-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-wts-qc-pipeline-v393-inputs)  
- [Steps](#dragen-wts-qc-pipeline-v393-steps)  
- [Outputs](#dragen-wts-qc-pipeline-v393-outputs)  
- [ICA](#ica)  


## dragen-wts-qc-pipeline v(3.9.3) Overview



  
> ID: dragen-wts-qc-pipeline--3.9.3  
> md5sum: 630ba20e9f70fedd1adbdd77c39086bd

### dragen-wts-qc-pipeline v(3.9.3) documentation
  
Workflow takes in dragen param along with object store version of a fastq_list.csv equivalent.
See the fastq_list_row schema definitions for more information.
Additonally runs qualimap step to genrate QC metrics.
More information on the documentation can be found [here](https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/DRAGEN/TPipelineIntro_fDG.htm)

### Categories
  


## Visual Workflow Overview
  
[![dragen-wts-qc-pipeline__3.9.3.svg](../../../../images/workflows/dragen-wts-qc-pipeline/3.9.3/dragen-wts-qc-pipeline__3.9.3.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/dragen-wts-qc-pipeline/3.9.3/dragen-wts-qc-pipeline__3.9.3.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/dragen-wts-qc-pipeline/3.9.3/dragen-wts-qc-pipeline__3.9.3.cwl)  


### Uses
  
- [dragen-transcriptome 3.9.3](../../../tools/dragen-transcriptome/3.9.3/dragen-transcriptome__3.9.3.md)  
- [qualimap 2.2.2](../../../tools/qualimap/2.2.2/qualimap__2.2.2.md)  

  


## dragen-wts-qc-pipeline v(3.9.3) Inputs

### algorithm



  
> ID: algorithm
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Counting algorithm:
uniquely-mapped-reads(default) or proportional.


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
Optional - Enable the DRAGEN Gene Fusion module - defaults to true


### enable rna quantification



  
> ID: enable_rna_quantification
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Optional - Enable the quantification module - defaults to true


### fastq list



  
> ID: fastq_list
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
CSV file that contains a list of FASTQ files
to process. read_1 and read_2 components in the CSV file must be presigned urls.


### Row of fastq lists



  
> ID: fastq_list_rows
  
**Optional:** `True`  
**Type:** `fastq-list-row[]`  
**Docs:**  
The row of fastq lists.
Each row has the following attributes:
  * RGID
  * RGLB
  * RGSM
  * Lane
  * Read1File
  * Read2File (optional)


### java mem



  
> ID: java_mem
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Set desired Java heap memory size


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
The directory where all output files are placed


### output file prefix



  
> ID: output_file_prefix
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The prefix given to all output files


### reference tar



  
> ID: reference_tar
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to ref data tarball


### tmp dir



  
> ID: tmp_dir
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Qualimap creates temporary bam files when sorting by name, which takes up space in the system tmp dir (usually /tmp). 
This can be avoided by sorting the bam file by name before running Qualimap.

  


## dragen-wts-qc-pipeline v(3.9.3) Steps

### run dragen transcriptome step


  
> ID: dragen-wts-qc-pipeline--3.9.3/run_dragen_transcriptome_step
  
**Step Type:** tool  
**Docs:**
  
Runs the dragen transcriptome workflow on the FPGA.
Takes in a fastq list and corresponding mount paths from the predefined_mount_paths.
All other options avaiable at the top of the workflow

#### Links
  
[CWL File Path](../../../../../../tools/dragen-transcriptome/3.9.3/dragen-transcriptome__3.9.3.cwl)  
[CWL File Help Page](../../../tools/dragen-transcriptome/3.9.3/dragen-transcriptome__3.9.3.md)  


### run qualimap step


  
> ID: dragen-wts-qc-pipeline--3.9.3/run_qualimap_step
  
**Step Type:** tool  
**Docs:**
  
Run qualimap step to generate additional QC metrics

#### Links
  
[CWL File Path](../../../../../../tools/qualimap/2.2.2/qualimap__2.2.2.cwl)  
[CWL File Help Page](../../../tools/qualimap/2.2.2/qualimap__2.2.2.md)  


## dragen-wts-qc-pipeline v(3.9.3) Outputs

### dragen transcriptome output directory



  
> ID: dragen-wts-qc-pipeline--3.9.3/dragen_transcriptome_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing all transcriptome output files
  


### dragen transcriptome output directory



  
> ID: dragen-wts-qc-pipeline--3.9.3/qualimap_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing all transcriptome output files
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.a43d1dedadfd46719cb77e842f1f26eb  

  
**workflow name:** dragen-wts-qc-pipeline_dev-wf  
**wfl version name:** 3.9.3  

  

