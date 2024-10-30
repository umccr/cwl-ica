
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
> md5sum: 446649b855aac94789ac8142821e07bf

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
The directory containing the fastq files.  
The fastq files are compressed using the ORA algorithm.


### license instance id location



  
> ID: lic_instance_id_location
  
**Optional:** `True`  
**Type:** `['File', 'string']`  
**Docs:**  
You may wish to place your own in.
Optional value, default set to /opt/instance-identity
which is a path inside the dragen container


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
The number of files to compress in parallel
ORA threads per file is set to 8 by default, 
so this value should represent 16 / number of cores available


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
The reference to use for the ORA compression


### ora threads per file



  
> ID: ora_threads_per_file
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
The number of threads to use per file. If using an FPGA medium instance in the 
run_dragen_instrument_run_fastq_to_ora_step this should be set to 4 since there are only 16 cores available


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
  

  

