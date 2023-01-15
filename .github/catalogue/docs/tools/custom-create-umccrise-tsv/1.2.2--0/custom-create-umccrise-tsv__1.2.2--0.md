
custom-create-umccrise-tsv 1.2.2--0 tool
========================================

## Table of Contents
  
- [Overview](#custom-create-umccrise-tsv-v122--0-overview)  
- [Links](#related-links)  
- [Inputs](#custom-create-umccrise-tsv-v122--0-inputs)  
- [Outputs](#custom-create-umccrise-tsv-v122--0-outputs)  
- [ICA](#ica)  


## custom-create-umccrise-tsv v(1.2.2--0) Overview



  
> ID: custom-create-umccrise-tsv--1.2.2--0  
> md5sum: c1bd3d953cb6f76f45ab1f1778ce0a20

### custom-create-umccrise-tsv v(1.2.2--0) documentation
  
Create umccrise tsv based on the mount paths. Take inputs as a json string and drop null columns.

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-create-umccrise-tsv/1.2.2--0/custom-create-umccrise-tsv__1.2.2--0.cwl)  


### Used By
  
- [umccrise-pipeline 1.2.2--0](../../../workflows/umccrise-pipeline/1.2.2--0/umccrise-pipeline__1.2.2--0.md)  
- [umccrise-pipeline 1.2.2--0](../../../workflows/umccrise-pipeline/1.2.2--0/umccrise-pipeline__1.2.2--0.md)  

  


## custom-create-umccrise-tsv v(1.2.2--0) Inputs

### input json strs



  
> ID: input_json_strs
  
**Optional:** `False`  
**Type:** `.[]`  
**Docs:**  
A list json strings as output from the the create-predefined-mount-paths-and-umccrise-row-from-umccrise-input-schema expression


### output file



  
> ID: output_file
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Name of the output file

  


## custom-create-umccrise-tsv v(1.2.2--0) Outputs

### umccrise input tsv



  
> ID: custom-create-umccrise-tsv--1.2.2--0/umccrise_input_tsv  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The umccrse input tsv file
  

  

