
create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema 1.2.1--0 expression
=======================================================================================

## Table of Contents
  
- [Overview](#create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema-v121--0-overview)  
- [Links](#related-links)  
- [Inputs](#create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema-v121--0-inputs)  
- [Outputs](#create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema-v121--0-outputs)  


## create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema v(1.2.1--0) Overview



  
> ID: create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema--1.2.1--0  
> md5sum: 7f54fc29af33f53fe80c391bd1ee2c9c

### create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema v(1.2.1--0) documentation
  
Create the predefined mount paths and the umccrise row json str from the umccrise schema.

The predefined mount paths have the following attributes:
  * file_obj | dir_obj
  * mount_path

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../expressions/create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema/1.2.1--0/create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema__1.2.1--0.cwl)  


### Used By
  
- [umccrise-pipeline 1.2.1--0](../../../workflows/umccrise-pipeline/1.2.1--0/umccrise-pipeline__1.2.1--0.md)  
- [umccrise-pipeline 1.2.1--0](../../../workflows/umccrise-pipeline/1.2.1--0/umccrise-pipeline__1.2.1--0.md)  

  


## create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema v(1.2.1--0) Inputs

### umccrise input rows



  
> ID: umccrise_input_rows
  
**Optional:** `False`  
**Type:** `umccrise-input[]`  
**Docs:**  
Array of umccrise input schemas

  


## create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema v(1.2.1--0) Outputs

### predefined mount paths



  
> ID: create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema--1.2.1--0/predefined_mount_paths  

  
**Optional:** `False`  
**Output Type:** `predefined-mount-path[]`  
**Docs:**  
Array of predefined mount paths to be mounted on the umccrise TES task
  


### umccrise input rows as json str



  
> ID: create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema--1.2.1--0/umccrise_input_rows_as_json_str  

  
**Optional:** `False`  
**Output Type:** `string[]`  
**Docs:**  
Array of jsonised strings ready to create the umccrise tsv
  

  

