
custom-tar-file-list 1.0.0 tool
===============================

## Table of Contents
  
- [Overview](#custom-tar-file-list-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-tar-file-list-v100-inputs)  
- [Outputs](#custom-tar-file-list-v100-outputs)  
- [ICA](#ica)  


## custom-tar-file-list v(1.0.0) Overview



  
> ID: custom-tar-file-list--1.0.0  
> md5sum: e963a2694f6b711316bbf03661542e85

### custom-tar-file-list v(1.0.0) documentation
  
Tar an array of files, uses compression and strictly no "tar bomb". Files are placed under dir name
with the output file being 'dir name.tar.gz'

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-tar-file-list/1.0.0/custom-tar-file-list__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## custom-tar-file-list v(1.0.0) Inputs

### dir name



  
> ID: dir_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The directory name all files will be placed in


### file list



  
> ID: file_list
  
**Optional:** `False`  
**Type:** `File[]`  
**Docs:**  
List of files to be placed in the directory

  


## custom-tar-file-list v(1.0.0) Outputs

### output compressed tar file



  
> ID: custom-tar-file-list--1.0.0/output_compressed_tar_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The compressed output tar file
  

  

