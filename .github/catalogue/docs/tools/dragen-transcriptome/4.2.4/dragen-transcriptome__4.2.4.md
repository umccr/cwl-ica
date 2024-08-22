
dragen-transcriptome 4.2.4 tool
===============================

## Table of Contents
  
- [Overview](#dragen-transcriptome-v424-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-transcriptome-v424-inputs)  
- [Outputs](#dragen-transcriptome-v424-outputs)  
- [ICA](#ica)  


## dragen-transcriptome v(4.2.4) Overview



  
> ID: dragen-transcriptome--4.2.4  
> md5sum: f575e8c2853d81c60d7180d29b9e94e1

### dragen-transcriptome v(4.2.4) documentation
  
Documentation for dragen-transcriptome v4.2.4

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/dragen-transcriptome/4.2.4/dragen-transcriptome__4.2.4.cwl)  


### Used By
  
- [dragen-transcriptome-pipeline 4.2.4](../../../workflows/dragen-transcriptome-pipeline/4.2.4/dragen-transcriptome-pipeline__4.2.4.md)  
- [dragen-wts-qc-pipeline 4.2.4](../../../workflows/dragen-wts-qc-pipeline/4.2.4/dragen-wts-qc-pipeline__4.2.4.md)  

  


## dragen-transcriptome v(4.2.4) Inputs

### annotation file



  
> ID: annotation_file
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to annotation transcript file.


### bam input



  
> ID: bam_input
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Input a BAM file for the Dragen RNA options


### enable duplicate marking



  
> ID: enable_duplicate_marking
  
**Optional:** `False`  
**Type:** `boolean`  
**Docs:**  
Mark identical alignments as duplicates


### enable map align



  
> ID: enable_map_align
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enabled by default.
Set this value to false if using bam_input


### enable map align output



  
> ID: enable_map_align_output
  
**Optional:** `False`  
**Type:** `boolean`  
**Docs:**  
Do you wish to have the output bam files present


### enable rna gene fusion



  
> ID: enable_rna_gene_fusion
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable the DRAGEN Gene Fusion module. The default value is true.


### enable rna quantification



  
> ID: enable_rna_quantification
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable the quantification module. The default value is true.


### enable rrna filtering



  
> ID: enable_rrna_filter
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Use the DRAGEN RNA pipeline to filter rRNA reads during alignment. The default value is false.


### enable sort



  
> ID: enable_sort
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
True by default, only set this to false if using --bam-input parameters


### fastq list



  
> ID: fastq_list
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
CSV file that contains a list of FASTQ files
to process. read_1 and read_2 components in the CSV file must be presigned urls.


### fastq list rows



  
> ID: fastq_list_rows
  
**Optional:** `True`  
**Type:** `fastq-list-row[]`  
**Docs:**  
Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects


### license instance id location



  
> ID: lic_instance_id_location
  
**Optional:** `True`  
**Type:** `['File', 'string']`  
**Docs:**  
You may wish to place your own in.
Optional value, default set to /opt/instance-identity
which is a path inside the dragen container


### output directory



  
> ID: output_directory
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The directory where all output files are placed.


### output file prefix



  
> ID: output_file_prefix
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The prefix given to all output files.


### read trimming



  
> ID: read_trimmers
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
To enable trimming filters in hard-trimming mode, set to a comma-separated list of the trimmer tools 
you would like to use. To disable trimming, set to none. During mapping, artifacts are removed from all reads.
Read trimming is disabled by default.


### reference tar



  
> ID: reference_tar
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to ref data tarball.


### name of the rRNA sequences to use for filtering



  
> ID: rrna_filter_contig
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Specify the name of the rRNA sequences to use for filtering.


### soft read trimming



  
> ID: soft_read_trimmers
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
To enable trimming filters in soft-trimming mode, set to a comma-separated list of the trimmer tools 
you would like to use. To disable soft trimming, set to none. During mapping, reads are aligned as if trimmed,
and bases are not removed from the reads. Soft-trimming is enabled for the polyg filter by default.


### trim adapter r1 5prime



  
> ID: trim_adapter_r1_5prime
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specify the FASTA file that contains adapter sequences to trim from the 5' end of Read 1. 
NB: the sequences should be in reverse order (with respect to their appearance in the FASTQ) but not complemented.


### trim adapter r2 5prime



  
> ID: trim_adapter_r2_5prime
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specify the FASTA file that contains adapter sequences to trim from the 5' end of Read 2.
NB: the sequences should be in reverse order (with respect to their appearance in the FASTQ) but not complemented.


### trim adapter read1



  
> ID: trim_adapter_read1
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specify the FASTA file that contains adapter sequences to trim from the 3' end of Read 1.


### trim adapter read2



  
> ID: trim_adapter_read2
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specify the FASTA file that contains adapter sequences to trim from the 3' end of Read 2.


### trim adapter stringency



  
> ID: trim_adapter_stringency
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specify the minimum number of adapter bases required for trimming


### trim r1 3prime



  
> ID: trim_r1_3prime
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specify the minimum number of bases to trim from the 3' end of Read 1 (default: 0).


### trim r1 5prime



  
> ID: trim_r1_5prime
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specify the minimum number of bases to trim from the 5' end of Read 1 (default: 0).


### trim r2 3prime



  
> ID: trim_r2_3prime
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specify the minimum number of bases to trim from the 3' end of Read 2 (default: 0).


### trim r2 5prime



  
> ID: trim_r2_5prime
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specify the minimum number of bases to trim from the 5' end of Read 2 (default: 0).

  


## dragen-transcriptome v(4.2.4) Outputs

### dragen bam out



  
> ID: dragen-transcriptome--4.2.4/dragen_bam_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
The output bam file, exists only if --enable-map-align-output is set to true
  


### dragen transcriptome output directory



  
> ID: dragen-transcriptome--4.2.4/dragen_transcriptome_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing all wts analysis output files
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.1bdb5d1976474c39b8290d8b5dc0520e  

  
**workflow name:** dragen-transcriptome_dev-wf  
**wfl version name:** 4.2.4  

  

