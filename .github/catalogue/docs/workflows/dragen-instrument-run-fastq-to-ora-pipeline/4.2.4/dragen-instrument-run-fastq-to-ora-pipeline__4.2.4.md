
dragen-instrument-run-fastq-to-ora-pipeline 4.2.4 workflow
==========================================================

## Table of Contents
  
- [Overview](#dragen-instrument-run-fastq-to-ora-v424-pipeline-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-instrument-run-fastq-to-ora-v424-pipeline-inputs)  
- [Steps](#dragen-instrument-run-fastq-to-ora-v424-pipeline-steps)  
- [Outputs](#dragen-instrument-run-fastq-to-ora-v424-pipeline-outputs)  
- [ICA](#ica)  


## dragen-instrument-run-fastq-to-ora v(4.2.4) pipeline Overview



  
> ID: dragen-instrument-run-fastq-to-ora-pipeline--4.2.4  
> md5sum: 72e2437257db521bcbee4460e6a1fa63

### dragen-instrument-run-fastq-to-ora v(4.2.4) pipeline documentation
  
This tool can be used for archiving purposes by first compressing fastqs prior to transfer to a long-term storage location.

### Categories
  


## Visual Workflow Overview
  
[![dragen-instrument-run-fastq-to-ora-pipeline__4.2.4.svg](../../../../images/workflows/dragen-instrument-run-fastq-to-ora-pipeline/4.2.4/dragen-instrument-run-fastq-to-ora-pipeline__4.2.4.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/dragen-instrument-run-fastq-to-ora-pipeline/4.2.4/dragen-instrument-run-fastq-to-ora-pipeline__4.2.4.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/dragen-instrument-run-fastq-to-ora-pipeline/4.2.4/dragen-instrument-run-fastq-to-ora-pipeline__4.2.4.cwl)  


### Uses
  
- [dragen-instrument-run-fastq-to-ora 4.2.4](../../../tools/dragen-instrument-run-fastq-to-ora/4.2.4/dragen-instrument-run-fastq-to-ora__4.2.4.md)  

  


## dragen-instrument-run-fastq-to-ora v(4.2.4) pipeline Inputs

### instrument run directory



  
> ID: instrument_run_directory
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The directory containing the instrument run. Expected to be in the BCLConvert 4.2.7 output format, with the following structure:
  Reports/
  InterOp/
  Logs/
  Samples/
  Samples/Lane_1/
  Samples/Lane_1/Sample_ID/
  Samples/Lane_1/Sample_ID/Sample_ID_S1_L001_R1_001.fastq.gz
  Samples/Lane_1/Sample_ID/Sample_ID_S1_L001_R2_001.fastq.gz
  etc...


### ora check file integrity



  
> ID: ora_check_file_integrity
  
**Optional:** `False`  
**Type:** `boolean`  
**Docs:**  
Set to true to perform and output result of FASTQ file and decompressed FASTQ.ORA integrity check. The default value is false.


### ora parallel files



  
> ID: ora_parallel_files
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
The number of files to compress in parallel. If using an FPGA medium instance in the 
run_dragen_instrument_run_fastq_to_ora_step this should be set to 16 / ora_threads_per_file.


### ora print file info



  
> ID: ora_print_file_info
  
**Optional:** `False`  
**Type:** `boolean`  
**Docs:**  
Prints file information summary of ORA compressed files.


### ora reference



  
> ID: ora_reference
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The reference tar to use for the ORA compression


### ora threads per file



  
> ID: ora_threads_per_file
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
The number of threads to use per file. If using an FPGA medium instance in the 
run_dragen_instrument_run_fastq_to_ora_step this should be set to 4 since there are only 16 cores available


### sample id list



  
> ID: sample_id_list
  
**Optional:** `True`  
**Type:** `.[]`  
**Docs:**  
Optional list of samples to process.  
Samples NOT in this list are NOT compressed AND NOT transferred to the final output directory!

  


## dragen-instrument-run-fastq-to-ora v(4.2.4) pipeline Steps

### Run Dragen Instrument Run Fastq to ORA


  
> ID: dragen-instrument-run-fastq-to-ora-pipeline--4.2.4/run_dragen_instrument_run_fastq_to_ora_step
  
**Step Type:** tool  
**Docs:**
  
Run the dragen instrument run fastq to ora tool

#### Links
  
[CWL File Path](../../../../../../tools/dragen-instrument-run-fastq-to-ora/4.2.4/dragen-instrument-run-fastq-to-ora__4.2.4.cwl)  
[CWL File Help Page](../../../tools/dragen-instrument-run-fastq-to-ora/4.2.4/dragen-instrument-run-fastq-to-ora__4.2.4.md)  


## dragen-instrument-run-fastq-to-ora v(4.2.4) pipeline Outputs

### output directory



  
> ID: dragen-instrument-run-fastq-to-ora-pipeline--4.2.4/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory of the instrument run with fastqs converted to oras
  

  

