
bclConvert 3.7.5 tool
=====================

## Table of Contents
  
- [Overview](#bclconvert-v375-overview)  
- [Links](#related-links)  
- [Inputs](#bclconvert-v375-inputs)  
- [Outputs](#bclconvert-v375-outputs)  
- [ICA](#ica)  


## bclConvert v(3.7.5) Overview



  
> ID: bclConvert--3.7.5  
> md5sum: f421bf663162c88e6cb28a91ddb55c0b

### bclConvert v(3.7.5) documentation
  
Runs the BCL Convert application off standard architechture

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/bclConvert/3.7.5/bclConvert__3.7.5.cwl)  


### Used By
  
- [bcl-conversion 3.7.5](../../../workflows/bcl-conversion/3.7.5/bcl-conversion__3.7.5.md)  

  


## bclConvert v(3.7.5) Inputs

### bcl conversion threads



  
> ID: bcl_conversion_threads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specifies number of threads used for conversion per tile.
Must be between 1 and available hardware threads,
inclusive.


### bcl input directory



  
> ID: bcl_input_directory
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
A main command-line option that indicates the path to the run
folder directory


### bcl num compression threads



  
> ID: bcl_num_compression_threads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specifies number of CPU threads used for compression of
output FASTQ files. Must be between 1 and available
hardware threads, inclusive.


### bcl num decompression threads



  
> ID: bcl_num_decompression_threads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specifies number of CPU threads used for decompression
of input base call files. Must be between 1 and available
hardware threads, inclusive.


### bcl num parallel tiles



  
> ID: bcl_num_parallel_tiles
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specifies number of tiles being converted to FASTQ files in
parallel. Must be between 1 and available hardware threads,
inclusive.


### convert only one lane



  
> ID: bcl_only_lane
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Convert only the specified lane number. The value must
be less than or equal to the number of lanes specified in the
RunInfo.xml. Must be a single integer value.


### bcl sample project subdirectories



  
> ID: bcl_sampleproject_subdirectories
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
true — Allows creation of Sample_Project subdirectories
as specified in the sample sheet. This option must be set to true for
the Sample_Project column in the data section to be used.
Default set to false.


### delete undetermined indices



  
> ID: delete_undetermined_indices
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Delete undetermined indices on completion of the run
Default: false


### first tile only



  
> ID: first_tile_only
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
true — Only process the first tile of the first swath of the
top surface of each lane specified in the sample sheet.
false — Process all tiles in each lane, as specified in the sample
sheet. Default is false


### force



  
> ID: force
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Allow for the directory specified by the --output-directory
option to already exist. Default is false


### output directory



  
> ID: output_directory
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
A required command-line option that indicates the path to
demultuplexed fastq output. The directory must not exist, unless -f,
force is specified


### sample sheet



  
> ID: samplesheet
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Indicates the path to the sample sheet to specify the
sample sheet location and name, if different from the default.


### shared thread odirect output



  
> ID: shared_thread_odirect_output
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Uses experimental shared-thread file output code, which
requires O_DIRECT mode. Must be true or false.
This file output method is optimized for sample counts
greater than 100,000. It is not recommended for lower
sample counts or using a distributed file system target such
as GPFS or Lustre. Default is false


### strict mode



  
> ID: strict_mode
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
true — Abort the program if any filter, locs, bcl, or bci lane
files are missing or corrupt.
false — Continue processing if any filter, locs, bcl, or bci lane files
are missing. Return a warning message for each missing or corrupt
file.

  


## bclConvert v(3.7.5) Outputs

### bcl convert directory output



  
> ID: bclConvert--3.7.5/bcl_convert_directory_output  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Output directory containing the fastq files, reports and stats
  


### fastq list rows



  
> ID: bclConvert--3.7.5/fastq_list_rows  

  
**Optional:** `False`  
**Output Type:** `fastq-list-row[]`  
**Docs:**  
This schema contains the following inputs:
* rgid: The id of the sample
* rgsm: The name of the sample
* rglb: The library of the sample
* lane: The lane of the sample
* read_1: The read 1 File of the sample
* read_2: The read 2 File of the sample (optional)
  

  

