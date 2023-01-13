
star 2.7.10 tool
================

## Table of Contents
  
- [Overview](#star-v2710-overview)  
- [Links](#related-links)  
- [Inputs](#star-v2710-inputs)  
- [Outputs](#star-v2710-outputs)  
- [ICA](#ica)  


## star v(2.7.10) Overview



  
> ID: star--2.7.10  
> md5sum: 246bcafcbefa85c0f6ce80d8cec0e043

### star v(2.7.10) documentation
  
Documentation for star v2.7.10

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/star/2.7.10/star__2.7.10.cwl)  

  


## star v(2.7.10) Inputs

### Align intron max



  
> ID: align_intron_max
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Maximum intron size, if 0, max intron size will be determined by
(2ˆwinBinNbits)*winAnchorDistNbins.


### Align intron min



  
> ID: align_intron_min
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Minimum intron size: genomic gap is considered intron if its
length>=alignIntronMin, otherwise it is considered Deletion.


### Align mates gap max



  
> ID: align_mates_gap_max
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Maximum gap between two mates, if 0, max intron gap will be determined by
(2ˆwinBinNbits)*winAnchorDistNbins.


### Slign SJ overhang min



  
> ID: align_sj_overhang_min
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Minimum overhang (i.e. block size) for spliced alignments.


### Align SJDB overhang min



  
> ID: align_sjdb_overhang_min
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Minimum overhang (i.e. block size) for annotated (sjdb) spliced
alignments.


### Chim junction overhang min



  
> ID: chim_junction_overhang_min
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Minimum length of chimeric segment length, if ==0, no chimeric.
output


### Chim out type



  
> ID: chim_out_type
  
**Optional:** `True`  
**Type:** `[ Junctions | SeparateSAMold | WithinBAM | WithinBAM HardClip | WithinBAM SoftClip  ]`  
**Docs:**  
Type of chimeric output.


### Chim segment min



  
> ID: chim_segment_min
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Type of chimeric output.


### forward reads



  
> ID: forward_reads
  
**Optional:** `False`  
**Type:** `['File', <cwl_utils.parser.cwl_v1_1.CommandInputArraySchema object at 0x7fb5fe4403d0>]`  
**Docs:**  
Name(s) (with path) of the files containing the sequences to be mapped.


### genome dir



  
> ID: genome_dir
  
**Optional:** `False`  
**Type:** `Directory`  
**Docs:**  
Specifies path to the directory where the genome indices are stored.


### Genome load



  
> ID: genome_load
  
**Optional:** `True`  
**Type:** `[ LoadAndKeep | LoadAndRemove | LoadAndExit | Remove | NoSharedMemory  ]`  
**Docs:**  
ode of shared memory usage for the genome files. Only used with
–runMode alignReads.


### GTF



  
> ID: gtf
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Path to annotations file.


### Limit out sam one read bytes



  
> ID: limit_out_sam_one_read_bytes
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Max size of the SAM record (bytes) for one read. Recommended value:
>(2*(LengthMate1+LengthMate2+100)*outFilterMultimapNmax


### Out file name prefix



  
> ID: out_file_name_prefix
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Output files name prefix (including full or relative path). Can only be
defined on the command line.


### Out filter intron motifs



  
> ID: out_filter_intron_motifs
  
**Optional:** `True`  
**Type:** `[ None | RemoveNoncanonical | RemoveNoncanonicalUnannotated  ]`  
**Docs:**  
Filter alignment using their motifs.


### Out filter mismatch nmax



  
> ID: out_filter_mismatch_nmax
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Max number of multiple alignments allowed for a read: if exceeded, the read is considered
unmapped.


### Out filter mismatchn over lmax



  
> ID: out_filter_mismatchn_over_lmax
  
**Optional:** `True`  
**Type:** `double`  
**Docs:**  


### Out filter multi map nmax



  
> ID: out_filter_multi_map_nmax
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  


### Out filter type



  
> ID: out_filter_type
  
**Optional:** `True`  
**Type:** `[ Normal | BySJout  ]`  
**Docs:**  
Type of filtering.


### Out reads unmapped



  
> ID: out_reads_unmapped
  
**Optional:** `True`  
**Type:** `[ None | Fastx  ]`  
**Docs:**  
Alignment will be output only if its ratio of mismatches to *mapped*
length is less than or equal to this value.


### Out SAM mapq unique



  
> ID: out_sam_mapq_unique
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
The MAPQ value for unique mappers.


### Out SAM mode



  
> ID: out_sam_mode
  
**Optional:** `True`  
**Type:** `[ None | Full | NoQS  ]`  
**Docs:**  
Mode of SAM output.


### Out sam stand field



  
> ID: out_sam_strand_field
  
**Optional:** `True`  
**Type:** `[ None | intronMotif  ]`  
**Docs:**  
Cufflinks-like strand field flag.


### Out SAM type



  
> ID: out_sam_type
  
**Optional:** `True`  
**Type:** `[ BAM | SAM  ]`  
**Docs:**  
Type of SAM/BAM output.


### Out SAM unmapped



  
> ID: out_sam_unmapped
  
**Optional:** `True`  
**Type:** `[ None | Within | Within KeepPairs  ]`  
**Docs:**  
Output of unmapped reads in the SAM format.


### Overhang



  
> ID: overhang
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specifies the length of the genomic sequence around the annotated junction
to be used in constructing the splice junctions database.


### read files command



  
> ID: read_files_command
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Command line to execute for each of the input file. 
This command should generate FASTA or FASTQ text and send it to stdout.


### reverse reads



  
> ID: reverse_reads
  
**Optional:** `True`  
**Type:** `['File', <cwl_utils.parser.cwl_v1_1.CommandInputArraySchema object at 0x7fb5fe391510>]`  
**Docs:**  
If paired-end reads (like Illumina), both 1 and 2 must be provided.


### run thread n



  
> ID: run_thread_n
  
**Optional:** `False`  
**Type:** `int`  
**Docs:**  
Defines the number of threads to be used for genome generation, it has
to be set to the number of available cores on the server node.


### See search start lmax



  
> ID: seed_search_start_lmax
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Minimum overhang (i.e. block size) for annotated (sjdb) spliced
alignments


### Sorted by coordinate



  
> ID: sorted_by_coordinate
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Sorted by coordinate. This option will allocate extra memory for sorting 
which can be specified by –limitBAMsortRAM.


### Unsorted



  
> ID: un_sorted
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Standard unsorted.

  


## star v(2.7.10) Outputs

### Alignment



  
> ID: star--2.7.10/alignment  

  
**Optional:** `False`  
**Output Type:** `['File', <cwl_utils.parser.cwl_v1_1.CommandOutputArraySchema object at 0x7fb5fe391150>]`  
**Docs:**  
Output alignment file.
  


### Unmapped reads



  
> ID: star--2.7.10/unmapped_reads  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Output unmapped reads.
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.1d2ef6fb37fe4adbb2b42495620999c0  

  
**workflow name:** star_dev-wf  
**wfl version name:** 2.7.10  

  

