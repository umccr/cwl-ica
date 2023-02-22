
umccrise-with-dragen-germline-pipeline 2.0.2--3.9.3 workflow
============================================================

## Table of Contents
  
- [Overview](#umccrise-with-dragen-germline-pipeline-v202--393-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#umccrise-with-dragen-germline-pipeline-v202--393-inputs)  
- [Steps](#umccrise-with-dragen-germline-pipeline-v202--393-steps)  
- [Outputs](#umccrise-with-dragen-germline-pipeline-v202--393-outputs)  
- [ICA](#ica)  


## umccrise-with-dragen-germline-pipeline v(2.0.2--3.9.3) Overview



  
> ID: umccrise-with-dragen-germline-pipeline--2.0.2--3.9.3  
> md5sum: 0feb4e21b93c06f73ebc0c9986f36323

### umccrise-with-dragen-germline-pipeline v(2.0.2--3.9.3) documentation
  
Run UMCCRise on a dragen-somatic output, but run germline on the normal fastqs first.
This means the inputs of this pipeline are:
1. Fastq list rows of the germline samples
2. An output directory from the dragen-somatic pipeline

3. Any additional umccrise parameters
4. Any additional germline parameters

### Categories
  


## Visual Workflow Overview
  
[![umccrise-with-dragen-germline-pipeline__2.0.2--3.9.3.svg](../../../../images/workflows/umccrise-with-dragen-germline-pipeline/2.0.2--3.9.3/umccrise-with-dragen-germline-pipeline__2.0.2--3.9.3.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/umccrise-with-dragen-germline-pipeline/2.0.2--3.9.3/umccrise-with-dragen-germline-pipeline__2.0.2--3.9.3.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/umccrise-with-dragen-germline-pipeline/2.0.2--3.9.3/umccrise-with-dragen-germline-pipeline__2.0.2--3.9.3.cwl)  


### Uses
  
- [get-file-from-directory-with-regex 1.0.0 :construction:](../../../expressions/get-file-from-directory-with-regex/1.0.0/get-file-from-directory-with-regex__1.0.0.md)  
- [custom-get-sample-name-from-bam-header 1.0.0 :construction:](../../../tools/custom-get-sample-name-from-bam-header/1.0.0/custom-get-sample-name-from-bam-header__1.0.0.md)  
- [dragen-germline-pipeline 3.9.3](../../dragen-germline-pipeline/3.9.3/dragen-germline-pipeline__3.9.3.md)  
- [umccrise 2.0.2--0](../../../tools/umccrise/2.0.2--0/umccrise__2.0.2--0.md)  

  


## umccrise-with-dragen-germline-pipeline v(2.0.2--3.9.3) Inputs

### dragen somatic directory



  
> ID: dragen_somatic_directory
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The output from the dragen somatic workflow


### enable duplicate marking



  
> ID: enable_duplicate_marking
  
**Optional:** `False`  
**Type:** `boolean`  
**Docs:**  
Enable the flagging of duplicate output
alignment records.


### fastq list rows germline



  
> ID: fastq_list_rows_germline
  
**Optional:** `False`  
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


### output directory germline



  
> ID: output_directory_germline
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The directory where all output files are placed


### output directory umccrise



  
> ID: output_directory_umccrise
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The name of the output directory used for umccrise step


### output file prefix germline



  
> ID: output_file_prefix_germline
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The prefix given to all output files


### reference tar germline



  
> ID: reference_tar_germline
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to ref data tarball


### reference tar umccrise



  
> ID: reference_tar_umccrise
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The reference tar ball for umccrise


### subject identifier umccrise



  
> ID: subject_identifier_umccrise
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The subject identifier for umccrise to use on output files

  


## umccrise-with-dragen-germline-pipeline v(2.0.2--3.9.3) Steps

### get tumor bam file from somatic directory


  
> ID: umccrise-with-dragen-germline-pipeline--2.0.2--3.9.3/get_tumor_bam_file_from_somatic_directory
  
**Step Type:** expression  
**Docs:**
  
Get the tumor bam file from the dragen somatic directory
(so we can then in turn get the sample name value from the bam header)

#### Links
  
[CWL File Path](../../../../../../expressions/get-file-from-directory-with-regex/1.0.0/get-file-from-directory-with-regex__1.0.0.cwl)  
[CWL File Help Page :construction:](../../../expressions/get-file-from-directory-with-regex/1.0.0/get-file-from-directory-with-regex__1.0.0.md)  


### get tumor name from bam header


  
> ID: umccrise-with-dragen-germline-pipeline--2.0.2--3.9.3/get_tumor_name_from_bam_header
  
**Step Type:** tool  
**Docs:**
  
Get the tumor name from the bam header.

#### Links
  
[CWL File Path](../../../../../../tools/custom-get-sample-name-from-bam-header/1.0.0/custom-get-sample-name-from-bam-header__1.0.0.cwl)  
[CWL File Help Page :construction:](../../../tools/custom-get-sample-name-from-bam-header/1.0.0/custom-get-sample-name-from-bam-header__1.0.0.md)  


### run dragen germline step


  
> ID: umccrise-with-dragen-germline-pipeline--2.0.2--3.9.3/run_dragen_germline_pipeline_step
  
**Step Type:** workflow  
**Docs:**
  
Run the dragen germline workflow against the normal fastq.

#### Links
  
[CWL File Path](../../../../../../workflows/dragen-germline-pipeline/3.9.3/dragen-germline-pipeline__3.9.3.cwl)  
[CWL File Help Page](../../dragen-germline-pipeline/3.9.3/dragen-germline-pipeline__3.9.3.md)
#### Subworkflow overview
  
[![dragen-germline-pipeline__3.9.3.svg](../../../../images/workflows/dragen-germline-pipeline/3.9.3/dragen-germline-pipeline__3.9.3.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/dragen-germline-pipeline/3.9.3/dragen-germline-pipeline__3.9.3.svg)  


### run umccrise pipeline step


  
> ID: umccrise-with-dragen-germline-pipeline--2.0.2--3.9.3/run_umccrise_pipeline_step
  
**Step Type:** tool  
**Docs:**
  
Run the umccrise pipeline using the input somatic directory and output from the dragen germline step

#### Links
  
[CWL File Path](../../../../../../tools/umccrise/2.0.2--0/umccrise__2.0.2--0.cwl)  
[CWL File Help Page](../../../tools/umccrise/2.0.2--0/umccrise__2.0.2--0.md)  


## umccrise-with-dragen-germline-pipeline v(2.0.2--3.9.3) Outputs

### umccrise output directory



  
> ID: umccrise-with-dragen-germline-pipeline--2.0.2--3.9.3/umccrise_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing all umccrise output files
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  
- [production_workflows](#project-production_workflows)  


### Project: development_workflows


> wfl id: wfl.e4cd73b0e6e941b3b48afe03a7b5dc43  

  
**workflow name:** umccrise-with-dragen-germline-pipeline_dev-wf  
**wfl version name:** 2.0.2--3.9.3  


### Project: production_workflows


> wfl id: wfl.7ed9c6014ac9498fbcbd4c17c28bc0d4  

  
**workflow name:** umccrise-with-dragen-germline-pipeline_prod-wf  
**wfl version name:** 2.0.2--3.9.3--8fdabfc  

  

