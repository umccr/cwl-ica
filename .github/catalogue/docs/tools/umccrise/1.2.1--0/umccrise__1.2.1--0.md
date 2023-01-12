
umccrise 1.2.1--0 tool
======================

## Table of Contents
  
- [Overview](#umccrise-v121--0-overview)  
- [Links](#related-links)  
- [Inputs](#umccrise-v121--0-inputs)  
- [Outputs](#umccrise-v121--0-outputs)  
- [ICA](#ica)  


## umccrise v(1.2.1--0) Overview



  
> ID: umccrise--1.2.1--0  
> md5sum: 7d1337350a246321bbf08216908f5629

### umccrise v(1.2.1--0) documentation
  

Run the umccrise workflow

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/umccrise/1.2.1--0/umccrise__1.2.1--0.cwl)  


### Used By
  
- [umccrise-pipeline 1.2.1--0](../../../workflows/umccrise-pipeline/1.2.1--0/umccrise-pipeline__1.2.1--0.md)  
- [umccrise-pipeline 1.2.1--0](../../../workflows/umccrise-pipeline/1.2.1--0/umccrise-pipeline__1.2.1--0.md)  

  


## umccrise v(1.2.1--0) Inputs

### dag



  
> ID: dag
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Propagated to snakemake. Print the DAG of jobs in the dot language.


### debug



  
> ID: debug
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
More verbose messages


### dryrun



  
> ID: dryrun
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Propagated to snakemake. Prints rules and commands to be run without actually executing them.


### exclude



  
> ID: exclude
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Optionally, samples or batches to ignore


### genome



  
> ID: genome
  
**Optional:** `True`  
**Type:** `[ GRCh37 | hg38  ]`  
**Docs:**  
genome


### genomes_dir



  
> ID: genomes_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The reference data bundle for the umccrise tool


### min af



  
> ID: min_af
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
AF threshold to filter small variants (unless a known hotspot)


### output directory



  
> ID: output_directory_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The name of the output directory


### report



  
> ID: report
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Propagated to snakemake.
Create an HTML report with results and statistics.
The argument has to be a file path ending with ".html"


### resources



  
> ID: resources
  
**Optional:** `True`  
**Type:** `.[]`  
**Docs:**  
Can be used to limit the amount of memory allowed to be used


### sample



  
> ID: sample
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Optionally, specific sample or batch to process


### skip stage



  
> ID: skip_stage
  
**Optional:** `True`  
**Type:** `.[]`  
**Docs:**  
Optionally, stages to skip, e.g.: -E oncoviruses -E cpsr


### stage



  
> ID: stage
  
**Optional:** `True`  
**Type:** `.[]`  
**Docs:**  
Optionally, specific stage to run, e.g.: -T pcgr -T coverage -T structural -T small_variants


### threads



  
> ID: threads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Maximum number of cores to use at single time.
Defaults to runtime.cores


### umccrise tsv



  
> ID: umccrise_tsv
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
CSV file that contains the row of samples ready to process


### umccrise tsv mount paths



  
> ID: umccrise_tsv_mount_paths
  
**Optional:** `True`  
**Type:** `predefined-mount-path[]`  
**Docs:**  
Path to umccrise tsv mount path

  


## umccrise v(1.2.1--0) Outputs

### output directory



  
> ID: umccrise--1.2.1--0/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.af61d2b172e84cbfa85eaf184226db8b  

  
**workflow name:** umccrise_dev-wf  
**wfl version name:** 1.2.1--0  

  

