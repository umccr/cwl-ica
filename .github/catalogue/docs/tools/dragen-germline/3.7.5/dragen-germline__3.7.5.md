
dragen-germline 3.7.5 tool
==========================

## Table of Contents
  
- [Overview](#dragen-germline-v375-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-germline-v375-inputs)  
- [Outputs](#dragen-germline-v375-outputs)  
- [ICA](#ica)  


## dragen-germline v(3.7.5) Overview



  
> ID: dragen-germline--3.7.5  
> md5sum: 54dd1c2214ab62a252ba9fb195af749d

### dragen-germline v(3.7.5) documentation
  
Documentation for dragen-germline v3.7.5

### Categories
  


## Related Links
  
- [CWL File Path](../../../../../../tools/dragen-germline/3.7.5/dragen-germline__3.7.5.cwl)  


### Used By
  
- [dragen-germline-pipeline 3.7.5](../../../workflows/dragen-germline-pipeline/3.7.5/dragen-germline-pipeline__3.7.5.md)  

  


## dragen-germline v(3.7.5) Inputs

### dbsnp annotation



  
> ID: dbsnp_annotation
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
In Germline, Tumor-Normal somatic, or Tumor-Only somatic modes,
DRAGEN can look up variant calls in a dbSNP database and add annotations for any matches that it finds there.
To enable the dbSNP database search, set the --dbsnp option to the full path to the dbSNP database
VCF or .vcf.gz file, which must be sorted in reference order.


### deduplicate minimum quality



  
> ID: dedup_min_qual
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specifies the Phred quality score below which a base should be excluded from the quality score
calculation used for choosing among duplicate reads.


### enable duplicate marking



  
> ID: enable_duplicate_marking
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Mark identical alignments as duplicates


### enable map align output



  
> ID: enable_map_align_output
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Do you wish to have the output bam files present


### fastq list



  
> ID: fastq_list
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
CSV file that contains a list of FASTQ files
to process.
Read1File and Read2File may be presigned urls or use this in conjunction with
the fastq_list_mount_paths inputs.


### fastq list mount paths



  
> ID: fastq_list_mount_paths
  
**Optional:** `True`  
**Type:** `predefined-mount-path[]`  
**Docs:**  
Path to fastq list mount path


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
The directory where all output files are placed


### output file prefix



  
> ID: output_file_prefix
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The prefix given to all output files


### reference tar



  
> ID: reference_tar
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to ref data tarball


### sample sex



  
> ID: sample_sex
  
**Optional:** `True`  
**Type:** `<cwl_utils.parser_v1_1.CommandInputEnumSchema object at 0x7f15dd478580>`  
**Docs:**  
Specifies the sex of a sample


### vc decoy contigs



  
> ID: vc_decoy_contigs
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
The --vc-decoy-contigs option specifies a comma-separated list of contigs to skip during variant calling.
This option can be set in the configuration file.


### vc enable baf



  
> ID: vc_enable_baf
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Enable or disable B-allele frequency output. Enabled by default.


### vc enable decoy contigs



  
> ID: vc_enable_decoy_contigs
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
If --vc-enable-decoy-contigs is set to true, variant calls on the decoy contigs are enabled.
The default value is false.


### vc enable gatk acceleration



  
> ID: vc_enable_gatk_acceleration
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
If is set to true, the variant caller runs in GATK mode
(concordant with GATK 3.7 in germline mode and GATK 4.0 in somatic mode).


### vc enable phasing



  
> ID: vc_enable_phasing
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
The –vc-enable-phasing option enables variants to be phased when possible. The default value is true.


### vc enable roh



  
> ID: vc_enable_roh
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable or disable the ROH caller by setting this option to true or false. Enabled by default for human autosomes only.


### vc enable vcf output



  
> ID: vc_enable_vcf_output
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
The –vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.


### vc forcegt vcf



  
> ID: vc_forcegt_vcf
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
AGENsupports force genotyping (ForceGT) for Germline SNV variant calling.
To use ForceGT, use the --vc-forcegt-vcf option with a list of small variants to force genotype.
The input list of small variants can be a .vcf or .vcf.gz file.

The current limitations of ForceGT are as follows:
*	ForceGT is supported for Germline SNV variant calling in the V3 mode.
The V1, V2, and V2+ modes are not supported.
*	ForceGT is not supported for Somatic SNV variant calling.
*	ForceGT variants do not propagate through Joint Genotyping.


### vc hard fitler



  
> ID: vc_hard_filter
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
DRAGEN provides post-VCF variant filtering based on annotations present in the VCF records.
However, due to the nature of DRAGEN’s algorithms, which incorporate the hypothesis of correlated errors
from within the core of variant caller, the pipeline has improved capabilities in distinguishing
the true variants from noise, and therefore the dependency on post-VCF filtering is substantially reduced.
For this reason, the default post-VCF filtering in DRAGEN is very simple


### vc max reads per active region



  
> ID: vc_max_reads_per_active_region
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
specifies the maximum number of reads covering a given active region.
Default is 10000 for the germline workflow


### vc max reads per raw region



  
> ID: vc_max_reads_per_raw_region
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
specifies the maximum number of reads covering a given raw region.
Default is 30000 for the germline workflow


### vc remove all soft clips



  
> ID: vc_remove_all_soft_clips
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
If is set to true, the variant caller does not use soft clips of reads to determine variants.


### vc roh blacklist bed



  
> ID: vc_roh_blacklist_bed
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
If provided, the ROH caller ignores variants that are contained in any region in the blacklist BED file.
DRAGEN distributes blacklist files for all popular human genomes and automatically selects a blacklist to
match the genome in use, unless this option is used explicitly select a file.


### vc target bed



  
> ID: vc_target_bed
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
This is an optional command line input that restricts processing of the small variant caller,
target bed related coverage, and callability metrics to regions specified in a BED file.


### vc target bed padding



  
> ID: vc_target_bed_padding
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
This is an optional command line input that can be used to pad all of the target
BED regions with the specified value.
For example, if a BED region is 1:1000-2000 and a padding value of 100 is used,
it is equivalent to using a BED region of 1:900-2100 and a padding value of 0.

Any padding added to --vc-target-bed-padding is used by the small variant caller
and by the target bed coverage/callability reports. The default padding is 0.


### vc target coverage



  
> ID: vc_target_coverage
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
The --vc-target-coverage option specifies the target coverage for down-sampling.
The default value is 500 for germline mode and 50 for somatic mode.

  


## dragen-germline v(3.7.5) Outputs

### dragen bam out



  
> ID: dragen-germline--3.7.5/dragen_bam_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
The output bam file, exists only if --enable-map-align-output is set to true
  


### dragen germline output directory



  
> ID: dragen-germline--3.7.5/dragen_germline_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing all germline output files
  


### dragen vcf out



  
> ID: dragen-germline--3.7.5/dragen_vcf_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
The output germline vcf file
  

  


## ICA

### ToC
  
- [development_workflows](#development_workflows)  


### Project: development_workflows


> wfl id: wfl.a19f90ebde874ceba9f3f41f82878e8c  

  
**workflow name:** dragen-germline_dev-wf  
**wfl version name:** 3.7.5  

  

