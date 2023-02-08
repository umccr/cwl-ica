
bcl-convert 4.0.3 tool
======================

## Table of Contents
  
- [Overview](#bcl-convert-v403-overview)  
- [Links](#related-links)  
- [Inputs](#bcl-convert-v403-inputs)  
- [Outputs](#bcl-convert-v403-outputs)  
- [ICA](#ica)  


## bcl-convert v(4.0.3) Overview



  
> ID: bcl-convert--4.0.3  
> md5sum: c72da99d83e7f095891aae6497d321ab

### bcl-convert v(4.0.3) documentation
  
Documentation for bcl-convert v4.0.3

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/bcl-convert/4.0.3/bcl-convert__4.0.3.cwl)  


### Used By
  
- [bclconvert 4.0.3](../../../workflows/bclconvert/4.0.3/bclconvert__4.0.3.md)  
- [validate-bclconvert-samplesheet 4.0.3](../../../workflows/validate-bclconvert-samplesheet/4.0.3/validate-bclconvert-samplesheet__4.0.3.md)  

  


## bcl-convert v(4.0.3) Inputs

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
  
**Optional:** `True`  
**Type:** `Directory`  
**Docs:**  
A main command-line option that indicates the path to the run
folder directory.
This parameter must be set, but is optional in the case that --bcl-validate-sample-sheet-only
is set and --run-info and --sample-sheet are provided


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


### bcl only matched reads



  
> ID: bcl_only_matched_reads
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Disable outputting unmapped reads to FASTQ files marked as Undetermined.


### bcl sample project subdirectories



  
> ID: bcl_sampleproject_subdirectories
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
true — Allows creation of Sample_Project subdirectories
as specified in the sample sheet. This option must be set to true for
the Sample_Project column in the data section to be used.
Default set to false.


### bcl validate sample sheet only



  
> ID: bcl_validate_sample_sheet_only
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Only validate RunInfo.xml & SampleSheet files (produce no FASTQ files)


### tiles



  
> ID: exclude_tiles
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Do not convert tiles that match a set of regular expressions, even if included in --tiles.


### fastq compression format



  
> ID: fastq_compression_format
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Required for DRAGEN ORA compression to specify the type of compression: 
use dragen for regular DRAGEN ORA compression, or dragen-interleaved for DRAGEN ORA paired compression.


### fastq gzip compression label



  
> ID: fastq_gzip_compression_level
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Set fastq output compression level 0-9 (default 1)


### first tile only



  
> ID: first_tile_only
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
true — Only process the first tile of the first swath of the
top surface of each lane specified in the sample sheet.
false — Process all tiles in each lane, as specified in the sample
sheet. Default is false


### lic instance id location



  
> ID: lic_instance_id_location
  
**Optional:** `False`  
**Type:** `['string', 'File']`  
**Docs:**  
The license instance id location


### no lane splitting



  
> ID: no_lane_splitting
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Consolidates FASTQ files across lanes.
Each sample is provided into the same file on a per-read basis.
 *  Must be true or false.
 *  Only allowed when Lane column is excluded from the sample sheet.


### num unknown barcodes reported



  
> ID: num_unknown_barcodes_reported
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Num of Top Unknown Barcodes to output (1000 by default)


### ora reference



  
> ID: ora_reference
  
**Optional:** `True`  
**Type:** `Directory`  
**Docs:**  
Required to output compressed FASTQ.ORA files. 
Specify the path to the directory that contains the compression reference and index file.


### output directory



  
> ID: output_directory
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
A required command-line option that indicates the path to
demultuplexed fastq output. The directory must not exist, unless -f,
force is specified


### output legacy stats



  
> ID: output_legacy_stats
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Also output stats in legacy (bcl2fastq) format (false by default)


### run info



  
> ID: run_info
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Overrides the path to the RunInfo.xml file.


### sample name column enabled



  
> ID: sample_name_column_enabled
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Use Sample_Name Sample Sheet column for *.fastq file names in Sample_Project subdirectories 
(requires bcl-sampleproject-subdirectories true as well).


### sample sheet



  
> ID: samplesheet
  
**Optional:** `True`  
**Type:** `['file:///home/runner/work/cwl-ica/cwl-ica/schemas/samplesheet/2.0.0--4.0.3/samplesheet__2.0.0--4.0.3.yaml#samplesheet', 'File']`  
**Docs:**  
Use sample sheet object to specify the
sample sheet location and name, if different from the default under /bcl_input_directory / SampleSheet.csv.


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


### tiles



  
> ID: tiles
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Only converts tiles that match a set of regular expressions.

  


## bcl-convert v(4.0.3) Outputs

### bcl convert directory output



  
> ID: bcl-convert--4.0.3/bcl_convert_directory_output  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Output directory containing the fastq files, reports and stats
  


### fastq list rows



  
> ID: bcl-convert--4.0.3/fastq_list_rows  

  
**Optional:** `True`  
**Output Type:** `fastq-list-row[]`  
**Docs:**  
This schema contains the following inputs:
* rgid: The id of the sample
* rgsm: The name of the sample
* rglb: The library of the sample
* lane: The lane of the sample
* read_1: The read 1 File of the sample
* read_2: The read 2 File of the sample (optional)
  


### run info out



  
> ID: bcl-convert--4.0.3/run_info_out  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The run info file used by the bclconvert workflow
  


### samplesheet out



  
> ID: bcl-convert--4.0.3/samplesheet_out  

  
**Optional:** `False`  
**Output Type:** `File`  
**Docs:**  
The samplesheet used by the bclconvert workflow
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.bdc024d6eaea42d4ba0f17da380f8a51  

  
**workflow name:** bcl-convert_dev-wf  
**wfl version name:** 4.0.3  

  

