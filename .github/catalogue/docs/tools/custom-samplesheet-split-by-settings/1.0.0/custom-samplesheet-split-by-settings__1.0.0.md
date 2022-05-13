
custom-samplesheet-split-by-settings 1.0.0 tool
===============================================

## Table of Contents
  
- [Overview](#custom-samplesheet-split-by-settings-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-samplesheet-split-by-settings-v100-inputs)  
- [Outputs](#custom-samplesheet-split-by-settings-v100-outputs)  
- [ICA](#ica)  


## custom-samplesheet-split-by-settings v(1.0.0) Overview



  
> ID: custom-samplesheet-split-by-settings--1.0.0  
> md5sum: e9d319b22650d0205105a99c1f9039a9

### custom-samplesheet-split-by-settings v(1.0.0) documentation
  
Use before running bcl-convert workflow to ensure that the bclConvert workflow can run in parallel.
Samples will be split into separate samplesheets based on their cycles specification

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-samplesheet-split-by-settings/1.0.0/custom-samplesheet-split-by-settings__1.0.0.cwl)  


### Used By
  
- [bcl-conversion 3.7.5](../../../workflows/bcl-conversion/3.7.5/bcl-conversion__3.7.5.md)  

  


## custom-samplesheet-split-by-settings v(1.0.0) Inputs

### ignore missing samples



  
> ID: ignore_missing_samples
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Don't raise an error if samples from the override cycles list are missing. Just remove them


### out dir



  
> ID: out_dir
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Where to place the output samplesheet csv files


### samplesheet csv



  
> ID: samplesheet_csv
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
The path to the original samplesheet csv file


### samplesheet format



  
> ID: samplesheet_format
  
**Optional:** `True`  
**Type:** `[ v1 | v2 ]`  
**Docs:**  
Set samplesheet to be in v1 or v2 format


### settings by samples



  
> ID: settings_by_samples
  
**Optional:** `True`  
**Type:** `settings-by-samples[]`  
**Docs:**  
Takes in an object form of settings by samples. This is used to split samplesheets

  


## custom-samplesheet-split-by-settings v(1.0.0) Outputs

### samplesheets outdir



  
> ID: custom-samplesheet-split-by-settings--1.0.0/samplesheet_outdir  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Directory of samplesheets
  


### output samplesheets



  
> ID: custom-samplesheet-split-by-settings--1.0.0/samplesheets  

  
**Optional:** `False`  
**Output Type:** `File[]`  
**Docs:**  
List of output samplesheets
  

  

