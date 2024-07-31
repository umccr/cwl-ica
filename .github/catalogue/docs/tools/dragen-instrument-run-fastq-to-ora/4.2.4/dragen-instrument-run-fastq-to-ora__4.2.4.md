
dragen-instrument-run-fastq-to-ora 4.2.4 tool
=============================================

## Table of Contents
  
- [Overview](#dragen-instrument-run-fastq-to-ora-v424-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-instrument-run-fastq-to-ora-v424-inputs)  
- [Outputs](#dragen-instrument-run-fastq-to-ora-v424-outputs)  
- [ICA](#ica)  


## dragen-instrument-run-fastq-to-ora v(4.2.4) Overview



  
> ID: dragen-instrument-run-fastq-to-ora--4.2.4  
> md5sum: 22a735c0ef3f851322c8ce20ba2870c1

### dragen-instrument-run-fastq-to-ora v(4.2.4) documentation
  
Documentation for dragen-instrument-run-fastq-to-ora v4.2.4

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/dragen-instrument-run-fastq-to-ora/4.2.4/dragen-instrument-run-fastq-to-ora__4.2.4.cwl)  


### Used By
  
- [dragen-instrument-run-fastq-to-ora-pipeline 4.2.4](../../../workflows/dragen-instrument-run-fastq-to-ora-pipeline/4.2.4/dragen-instrument-run-fastq-to-ora-pipeline__4.2.4.md)  

  


## dragen-instrument-run-fastq-to-ora v(4.2.4) Inputs

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


### ora reference



  
> ID: ora_reference
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The reference to use for the ORA compression


### output directory name



  
> ID: output_directory_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The name of the output directory


### sample id list



  
> ID: sample_id_list
  
**Optional:** `True`  
**Type:** `.[]`  
**Docs:**  
Optional list of samples to process.  
Samples NOT in this list are NOT compressed AND NOT transferred to the final output directory!

  


## dragen-instrument-run-fastq-to-ora v(4.2.4) Outputs

### output directory



  
> ID: dragen-instrument-run-fastq-to-ora--4.2.4/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing the instrument run with compressed ORA files
  

  

