
tso500-ctdna-analysis-workflow 1.1.0--120 tool
==============================================

## Table of Contents
  
- [Overview](#tso500-ctdna-analysis-workflow-v110120-overview)  
- [Links](#related-links)  
- [Inputs](#tso500-ctdna-analysis-workflow-v110120-inputs)  
- [Outputs](#tso500-ctdna-analysis-workflow-v110120-outputs)  
- [ICA](#ica)  


## tso500-ctdna-analysis-workflow v(1.1.0.120) Overview



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120  
> md5sum: 165dca533f7d97c3bfc3f318a1957074

### tso500-ctdna-analysis-workflow v(1.1.0.120) documentation
  
Runs the ctDNA analysis workflow v(1.1.0.120)

### Categories
  
- tso500  


## Related Links
  
- [CWL File Path](../../../../../../tools/tso500-ctdna-analysis-workflow/1.1.0--120/tso500-ctdna-analysis-workflow__1.1.0--120.cwl)  


### Used By
  
- [tso500-ctdna 1.1.0--120](../../../workflows/tso500-ctdna/1.1.0--120/tso500-ctdna__1.1.0--120.md)  

  


## tso500-ctdna-analysis-workflow v(1.1.0.120) Inputs

### dragen license key



  
> ID: dragen_license_key
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
File containing the dragen license


### fastq list rows



  
> ID: fastq_list_rows
  
**Optional:** `False`  
**Type:** `fastq-list-row[]`  
**Docs:**  
A list of fastq list rows where each element has the following attributes
* rgid  # Not used
* rgsm
* rglb  # Not used
* read_1
* read_2


### fastq validation dsdm



  
> ID: fastq_validation_dsdm
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Output of demux workflow. Contains steps for each sample id to run


### output dirname



  
> ID: output_dirname
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Output directory name (optional)


### resources dir



  
> ID: resources_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The directory of resources


### tso500 samples



  
> ID: tso500_samples
  
**Optional:** `False`  
**Type:** `tso500-sample[]`  
**Docs:**  
A list of tso500 samples each element has the following attributes:
* sample_id
* sample_type
* pair_id

  


## tso500-ctdna-analysis-workflow v(1.1.0.120) Outputs

### align collapse fusion caller dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/align_collapse_fusion_caller_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for align collapse fusion caller step
  


### annotation dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/annotation_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for annotation step
  


### cnv caller dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/cnv_caller_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for cnv caller step
  


### contamination dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/contamination_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for contamination step
  


### contamination dsdm



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/contamination_dsdm  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Contamination dsdm json, used as input for Reporting task
  


### dna fusion filtering dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/dna_fusion_filtering_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for dna fusion filtering step
  


### dna qc metrics dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/dna_qc_metrics_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for dna qc metrics step
  


### max somatic vaf dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/max_somatic_vaf_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for max somatic vaf step
  


### merged annotation dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/merged_annotation_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for merged annotation step
  


### msi dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/msi_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for msi step
  


### output directory



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/output_dir  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Output files
  


### phased variants dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/phased_variants_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for phased variants step
  


### small variant filter dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/small_variant_filter_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for small variants filter step
  


### stitched realigned dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/stitched_realigned_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for stitched realigned step
  


### tmb dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/tmb_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for tmb step
  


### variant caller dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/variant_caller_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for variant caller step
  


### variant matching dir



  
> ID: tso500-ctdna-analysis-workflow--1.1.0.120/variant_matching_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output directory for variant matching step
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  
- [collab-illumina-dev_workflows](#project-collab-illumina-dev_workflows)  


### Project: development_workflows


> wfl id: wfl.867aabc177344a40ae61ef868ddd3c98  

  
**workflow name:** tso500-ctdna-analysis-workflow_dev-wf  
**wfl version name:** 1.1.0--120  


### Project: collab-illumina-dev_workflows


> wfl id: wfl.544d209e70d1470b93ef0033ba201784  

  
**workflow name:** tso500-ctdna-analysis-workflow_clb-ilmn-dev  
**wfl version name:** 1.1.0--120  

  

