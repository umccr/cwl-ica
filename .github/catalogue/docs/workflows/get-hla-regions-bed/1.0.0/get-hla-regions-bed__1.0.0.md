
get-hla-regions-bed 1.0.0 workflow
==================================

## Table of Contents
  
- [Overview](#get-hla-regions-bed-v100-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#get-hla-regions-bed-v100-inputs)  
- [Steps](#get-hla-regions-bed-v100-steps)  
- [Outputs](#get-hla-regions-bed-v100-outputs)  
- [ICA](#ica)  


## get-hla-regions-bed v(1.0.0) Overview



  
> ID: get-hla-regions-bed--1.0.0  
> md5sum: a18c47cf6a023de7ed0915ce8e1e951f

### get-hla-regions-bed v(1.0.0) documentation
  
Takes input of genome version and a reference file.
Returns a regions bed file from a list of contig objects
Step 1 -> Creates a contig object for hla region in chr6
Step 2 -> Creates a bed file from the contig object in step 1
Step 3 -> Uses the faidx file to create a bed file from the hla contigs
Step 4 -> Merges the list from step 2 and step 3 and creates a regions bed file

### Categories
  


## Visual Workflow Overview
  
[![get-hla-regions-bed__1.0.0.svg](../../../../images/workflows/get-hla-regions-bed/1.0.0/get-hla-regions-bed__1.0.0.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/get-hla-regions-bed/1.0.0/get-hla-regions-bed__1.0.0.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/get-hla-regions-bed/1.0.0/get-hla-regions-bed__1.0.0.cwl)  


### Uses
  
- [bedops 2.4.39](../../../tools/bedops/2.4.39/bedops__2.4.39.md)  
- [create-contig-obj-for-hla-chr6-region 1.0.0](../../../expressions/create-contig-obj-for-hla-chr6-region/1.0.0/create-contig-obj-for-hla-chr6-region__1.0.0.md)  
- [custom-create-regions-bed-from-contigs-list 1.0.0 :construction:](../../../tools/custom-create-regions-bed-from-contigs-list/1.0.0/custom-create-regions-bed-from-contigs-list__1.0.0.md)  
- [custom-hla-bed-from-faidx 1.0.0](../../../tools/custom-hla-bed-from-faidx/1.0.0/custom-hla-bed-from-faidx__1.0.0.md)  


### Used By
  
- [dragen-qc-hla-pipeline 3.7.5--1.3.5](../../dragen-qc-hla-pipeline/3.7.5--1.3.5/dragen-qc-hla-pipeline__3.7.5--1.3.5.md)  

  


## get-hla-regions-bed v(1.0.0) Inputs

### A reference faidx file



  
> ID: faidx_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
May be extracted from a secondary files reference file if this is a subworkflow


### name of the genome



  
> ID: genome_version
  
**Optional:** `False`  
**Type:** `[ hg38 | GRCh37 ]`  
**Docs:**  
The name of the genome determines the chr6 contig we create


### output regions bed file name



  
> ID: regions_bed_file
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Name of the output regions bed file we create

  


## get-hla-regions-bed v(1.0.0) Steps

### bedops merge step


  
> ID: get-hla-regions-bed--1.0.0/bedops_merge_step
  
**Step Type:** tool  
**Docs:**
  
Merge the chromosome 6 and hla bed files

#### Links
  
[CWL File Path](../../../../../../tools/bedops/2.4.39/bedops__2.4.39.cwl)  
[CWL File Help Page](../../../tools/bedops/2.4.39/bedops__2.4.39.md)  


### create contig obj for chr 6 step


  
> ID: get-hla-regions-bed--1.0.0/create_contig_obj_for_chr6_step
  
**Step Type:** expression  
**Docs:**
  
Creates a contig object for the hla region
in chr6 based on the reference type.

#### Links
  
[CWL File Path](../../../../../../expressions/create-contig-obj-for-hla-chr6-region/1.0.0/create-contig-obj-for-hla-chr6-region__1.0.0.cwl)  
[CWL File Help Page](../../../expressions/create-contig-obj-for-hla-chr6-region/1.0.0/create-contig-obj-for-hla-chr6-region__1.0.0.md)  


### create regions bed from contigs


  
> ID: get-hla-regions-bed--1.0.0/create_regions_bed_for_chr_6_hla_region_step
  
**Step Type:** tool  
**Docs:**
  
Merge the list of contigs from each the chr6 region and the hla_contigs

#### Links
  
[CWL File Path](../../../../../../tools/custom-create-regions-bed-from-contigs-list/1.0.0/custom-create-regions-bed-from-contigs-list__1.0.0.cwl)  
[CWL File Help Page :construction:](../../../tools/custom-create-regions-bed-from-contigs-list/1.0.0/custom-create-regions-bed-from-contigs-list__1.0.0.md)  


### create contig obj for hla contigs step


  
> ID: get-hla-regions-bed--1.0.0/create_regions_bed_for_hla_contigs_step
  
**Step Type:** tool  
**Docs:**
  
Creates a contig object for the hla regions.
Uses the faidx file in the input to search for HLA contigs

#### Links
  
[CWL File Path](../../../../../../tools/custom-hla-bed-from-faidx/1.0.0/custom-hla-bed-from-faidx__1.0.0.cwl)  
[CWL File Help Page](../../../tools/custom-hla-bed-from-faidx/1.0.0/custom-hla-bed-from-faidx__1.0.0.md)  


## get-hla-regions-bed v(1.0.0) Outputs

### output regions bed



  
> ID: get-hla-regions-bed--1.0.0/regions_bed  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The output regions bed file
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.4c8ce85b9d2f427bb08e288d0e915981  

  
**workflow name:** get-hla-regions-bed_dev-wf  
**wfl version name:** 1.0.0  

  

