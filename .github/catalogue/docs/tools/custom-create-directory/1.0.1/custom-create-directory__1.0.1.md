
custom-create-directory 1.0.1 tool
==================================

## Table of Contents
  
- [Overview](#custome-create-directory-v101-overview)  
- [Links](#related-links)  
- [Inputs](#custome-create-directory-v101-inputs)  
- [Outputs](#custome-create-directory-v101-outputs)  
- [ICA](#ica)  


## custome-create-directory v(1.0.1) Overview



  
> ID: custome-create-directory--1.0.1  
> md5sum: 8ec168edec6bca93747125d52af2c17b

### custome-create-directory v(1.0.1) documentation
  
Documentation for custome-create-directory v1.0.1
Create a directory based on **content** of list of input directories, i.e. not the
directory itself. rsync interprets a directory with no trailing slash as copy this directory, 
and a directory with a trailing slash as copy the contents of this directory.  

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-create-directory/1.0.1/custom-create-directory__1.0.1.cwl)  

  


## custome-create-directory v(1.0.1) Inputs

### input directories



  
> ID: input_directories
  
**Optional:** `True`  
**Type:** `Directory[]`  
**Docs:**  
List of input directories to go into the output directory


### output directory name



  
> ID: output_directory_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The name of the output directory

  


## custome-create-directory v(1.0.1) Outputs

### output directory



  
> ID: custome-create-directory--1.0.1/output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory with all of the outputs collected
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.d58562105cb74b67906be002c2f53bef  

  
**workflow name:** custom-create-directory_dev-wf  
**wfl version name:** 1.0.1  

  

