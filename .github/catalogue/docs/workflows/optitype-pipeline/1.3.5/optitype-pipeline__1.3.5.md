
optitype-pipeline 1.3.5 workflow
================================

## Table of Contents
  
- [Overview](#optitype-pipeline-v135-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#optitype-pipeline-v135-inputs)  
- [Steps](#optitype-pipeline-v135-steps)  
- [Outputs](#optitype-pipeline-v135-outputs)  
- [ICA](#ica)  


## optitype-pipeline v(1.3.5) Overview



  
> ID: optitype-pipeline--1.3.5  
> md5sum: ec5b9d1e7562766d5cd2ead920eb4381

### optitype-pipeline v(1.3.5) documentation
  
This is the Optitype QC workflow.
We take in a regions bed file that contains our HLA regions
We use sambamba slice to take these to a region specific hla bam
We use the unmapped reads, take a subset of no more than 1 million reads, and merge these to the region specific hla bam
The resulting bam file is converted to paired-end fastq reads
We then convert this bam file back to fastq and run through optitype v1.3.5 (with paired end data)

### Categories
  
- hla  


## Visual Workflow Overview
  
[![optitype-pipeline__1.3.5.svg](../../../../images/workflows/optitype-pipeline/1.3.5/optitype-pipeline__1.3.5.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/optitype-pipeline/1.3.5/optitype-pipeline__1.3.5.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/optitype-pipeline/1.3.5/optitype-pipeline__1.3.5.cwl)  


### Uses
  
- [sambamba-slice-and-index 0.8.0](../../../tools/sambamba-slice-and-index/0.8.0/sambamba-slice-and-index__0.8.0.md)  
- [sambamba-view-and-index 0.8.0](../../../tools/sambamba-view-and-index/0.8.0/sambamba-view-and-index__0.8.0.md)  
- [sambamba-merge-and-index 0.8.0](../../../tools/sambamba-merge-and-index/0.8.0/sambamba-merge-and-index__0.8.0.md)  
- [optitype 1.3.5](../../../tools/optitype/1.3.5/optitype__1.3.5.md)  
- [sambamba-sort-and-index 0.8.0](../../../tools/sambamba-sort-and-index/0.8.0/sambamba-sort-and-index__0.8.0.md)  
- [custom-subset-bam 1.12.0](../../../tools/custom-subset-bam/1.12.0/custom-subset-bam__1.12.0.md)  
- [samtools-fastq 1.12.0 :construction:](../../../tools/samtools-fastq/1.12.0/samtools-fastq__1.12.0.md)  


### Used By
  
- [dragen-qc-hla-pipeline 3.7.5--1.3.5](../../dragen-qc-hla-pipeline/3.7.5--1.3.5/dragen-qc-hla-pipeline__3.7.5--1.3.5.md)  

  


## optitype-pipeline v(1.3.5) Inputs

### bam sorted



  
> ID: bam_sorted
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The path to the aligned bam file

### hla reference fasta



  
> ID: hla_reference_fasta
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The fasta file to align the hla reads to through razers3


### regions bed file



  
> ID: regions_bed
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The bed file used to slice the bam file
This should contain the HLA region on chrom 6 and any extra HLA contigs (for hg38)


### sample name



  
> ID: sample_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Used for file naming throughout workflow

  


## optitype-pipeline v(1.3.5) Steps

### get bam slice from bed


  
> ID: optitype-pipeline--1.3.5/get_bam_slice_from_bed_step
  
**Step Type:** tool  
**Docs:**
  
Takes in the sorted full bam and hla regions bed and returns
a subsetted bam by hla region

#### Links
  
[CWL File Path](../../../../../../tools/sambamba-slice-and-index/0.8.0/sambamba-slice-and-index__0.8.0.cwl)  
[CWL File Help Page](../../../tools/sambamba-slice-and-index/0.8.0/sambamba-slice-and-index__0.8.0.md)  


### get unmapped file from sorted bam


  
> ID: optitype-pipeline--1.3.5/get_unmapped_file_from_sorted_bam_step
  
**Step Type:** tool  
**Docs:**
  
Takes in a sorted unmapped file and returns a sorted bam

#### Links
  
[CWL File Path](../../../../../../tools/sambamba-view-and-index/0.8.0/sambamba-view-and-index__0.8.0.cwl)  
[CWL File Help Page](../../../tools/sambamba-view-and-index/0.8.0/sambamba-view-and-index__0.8.0.md)  


### merge hla and unmapped bam files


  
> ID: optitype-pipeline--1.3.5/merge_hla_and_unmapped_bam_files_step
  
**Step Type:** tool  
**Docs:**
  
Merge the hla and unmapped files into one sorted bam

#### Links
  
[CWL File Path](../../../../../../tools/sambamba-merge-and-index/0.8.0/sambamba-merge-and-index__0.8.0.cwl)  
[CWL File Help Page](../../../tools/sambamba-merge-and-index/0.8.0/sambamba-merge-and-index__0.8.0.md)  


### optitype step


  
> ID: optitype-pipeline--1.3.5/optitype_step
  
**Step Type:** tool  
**Docs:**
  
Run the optitype pipeline on our smaller fastq files

#### Links
  
[CWL File Path](../../../../../../tools/optitype/1.3.5/optitype__1.3.5.cwl)  
[CWL File Help Page](../../../tools/optitype/1.3.5/optitype__1.3.5.md)  


### Sort merged bam by name


  
> ID: optitype-pipeline--1.3.5/sort_merged_bam_by_name_step
  
**Step Type:** tool  
**Docs:**
  
Use sambamba sort to sort indexed bam by readname
This is a prerequisite for samtools-fastq when using paired data

#### Links
  
[CWL File Path](../../../../../../tools/sambamba-sort-and-index/0.8.0/sambamba-sort-and-index__0.8.0.cwl)  
[CWL File Help Page](../../../tools/sambamba-sort-and-index/0.8.0/sambamba-sort-and-index__0.8.0.md)  


### set unmapped file from sorted bam


  
> ID: optitype-pipeline--1.3.5/subset_unmapped_bam
  
**Step Type:** tool  
**Docs:**
  
Takes in a list of n reads and randomly reduces the bam to that number of reads

#### Links
  
[CWL File Path](../../../../../../tools/custom-subset-bam/1.12.0/custom-subset-bam__1.12.0.cwl)  
[CWL File Help Page](../../../tools/custom-subset-bam/1.12.0/custom-subset-bam__1.12.0.md)  


### unmapped and hla bam to fastq


  
> ID: optitype-pipeline--1.3.5/unmapped_and_hla_bam_to_fastq_step
  
**Step Type:** tool  
**Docs:**
  
Convert our truncated bam file to paired fastq files

#### Links
  
[CWL File Path](../../../../../../tools/samtools-fastq/1.12.0/samtools-fastq__1.12.0.cwl)  
[CWL File Help Page :construction:](../../../tools/samtools-fastq/1.12.0/samtools-fastq__1.12.0.md)  


## optitype-pipeline v(1.3.5) Outputs

### coverage plot



  
> ID: optitype-pipeline--1.3.5/coverage_plot  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The coverage plot output from the optitype directory. Can be used as a QC method for determining
how certain the allele prediction was.
  


### output directory



  
> ID: optitype-pipeline--1.3.5/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory of the optitype step
  


### result matrix



  
> ID: optitype-pipeline--1.3.5/result_matrix  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Subattribute of the optitype directory, contains the likelihood information for each HLA allele
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.e1332fc391564d93bfba7e206ab0ab3e  

  
**workflow name:** optitype-pipeline_dev-wf  
**wfl version name:** 1.3.5  

  

