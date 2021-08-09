
multiqc-interop 1.2.1 tool
==========================

## Table of Contents
  
- [Overview](#multiqc-interop-v121-overview)  
- [Links](#related-links)  
- [Inputs](#multiqc-interop-v121-inputs)  
- [Outputs](#multiqc-interop-v121-outputs)  
- [ICA](#ica)  


## multiqc-interop v(1.2.1) Overview



  
> ID: multiqc-interop--1.2.1  
> md5sum: 346fde115ccefa53c32b28be0c9978ff

### multiqc-interop v(1.2.1) documentation
  
Producing QC report using interop matrix

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/multiqc-interop/1.2.1/multiqc-interop__1.2.1.cwl)  


### Used By
  
- [bcl-conversion 3.7.5](../../../workflows/bcl-conversion/3.7.5/bcl-conversion__3.7.5.md)  

  


## multiqc-interop v(1.2.1) Inputs

### dummy file



  
> ID: dummy_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
testing inputs stream logic
If used will set input mode to stream on ICA which
saves having to download the entire input folder


### input directory



  
> ID: input_directory
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
The bcl directory


### output directory



  
> ID: output_directory_name
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
The output directory, defaults to "multiqc-outdir"


### output filename



  
> ID: output_filename
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Report filename in html format.
Defaults to 'multiqc-report.html'


### title



  
> ID: title
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Report title.
Printed as page header, used for filename if not otherwise specified.

  


## multiqc-interop v(1.2.1) Outputs

### multiqc output



  
> ID: multiqc-interop--1.2.1/interop_multi_qc_out  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
output dircetory with interop multiQC matrices
  

  

