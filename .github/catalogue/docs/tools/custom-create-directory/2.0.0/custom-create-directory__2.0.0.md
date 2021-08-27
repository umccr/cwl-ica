
custom-create-directory 2.0.0 tool
==================================

## Table of Contents
  
- [Overview](#custom-create-directory-v200-overview)  
- [Links](#related-links)  
- [Inputs](#custom-create-directory-v200-inputs)  
- [Outputs](#custom-create-directory-v200-outputs)  
- [ICA](#ica)  


## custom-create-directory v(2.0.0) Overview



  
> ID: custom-create-directory--2.0.0  
> md5sum: 52557029b02ff7f5df78427603435985

### custom-create-directory v(2.0.0) documentation
  
Create a directory for output v2.0.0, uses the custom-output-dir-entry schema v2.0.0.
Can be of type - tarball, directory, filelist.
One can select a list of files from each directory, tarball to extract.
One can also select 'top_dir' or 'sub_dir' to determine if files go in the top directory or a sub directory.  

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-create-directory/2.0.0/custom-create-directory__2.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  
- [tso500-ctdna-with-post-processing-pipeline 1.1.0--1.0.0](../../../workflows/tso500-ctdna-with-post-processing-pipeline/1.1.0--1.0.0/tso500-ctdna-with-post-processing-pipeline__1.1.0--1.0.0.md)  

  


## custom-create-directory v(2.0.0) Inputs

### Custom output dir entry list



  
> ID: custom_output_dir_entry_list
  
**Optional:** `True`  
**Type:** `custom-output-dir-entry[]`  
**Docs:**  
The list of file entries


### output directory name



  
> ID: output_directory_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The name of the output directory

  


## custom-create-directory v(2.0.0) Outputs

### output directory



  
> ID: custom-create-directory--2.0.0/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory
  

  

