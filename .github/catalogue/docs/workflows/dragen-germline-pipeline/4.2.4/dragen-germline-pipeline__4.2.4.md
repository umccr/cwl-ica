
dragen-germline-pipeline 4.2.4 workflow
=======================================

## Table of Contents
  
- [Overview](#dragen-germline-pipeline-v424-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-germline-pipeline-v424-inputs)  
- [Steps](#dragen-germline-pipeline-v424-steps)  
- [Outputs](#dragen-germline-pipeline-v424-outputs)  
- [ICA](#ica)  


## dragen-germline-pipeline v(4.2.4) Overview



  
> ID: dragen-germline-pipeline--4.2.4  
> md5sum: 78a515690480b9181a3c3faaba6eea43

### dragen-germline-pipeline v(4.2.4) documentation
  
Documentation for dragen-germline-pipeline v4.2.4

### Categories
  
- dragen  


## Visual Workflow Overview
  
[![dragen-germline-pipeline__4.2.4.svg](../../../../images/workflows/dragen-germline-pipeline/4.2.4/dragen-germline-pipeline__4.2.4.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/dragen-germline-pipeline/4.2.4/dragen-germline-pipeline__4.2.4.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/dragen-germline-pipeline/4.2.4/dragen-germline-pipeline__4.2.4.cwl)  


### Uses
  
- [custom-touch-file 1.0.0 :construction:](../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.md)  
- [multiqc 1.14.0](../../../tools/multiqc/1.14.0/multiqc__1.14.0.md)  
- [dragen-germline 4.2.4](../../../tools/dragen-germline/4.2.4/dragen-germline__4.2.4.md)  

  


## dragen-germline-pipeline v(4.2.4) Inputs

### bam input



  
> ID: bam_input
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Input a normal BAM file for the variant calling stage


### cnv enable self normalization



  
> ID: cnv_enable_self_normalization
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable CNV self normalization.
Self Normalization requires that the DRAGEN hash table be generated with the enable-cnv=true option.


### cram input



  
> ID: cram_input
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Input a normal CRAM file for the variant calling stage


### cram reference



  
> ID: cram_reference
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Path to the reference fasta file for the CRAM input. 
Required only if the input is a cram file AND not the reference in the tarball


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


### enable cnv calling



  
> ID: enable_cnv
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable CNV processing in the DRAGEN Host Software.


### enable duplicate marking



  
> ID: enable_duplicate_marking
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Mark identical alignments as duplicates


### enable hla



  
> ID: enable_hla
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable HLA typing by setting --enable-hla flag to true


### enable map align



  
> ID: enable_map_align
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enabled by default since --enable-variant-caller option is set to true.
Set this value to false if using bam_input


### enable map align output



  
> ID: enable_map_align_output
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Do you wish to have the output bam files present


### enable sv



  
> ID: enable_sv
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable/disable structural variant
caller. Default is false.


### fastq list



  
> ID: fastq_list
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
CSV file that contains a list of FASTQ files
to process.
Read1File and Read2File may be presigned urls or use this in conjunction with
the fastq_list_mount_paths inputs.


### fastq list rows



  
> ID: fastq_list_rows
  
**Optional:** `True`  
**Type:** `fastq-list-row[]`  
**Docs:**  
Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects


### hla allele frequency file



  
> ID: hla_allele_frequency_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Use the population-level HLA allele frequency file to break ties if one or more HLA allele produces the same or similar results.
The input HLA allele frequency file must be in CSV format and contain the HLA alleles and the occurrence frequency in population.
If --hla-allele-frequency-file is not specified, DRAGEN automatically uses hla_classI_allele_frequency.csv from /opt/edico/config/.
Population-level allele frequencies can be obtained from the Allele Frequency Net database.


### hla bed file



  
> ID: hla_bed_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Use the HLA region BED input file to specify the region to extract HLA reads from.
DRAGEN HLA Caller parses the input file for regions within the BED file, and then
extracts reads accordingly to align with the HLA allele reference.


### hla min reads



  
> ID: hla_min_reads
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Set the minimum number of reads to align to HLA alleles to ensure sufficient coverage and perform HLA typing.
The default value is 1000 and suggested for WES samples. If using samples with less coverage, you can use a
lower threshold value.


### hla reference file



  
> ID: hla_reference_file
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Use the HLA allele reference file to specify the reference alleles to align against.
The input HLA reference file must be in FASTA format and contain the protein sequence separated into exons.
If --hla-reference-file is not specified, DRAGEN uses hla_classI_ref_freq.fasta from /opt/edico/config/.
The reference HLA sequences are obtained from the IMGT/HLA database.


### hla tiebreaker threshold



  
> ID: hla_tiebreaker_threshold
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
If more than one allele has a similar number of reads aligned and there is not a clear indicator for the best allele,
the alleles are considered as ties. The HLA Caller places the tied alleles into a candidate set for tie breaking based
on the population allele frequency. If an allele has more than the specified fraction of reads aligned (normalized to
the top hit), then the allele is included into the candidate set for tie breaking. The default value is 0.97.


### hla zygosity threshold



  
> ID: hla_zygosity_threshold
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
If the minor allele at a given locus has fewer reads mapped than a fraction of the read count of the major allele,
then the HLA Caller infers homozygosity for the given HLA-I gene. You can use this option to specify the fraction value.
The default value is 0.15.


### license instance id location



  
> ID: lic_instance_id_location
  
**Optional:** `True`  
**Type:** `['File', 'string']`  
**Docs:**  
You may wish to place your own in.
Optional value, default set to /opt/instance-identity
which is a path inside the dragen container


### output prefix



  
> ID: output_prefix
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
The prefix given to all output files


### qc coverage ignore overlaps



  
> ID: qc_coverage_ignore_overlaps
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Set to true to resolve all of the alignments for each fragment and avoid double-counting any
overlapping bases. This might result in marginally longer run times.
This option also requires setting --enable-map-align=true.


### qc coverage region 1



  
> ID: qc_coverage_region_1
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Generates coverage region report using bed file 1.


### qc coverage region 2



  
> ID: qc_coverage_region_2
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Generates coverage region report using bed file 2.


### qc coverage region 3



  
> ID: qc_coverage_region_3
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Generates coverage region report using bed file 3.


### reference tar



  
> ID: reference_tar
  
**Optional:** `False`  
**Type:** `File`  
**Docs:**  
Path to ref data tarball


### sample sex



  
> ID: sample_sex
  
**Optional:** `True`  
**Type:** `[ male | female  ]`  
**Docs:**  
Specifies the sex of a sample


### sv call regions bed



  
> ID: sv_call_regions_bed
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specifies a BED file containing the set of regions to call.


### sv discovery



  
> ID: sv_discovery
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable SV discovery. This flag can be set to false only when --sv-forcegt-vcf is used.
When set to false, SV discovery is disabled and only the forced genotyping input variants
are processed. The default is true.


### sv enable liquid tumor mode



  
> ID: sv_enable_liquid_tumor_mode
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable liquid tumor mode.


### sv exome



  
> ID: sv_exome
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Set to true to configure the variant caller for targeted sequencing inputs,
which includes disabling high depth filters.
In integrated mode, the default is to autodetect targeted sequencing input,
and in standalone mode the default is false.


### sv forcegt vcf



  
> ID: sv_forcegt_vcf
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specify a VCF of structural variants for forced genotyping. The variants are scored and emitted
in the output VCF even if not found in the sample data.
The variants are merged with any additional variants discovered directly from the sample data.


### sv output contigs



  
> ID: sv_output_contigs
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Set to true to have assembled contig sequences output in a VCF file. The default is false.


### sv region



  
> ID: sv_region
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
Limit the analysis to a specified region of the genome for debugging purposes.
This option can be specified multiple times to build a list of regions.
The value must be in the format "chr:startPos-endPos"..


### sv use overlap pair evidence



  
> ID: sv_se_overlap_pair_evidence
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Allow overlapping read pairs to be considered as evidence.
By default, DRAGEN uses autodetect on the fraction of overlapping read pairs if <20%.


### sv tin contam tolerance



  
> ID: sv_tin_contam_tolerance
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Set the Tumor-in-Normal (TiN) contamination tolerance level.
You can enter any value between 0-1. The default maximum TiN contamination tolerance is 0.15.


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
**Type:** `boolean`  
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
The -vc-enable-phasing option enables variants to be phased when possible. The default value is true.


### vc enable roh



  
> ID: vc_enable_roh
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable or disable the ROH caller by setting this option to true or false. Enabled by default for human autosomes only.


### vc enable sex chr diploid



  
> ID: vc_enable_sex_chr_diploid
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
For male samples in germline calling mode, DRAGEN calls potential mosaic variants in non-PAR regions of sex chromosomes.
A variant is called as mosaic when the allele frequency (FORMAT/AF) is below 85% or if multiple alt alleles are called,
suggesting incompatibility with the haploid assumption. The GT field for bi-allelic mosaic variants is "0/1",
denoting a mixture of reference and alt alleles, as opposed to the regular GT of "1" for haploid variants.
The GT field for multi-allelic mosaic variants is "1/2" in VCF.
You can disable the calling of mosaic variants by setting --vc-enable-sex-chr-diploid to false.


### vc enable vcf output



  
> ID: vc_enable_vcf_output
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
The -vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.


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


### vc haploid call af threshold



  
> ID: vc_haploid_call_af_threshold
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Option --vc-haploid-call-af-threshold=<af_threshold> to control threshold.
* Diploid model is applied to haploid (chrX/Y, non-PAR) regions in male samples.
* Variants with only one alt allele and with AF>=85% are rewritten to haploid calls.
* The potential mosaic calls with AF<85% will have GT of "0/1" and an INFO tag of
  "MOSAIC" will be added.


### vc hard fitler



  
> ID: vc_hard_filter
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
DRAGEN provides post-VCF variant filtering based on annotations present in the VCF records.
However, due to the nature of DRAGEN's algorithms, which incorporate the hypothesis of correlated errors
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

  


## dragen-germline-pipeline v(4.2.4) Steps

### Create dummy file


  
> ID: dragen-germline-pipeline--4.2.4/create_dummy_file_step
  
**Step Type:** tool  
**Docs:**
  
Intermediate step for letting multiqc-interop be placed in stream mode

#### Links
  
[CWL File Path](../../../../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl)  
[CWL File Help Page :construction:](../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.md)  


### dragen qc step


  
> ID: dragen-germline-pipeline--4.2.4/dragen_qc_step
  
**Step Type:** tool  
**Docs:**
  
The dragen qc step - this takes in an array of dirs

#### Links
  
[CWL File Path](../../../../../../tools/multiqc/1.14.0/multiqc__1.14.0.cwl)  
[CWL File Help Page](../../../tools/multiqc/1.14.0/multiqc__1.14.0.md)  


### run dragen germline step


  
> ID: dragen-germline-pipeline--4.2.4/run_dragen_germline_step
  
**Step Type:** tool  
**Docs:**
  
Runs the dragen germline workflow on the FPGA.
Takes in either a fastq list as a file or a fastq_list_rows schema object

#### Links
  
[CWL File Path](../../../../../../tools/dragen-germline/4.2.4/dragen-germline__4.2.4.cwl)  
[CWL File Help Page](../../../tools/dragen-germline/4.2.4/dragen-germline__4.2.4.md)  


## dragen-germline-pipeline v(4.2.4) Outputs

### dragen bam out



  
> ID: dragen-germline-pipeline--4.2.4/dragen_bam_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
The output bam file, exists only if --enable-map-align-output is set to true
  


### dragen germline output directory



  
> ID: dragen-germline-pipeline--4.2.4/dragen_germline_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory containing all germline output files
  


### dragen vcf out



  
> ID: dragen-germline-pipeline--4.2.4/dragen_vcf_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
The output germline vcf file
  


### multiqc output directory



  
> ID: dragen-germline-pipeline--4.2.4/multiqc_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory for multiqc
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  


### Project: development_workflows


> wfl id: wfl.c5b3bd16ef014a338d489b6829d685c6  

  
**workflow name:** dragen-germline-pipeline_dev-wf  
**wfl version name:** 4.2.4  

  

