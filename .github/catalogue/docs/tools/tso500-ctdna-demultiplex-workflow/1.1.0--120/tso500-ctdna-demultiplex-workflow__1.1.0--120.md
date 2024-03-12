
tso500-ctdna-demultiplex-workflow 1.1.0--120 tool
=================================================

## Table of Contents
  
- [Overview](#tso500-ctdna-demultiplex-workflow-v110120-overview)  
- [Links](#related-links)  
- [Inputs](#tso500-ctdna-demultiplex-workflow-v110120-inputs)  
- [Outputs](#tso500-ctdna-demultiplex-workflow-v110120-outputs)  
- [ICA](#ica)  


## tso500-ctdna-demultiplex-workflow v(1.1.0.120) Overview



  
> ID: tso500-ctdna-demultiplex-workflow--1.1.0.120  
> md5sum: f5efc752a4de848f62d4ec44158cd318

### tso500-ctdna-demultiplex-workflow v(1.1.0.120) documentation
  
Runs the ctDNA demultiplex workflow from fastq stage (just the fastq validation task)
Techinally the following steps are run:
* FindDragenLicenseTask
* FindDragenLicenstInstanceLocationTask
* ResetFPGATask
* SampleSheetValidationTask
* ResourceVerificationTask
* RunQcTask  # Skipped since fastqs present
* FastqGenerationTask  # Skipped since fastqs present
* FastqValidationTask
This tool does NOT require the tso500 data to have the fastq files in a per 'folder' level like the ISL workflow.
You instead use the tso500-sample schema and the fastq-list-row schema to mount the gds paths into the container
as the WDL workflow expects them (mimicking the ISL workflow task inputs).

### Categories
  
- tso500  


## Related Links
  
- [CWL File Path](../../../../../../tools/tso500-ctdna-demultiplex-workflow/1.1.0--120/tso500-ctdna-demultiplex-workflow__1.1.0--120.cwl)  


### Used By
  
- [tso500-ctdna 1.1.0--120](../../../workflows/tso500-ctdna/1.1.0--120/tso500-ctdna__1.1.0--120.md)  

  


## tso500-ctdna-demultiplex-workflow v(1.1.0.120) Inputs

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


### resources dir



  
> ID: resources_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The directory of resources


### run info xml



  
> ID: run_info_xml
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The run info xml file found inside the run folder


### run parameters xml



  
> ID: run_parameters_xml
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The run parameters xml file found inside the run folder


### sample sheet



  
> ID: samplesheet
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The sample sheet file. Special samplesheet type, must have the Sample_Type and Pair_ID columns in the [Data] section.
Even though we don't demultiplex, we still need the information on Sample_Type and Pair_ID to determine which
workflow (DNA / RNA) to run through.


### samplesheet prefix



  
> ID: samplesheet_prefix
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
If using a v2 samplesheet, this points to the TSO500 section of the samplesheet.
Leave blank for v1 samples.


### tso500 samples



  
> ID: tso500_samples
  
**Optional:** `False`  
**Type:** `tso500-sample[]`  
**Docs:**  
A list of tso500 samples each element has the following attributes:
* sample_id
* sample_type
* pair_id

  


## tso500-ctdna-demultiplex-workflow v(1.1.0.120) Outputs

### fastq_validation_dir



  
> ID: tso500-ctdna-demultiplex-workflow--1.1.0.120/fastq_validation_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output dir for fastq_validation_dir
  


### fastq validation dsdm



  
> ID: tso500-ctdna-demultiplex-workflow--1.1.0.120/fastq_validation_dsdm  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The fastq validation dsdm
  


### output dir



  
> ID: tso500-ctdna-demultiplex-workflow--1.1.0.120/output_dir  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory of all of the files
  


### output samplesheet



  
> ID: tso500-ctdna-demultiplex-workflow--1.1.0.120/output_samplesheet  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
AnalysisWorkflow ready sample sheet
  


### resource_verification_dir



  
> ID: tso500-ctdna-demultiplex-workflow--1.1.0.120/resource_verification_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output dir for resource_verification_dir
  


### samplesheet_validation_dir



  
> ID: tso500-ctdna-demultiplex-workflow--1.1.0.120/samplesheet_validation_dir  

  
**Optional:** `True`  
**Output Type:** `Directory`  
**Docs:**  
Intermediate output dir for samplesheet_validation_dir
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  
- [collab-illumina-dev_workflows](#project-collab-illumina-dev_workflows)  


### Project: development_workflows


> wfl id: wfl.fd8c8ddabe824ae3a730aa2ce926785d  

  
**workflow name:** tso500-ctdna-demultiplex-workflow_dev-wf  
**wfl version name:** 1.1.0--120  


### Project: collab-illumina-dev_workflows


> wfl id: wfl.0cf5fb870db44158876dd0849470f573  

  
**workflow name:** tso500-ctdna-demultiplex-workflow_clb-ilmn-dev  
**wfl version name:** 1.1.0--120  

  

