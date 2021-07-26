
bedops 2.4.39 tool
==================

## Table of Contents
  
- [Overview](#bedops-v2439-overview)  
- [Links](#related-links)  
- [Inputs](#bedops-v2439-inputs)  
- [Outputs](#bedops-v2439-outputs)  
- [ICA](#ica)  


## bedops v(2.4.39) Overview



  
> ID: bedops--2.4.39  
> md5sum: 94cac9220b0156075600bc0a26a0c4b9

### bedops v(2.4.39) documentation
  
Runs bedops v2.4.39. Multifunctional tool
bedops documentation can be found [here](https://bedops.readthedocs.io/en/latest/)
Usage:
Every input file must be sorted per the sort-bed utility.
Each operation requires a minimum number of files as shown below.
  There is no fixed maximum number of files that may be used.
Input files must have at least the first 3 columns of the BED specification.
The program accepts BED and Starch file formats.
May use '-' for a file to indicate reading from standard input (BED format only).

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/bedops/2.4.39/bedops__2.4.39.cwl)  


### Used By
  
- [get-hla-regions-bed 1.0.0](../../../workflows/get-hla-regions-bed/1.0.0/get-hla-regions-bed__1.0.0.md)  

  


## bedops v(2.4.39) Inputs

### chop



  
> ID: chop
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Using the -w or --chop operation requires at least 1 BED file input.
The output consists of the first 3 columns of the BED specification.
Produces windowed slices from the merged regions of all input files.


### chromosome



  
> ID: chromosome
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Jump to and process data for given <chromosome> only.


### complement



  
> ID: complement
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Using the -c or --complement operation requires at least 1 BED file input.
The output consists of the first 3 columns of the BED specification.
Reports the intervening intervals in between all coordinates found in the input file(s).


### difference



  
> ID: difference
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Using the -d or --difference operation requires at least 2 BED file inputs.
The output consists of the first 3 columns of the BED specification.
Reports the intervals found in the first file that are not present in the 2nd (or 3rd or 4th...) files.


### ec



  
> ID: ec
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Error check input files (slower).


### element of



  
> ID: element_of
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Using the -e or --element-of operation requires at least 2 BED file inputs.
The output consists of all columns from qualifying rows of the first input file.
-e produces exactly everything that -n does not, given the same overlap criterion.


### everything



  
> ID: everything
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Using the -u or --everything operation requires at least 1 BED file input.
The output consists of all columns from all rows of all input files.
If multiple rows are identical, the output will consist of all of them.


### header



  
> ID: header
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Accept headers (VCF, GFF, SAM, BED, WIG) in any input file.


### input files



  
> ID: input_files
  
**Optional:** `False`  
**Type:** `File[]`  
**Docs:**  
The bcl directory


### intersect



  
> ID: intersect
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Using the -i or --intersect operation requires at least 2 BED file inputs.
The output consists of the first 3 columns of the BED specification.
Reports the intervals common to all input files.


### merge



  
> ID: merge
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Using the -m or --merge operation requires at least 1 BED file input.
The output consists of the first 3 columns of the BED specification.
Merges together (flattens) all disjoint, overlapping, and adjoining intervals from all input files into
contiguous, disjoint regions.


### not element of



  
> ID: not_element_of
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Using the -n or --not-element-of operation requires at least 2 BED file inputs.
The output consists of all columns from qualifying rows of the first input file.
-n produces exactly everything that -e does not, given the same overlap criterion.


### output filename



  
> ID: output_filename
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Redirects stdout


### partition



  
> ID: partition
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Using the -p or --partition operation requires at least 1 BED file input.
The output consists of the first 3 columns of the BED specification.
Breaks up inputs into disjoint (often adjacent) bed intervals.


### range



  
> ID: range
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
--range L:R:
Add 'L' bp to all start coordinates and 'R' bp to end
coordinates. Either value may be + or - to grow or
shrink regions.  With the -e/-n operations, the first
(reference) file is not padded, unlike all other files.
OR:
--range -S:S:
Pad or shrink input file(s) coordinates symmetrically by S.
This is shorthand for:


### symdiff



  
> ID: symdiff
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Using the -s or --symmdiff operation requires at least 2 BED file inputs.
The output consists of the first 3 columns of the BED specification.
Reports the intervals found in exactly 1 input file.

  


## bedops v(2.4.39) Outputs

### output file



  
> ID: bedops--2.4.39/output_file  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
Output file, of varying format depending on the command run
  

  


## ICA

### Project: development_workflows


> wfl id: wfl.5808cc6b5c6b4386b1ad966fabcec1be  

  
**workflow name:** bedops_dev-wf  
**wfl version name:** 2.4.39  

  

