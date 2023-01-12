
custom-tar-vcf-file-list 1.0.0 tool
===================================

## Table of Contents
  
- [Overview](#custom-tar-vcf-file-list-v100-overview)  
- [Links](#related-links)  
- [Inputs](#custom-tar-vcf-file-list-v100-inputs)  
- [Outputs](#custom-tar-vcf-file-list-v100-outputs)  
- [ICA](#ica)  


## custom-tar-vcf-file-list v(1.0.0) Overview



  
> ID: custom-tar-vcf-file-list--1.0.0  
> md5sum: 13b55bcd131966369168c08d179b6bb0

### custom-tar-vcf-file-list v(1.0.0) documentation
  
Tar an array of compressed vcf files (and their indexes) uses compression and strictly no "tar bomb".
Files are placed under dir name with the output file being 'dir name.tar.gz'

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/custom-tar-vcf-file-list/1.0.0/custom-tar-vcf-file-list__1.0.0.cwl)  


### Used By
  
- [tso500-ctdna-post-processing-pipeline 1.0.0](../../../workflows/tso500-ctdna-post-processing-pipeline/1.0.0/tso500-ctdna-post-processing-pipeline__1.0.0.md)  

  


## custom-tar-vcf-file-list v(1.0.0) Inputs

### dir name



  
> ID: dir_name
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The directory name all files will be placed in


### file list



  
> ID: vcf_file_list
  
**Optional:** `False`  
**Type:** `.[]`  
**Docs:**  
List of files to be placed in the directory

  


## custom-tar-vcf-file-list v(1.0.0) Outputs

### output compressed tar file



  
> ID: custom-tar-vcf-file-list--1.0.0/output_compressed_tar_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The compressed output tar file
  

  

