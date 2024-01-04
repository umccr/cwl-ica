
dragen-somatic-pipeline 4.2.4 workflow
======================================

## Table of Contents
  
- [Overview](#dragen-somatic-pipeline-v424-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-somatic-pipeline-v424-inputs)  
- [Steps](#dragen-somatic-pipeline-v424-steps)  
- [Outputs](#dragen-somatic-pipeline-v424-outputs)  
- [ICA](#ica)  


## dragen-somatic-pipeline v(4.2.4) Overview



  
> ID: dragen-somatic-pipeline--4.2.4  
> md5sum: 2c8ad6dd8ec694396b6ce2c78195c58c

### dragen-somatic-pipeline v(4.2.4) documentation
  
Documentation for dragen-somatic-pipeline v4.2.4

### Categories
  
- dragen  
- variant-calling  


## Visual Workflow Overview
  
[![dragen-somatic-pipeline__4.2.4.svg](../../../../images/workflows/dragen-somatic-pipeline/4.2.4/dragen-somatic-pipeline__4.2.4.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/dragen-somatic-pipeline/4.2.4/dragen-somatic-pipeline__4.2.4.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/dragen-somatic-pipeline/4.2.4/dragen-somatic-pipeline__4.2.4.cwl)  


### Uses
  
- [custom-touch-file 1.0.0 :construction:](../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.md)  
- [multiqc 1.14.0](../../../tools/multiqc/1.14.0/multiqc__1.14.0.md)  
- [dragen-somatic 4.2.4](../../../tools/dragen-somatic/4.2.4/dragen-somatic__4.2.4.md)  

  


## dragen-somatic-pipeline v(4.2.4) Inputs

### bam input



  
> ID: bam_input
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Input a BAM file for the variant calling stage


### cnv enable self normalization



  
> ID: cnv_enable_self_normalization
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable CNV self normalization.
Self Normalization requires that the DRAGEN hash table be generated with the enable-cnv=true option.


### cnv normal b allele vcf



  
> ID: cnv_normal_b_allele_vcf
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specify a matched normal SNV VCF.


### cnv normal cnv vcf



  
> ID: cnv_normal_cnv_vcf
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Specify germline CNVs from the matched normal sample.


### cnv population b allele vcf



  
> ID: cnv_population_b_allele_vcf
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specify a population SNP catalog.


### cnv somatic enable het calling



  
> ID: cnv_somatic_enable_het_calling
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable HET-calling mode for heterogeneous segments.


### cnv somatic enable lower ploidy limit



  
> ID: cnv_somatic_enable_lower_ploidy_limit
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
To improve accuracy on the tumor ploidy model estimation, the somatic WGS CNV caller estimates whether the chosen model calls 
homozygous deletions on regions that are likely to reduce the overall fitness of cells, 
which are therefore deemed to be "essential" and under negative selection. 
In the current literature, recent efforts tried to map such cell-essential genes (eg, in 2015 - https://www.science.org/doi/10.1126/science.aac7041).
The check on essential regions is controlled with --cnv-somatic-enable-lower-ploidy-limit (default true).


### cnv somatic essential genes bed



  
> ID: cnv_somatic_essential_genes_bed
  
**Optional:** `True`  
**Type:** `['string', 'File']`  
**Docs:**  
Default bedfiles describing the essential regions are provided for hg19, GRCh37, hs37d5, GRCh38, 
but a custom bedfile can also be provided in input through the 
--cnv-somatic-essential-genes-bed=<BEDFILE_PATH> parameter. 
In such case, the feature is automatically enabled. 
A custom essential regions bedfile needs to have the following format: 4-column, tab-separated, 
where the first 3 columns identify the coordinates of the essential region (chromosome, 0-based start, excluded end). 
The fourth column is the region id (string type). For the purpose of the algorithm, currently only the first 3 columns are used. 
However, the fourth might be helpful to investigate manually which regions drove the decisions on model plausibility made by the caller.


### cnv use somatic vc baf



  
> ID: cnv_use_somatic_vc_baf
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
If running in tumor-normal mode with the SNV caller enabled, use this option
to specify the germline heterozygous sites.


### cnv use somatic vc vaf



  
> ID: cnv_use_somatic_vc_vaf
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Use the variant allele frequencies (VAFs) from the somatic SNVs to help select
the tumor model for the sample.


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
Enable the flagging of duplicate output
alignment records.


### enable hla



  
> ID: enable_hla
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable HLA typing by setting --enable-hla flag to true


### enable hrd



  
> ID: enable_hrd
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Set to true to enable HRD scoring to quantify genomic instability.
Requires somatic CNV calls.


### enable map align



  
> ID: enable_map_align
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enabled by default since --enable-variant-caller option is set to true.
Set this value to false if using bam_input AND tumor_bam_input


### enable map align output



  
> ID: enable_map_align_output
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enables saving the output from the
map/align stage. Default is true when only
running map/align. Default is false if
running the variant caller.


### enable rna



  
> ID: enable_rna
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Set this option for running RNA samples through T/N workflow


### enable sort



  
> ID: enable_sort
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
True by default, only set this to false if using --bam-input and --tumor-bam-input parameters


### enable sv



  
> ID: enable_sv
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable/disable structural variant
caller. Default is false.


### enable tmb



  
> ID: enable_tmb
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enables TMB. If set, the small variant caller, Illumina Annotation Engine,
and the related callability report are enabled.


### fastq list



  
> ID: fastq_list
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
CSV file that contains a list of FASTQ files for normal sample
to process. read_1 and read_2 components in the CSV file must be presigned urls.


### fastq list rows



  
> ID: fastq_list_rows
  
**Optional:** `True`  
**Type:** `fastq-list-row[]`  
**Docs:**  
Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects for normal sample


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


### output directory



  
> ID: output_directory
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Required - The output directory.


### output file prefix



  
> ID: output_file_prefix
  
**Optional:** `False`  
**Type:** `string`  
**Docs:**  
Required - the output file prefix


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


### repeat genotype enable



  
> ID: repeat_genotype_enable
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enables repeat expansion detection.


### repeat genotype specs



  
> ID: repeat_genotype_specs
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specifies the full path to the JSON file that contains the
repeat variant catalog (specification) describing the loci to call.
If the option is not provided, DRAGEN attempts to autodetect the applicable catalog file
from /opt/edico/repeat-specs/ based on the reference provided.


### repeat genotype use catalog



  
> ID: repeat_genotype_use_catalog
  
**Optional:** `True`  
**Type:** `[ default | default_plus_smn | expanded  ]`  
**Docs:**  
Repeat variant catalog type to use (default - ~60 repeats, default_plus_smn -
same as default with SMN repeat, expanded - ~50K repeats)


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


### sv enable somatic ins tandup hotspot regions



  
> ID: sv_enable_somatic_ins_tandup_hotspot_regions
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable or disable the ITD hotspot region input. The default is true in somatic variant analysis.


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
The value must be in the format “chr:startPos-endPos”..


### sv use overlap pair evidence



  
> ID: sv_se_overlap_pair_evidence
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Allow overlapping read pairs to be considered as evidence.
By default, DRAGEN uses autodetect on the fraction of overlapping read pairs if <20%.


### sv somatic ins tandup hotspot regions bed



  
> ID: sv_somatic_ins_tandup_hotspot_regions_bed
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Specify a BED of ITD hotspot regions to increase sensitivity for calling ITDs in somatic variant analysis.
By default, DRAGEN SV automatically selects areference-specific hotspots BED file from
/opt/edico/config/sv_somatic_ins_tandup_hotspot_*.bed.


### sv tin contam tolerance



  
> ID: sv_tin_contam_tolerance
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Set the Tumor-in-Normal (TiN) contamination tolerance level.
You can enter any value between 0–1. The default maximum TiN contamination tolerance is 0.15.


### tmb db threshold



  
> ID: tmb_db_threshold
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
Specify the minimum allele count (total number of observations) for an allele in gnomAD or 1000 Genome
to be considered a germline variant.  Variant calls that have the same positions and allele are ignored
from the TMB calculation. The default value is 10.


### tmb vaf threshold



  
> ID: tmb_vaf_threshold
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Specify the minimum VAF threshold for a variant. Variants that do not meet the threshold are filtered out.
The default value is 0.05.


### tumor bam input



  
> ID: tumor_bam_input
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
Input a BAM file for the variant calling stage


### tumor fastq list



  
> ID: tumor_fastq_list
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
CSV file that contains a list of FASTQ files
to process. read_1 and read_2 components in the CSV file must be presigned urls.


### tumor fastq list rows



  
> ID: tumor_fastq_list_rows
  
**Optional:** `True`  
**Type:** `fastq-list-row[]`  
**Docs:**  
Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects for tumor sample


### vc af call threshold



  
> ID: vc_af_call_threshold
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Set the allele frequency call threshold to emit a call in the VCF if the AF filter is enabled.
The default is 0.01.


### vc af call threshold mito



  
> ID: vc_af_call_threshold_mito
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
If the AF filter is enabled using --vc-enable-af-filter-mito=true,
the option sets the allele frequency call threshold to emit a call in the VCF for mitochondrial variant calling.
The default value is 0.01.


### vc af filter threshold



  
> ID: vc_af_filter_threshold
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Set the allele frequency filter threshold to mark emitted VCF calls as filtered if the AF filter is
enabled.
The default is 0.05.


### vc af filter threshold mito



  
> ID: vc_af_filter_threshold_mito
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
If the AF filter is enabled using --vc-enable-af-filter-mito=true,
the option sets the allele frequency filter threshold to mark emitted VCF calls
as filtered for mitochondrial variant calling. The default value is 0.02.


### vc base qual threshold



  
> ID: vc_base_qual_threshold
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
(Replaces --vc-min-base-qual)
Specifies the minimum base quality to be considered in the active region detection of the small variant caller.
The default value is 10.


### vc callability normal thresh



  
> ID: vc_callability_normal_thresh
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
The --vc-callability-normal-thresh option specifies the callability threshold for normal samples.
The somatic callable regions report includes all regions with normal coverage above the normal threshold.


### vc callability tumor thresh



  
> ID: vc_callability_tumor_thresh
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
The --vc-callability-tumor-thresh option specifies the callability threshold for tumor samples. The
somatic callable regions report includes all regions with tumor coverage above the tumor threshold.


### vc combine phased variants distance



  
> ID: vc_combine_phased_variants_distance
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
When the specified value is greater than 0, combines all phased variants in the phasing set that have a distance 
less than or equal to the provided value. The max allowed phasing distance is 15. 
The default value is 0, which disables the option.


### vc combine phased variants max vaf delta



  
> ID: vc_combine_phased_variants_max_vaf_delta
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Component SNVs/INDELs of MNV calls are output only if the VAF of the component 
call is greater than that of the MNV by more than 0.1. The VAF difference 
threshold for outputting component calls along with MNV calls can be controlled by 
the --vc-combine-phased-variants-max-vaf-delta option.
This option is mutually exclusive with --vc-mnv-emit-component-calls


### vc decoy contigs



  
> ID: vc_decoy_contigs
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
The --vc-decoy-contigs option specifies a comma-separated list of contigs to skip during variant calling.
This option can be set in the configuration file.


### vc enable af filter



  
> ID: vc_enable_af_filter
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enables the allele frequency filter. The default value is false. When set to true, the VCF excludes variants
with allele frequencies below the AF call threshold or variants with an allele frequency below the AF filter
threshold and tagged with low AF filter tag. The default AF call threshold is 1% and the default AF filter
threshold is 5%.
To change the threshold values, use the following command line options:
  --vc-af-callthreshold and --vc-af-filter-threshold.


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


### vc enable liquid tumor mode



  
> ID: vc_enable_liquid_tumor_mode
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
In a tumor-normal analysis, DRAGEN accounts for tumor-in-normal (TiN) contamination by running liquid
tumor mode. Liquid tumor mode is disabled by default. When liquid tumor mode is enabled, DRAGEN is
able to call variants in the presence of TiN contamination up to a specified maximum tolerance level.
vc-enable-liquid-tumor-mode enables liquid tumor mode with a default maximum contamination
TiN tolerance of 0.15. If using the default maximum contamination TiN tolerance, somatic variants are
expected to be observed in the normal sample with allele frequencies up to 15% of the corresponding
allele in the tumor sample.


### vc enable non homoref normal filter



  
> ID: vc_enable_non_homref_normal_filter
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enables the non-homref normal filter. The default value is true. When set to true, the VCF filters out
variants if the normal sample genotype is not a homozygous reference.


### vc enable non primary allelic filter



  
> ID: vc_enable_non_primary_allelic_filter
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Similar to vc-enable-triallelic-filter, but less aggressive.
Keep the allele per position with highest alt AD, and only filter the rest.
The default is false. Not compatible with vc-enable-triallelic-filter.


### vc enable orientation bias filter



  
> ID: vc_enable_orientation_bias_filter
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enables the orientation bias filter. The default value is false, which means the option is disabled.


### vc enable orientation bias filter artifacts



  
> ID: vc_enable_orientation_bias_filter_artifacts
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
The artifact type to be filtered can be specified with the --vc-orientation-bias-filter-artifacts option.
The default is C/T,G/T, which correspond to OxoG and FFPE artifacts. Valid values include C/T, or G/T, or C/T,G/T,C/A.
An artifact (or an artifact and its reverse compliment) cannot be listed twice.
For example, C/T,G/A is not valid, because C→G and T→A are reverse compliments.


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


### vc enable triallelic filter



  
> ID: vc_enable_triallelic_filter
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enables the multiallelic filter. The default is true.


### vc enable unequal ntd



  
> ID: vc_enable_unequal_ntd
  
**Optional:** `True`  
**Type:** `['boolean', <cwl_utils.parser.cwl_v1_1.InputEnumSchema object at 0x7fbcbf71bf40>]`  
**Docs:**  
Nucleotide (NTD) Error Bias Estimation is on by default and recommended as a replacement for the orientation bias filter.
Both methods take account of strand-specific biases (systematic differences between F1R2 and F2R1 reads).
In addition, NTD error estimation accounts for non-strand-specific biases such as sample-wide elevation of a certain SNV type,
eg C->T or any other transition or transversion.
NTD error estimation can also capture the biases in a trinucleotide context.


### vc enable vcf output



  
> ID: vc_enable_vcf_output
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
The –vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.


### vc hard filter



  
> ID: vc_hard_filter
  
**Optional:** `True`  
**Type:** `string`  
**Docs:**  
DRAGEN provides post-VCF variant filtering based on annotations present in the VCF records.
However, due to the nature of DRAGEN’s algorithms, which incorporate the hypothesis of correlated errors
from within the core of variant caller, the pipeline has improved capabilities in distinguishing
the true variants from noise, and therefore the dependency on post-VCF filtering is substantially reduced.
For this reason, the default post-VCF filtering in DRAGEN is very simple


### vc hotspot log10 prior boost



  
> ID: vc_hotspot_log10_prior_boost
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
The size of the hotspot adjustment can be controlled via vc-hotspotlog10-prior-boost,
which has a default value of 4 (log10 scale) corresponding to an increase of 40 phred.


### vc max reads per active region



  
> ID: vc_max_reads_per_active_region
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
specifies the maximum number of reads covering a given active region.
Default is 10000 for the somatic workflow


### vc max reads per raw region



  
> ID: vc_max_reads_per_raw_region
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
specifies the maximum number of reads covering a given raw region.
Default is 30000 for the somatic workflow


### vc min tumor read qual



  
> ID: vc_min_tumor_read_qual
  
**Optional:** `True`  
**Type:** `int`  
**Docs:**  
The --vc-min-tumor-read-qual option specifies the minimum read quality (MAPQ) to be considered for
variant calling. The default value is 3 for tumor-normal analysis or 20 for tumor-only analysis.


### vc mnv emit component calls



  
> ID: vc_mnv_emit_component_calls
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
To output all component SNVs/INDELs of MNVs, regardless of VAF difference, 
when enabled, use the option --vc-mnv-emit-component-calls. 
This option is mutually exclusive with --vc-combine-phased-variants-max-vaf-delta


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


### vc somatic hotspots



  
> ID: vc_somatic_hotspots
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
The somatic hotspots option allows an input VCF to specify the positions where the risk for somatic
mutations are assumed to be significantly elevated. DRAGEN genotyping priors are boosted for all
postions specified in the VCF, so it is possible to call a variant at one of these sites with fewer supporting
reads. The cosmic database in VCF format can be used as one source of prior information to boost
sensitivity for known somatic mutations.


### vc sq call threshold



  
> ID: vc_sq_call_threshold
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Emits calls in the VCF. The default is 3.
If the value for vc-sq-filter-threshold is lower than vc-sq-callthreshold,
the filter threshold value is used instead of the call threshold value


### vc sq filter threshold



  
> ID: vc_sq_filter_threshold
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Marks emitted VCF calls as filtered.
The default is 17.5 for tumor-normal and 6.5 for tumor-only.


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


### vc target vaf



  
> ID: vc_target_vaf
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
The vc-target-vaf is used to select the variant allele frequencies of interest. 
The variant caller will aim to detect variants with allele frequencies larger than this setting. 
We recommend adding a small safety factor, e.g. to ensure variants in the ballpark of 1% are detected, 
the minimum vc-target-vaf can be specified as 0.009 (0.9%). This setting will not apply a hard threshold, 
and it is possible to detect variants with allele frequencies lower than the selected threshold. 
On high coverage and clean datasets, a lower target-vaf may help increase sensitivity. 
On noisy samples (like FFPE) a higher target-vaf (like 0.03) maybe help reduce false positives. 
Using a low target-vaf may also increase runtime. Set the vc-target-vaf to 0 to disable this feature. 
When this feature is disabled the variant caller will require at least 2 supporting reads to discover a candidate variant. 
Default=0.01.


### vc tin contam tolerance



  
> ID: vc_tin_contam_tolerance
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
vc-tin-contam-tolerance enables liquid tumor mode and allows you to
set the maximum contamination TiN tolerance. The maximum contamination TiN tolerance must be
greater than zero. For example, vc-tin-contam-tolerance=-0.1.

  


## dragen-somatic-pipeline v(4.2.4) Steps

### Create dummy file


  
> ID: dragen-somatic-pipeline--4.2.4/create_dummy_file_step
  
**Step Type:** tool  
**Docs:**
  
Intermediate step for letting multiqc-interop be placed in stream mode

#### Links
  
[CWL File Path](../../../../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl)  
[CWL File Help Page :construction:](../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.md)  


### run dragen qc step


  
> ID: dragen-somatic-pipeline--4.2.4/run_dragen_qc_step
  
**Step Type:** tool  
**Docs:**
  
The dragen qc step - this takes in an array of dirs

#### Links
  
[CWL File Path](../../../../../../tools/multiqc/1.14.0/multiqc__1.14.0.cwl)  
[CWL File Help Page](../../../tools/multiqc/1.14.0/multiqc__1.14.0.md)  


### run dragen somatic step


  
> ID: dragen-somatic-pipeline--4.2.4/run_dragen_somatic_step
  
**Step Type:** tool  
**Docs:**
  
Run dragen somatic v4.2.4

#### Links
  
[CWL File Path](../../../../../../tools/dragen-somatic/4.2.4/dragen-somatic__4.2.4.cwl)  
[CWL File Help Page](../../../tools/dragen-somatic/4.2.4/dragen-somatic__4.2.4.md)  


## dragen-somatic-pipeline v(4.2.4) Outputs

### dragen somatic output directory



  
> ID: dragen-somatic-pipeline--4.2.4/dragen_somatic_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Output directory containing all outputs of the somatic dragen run
  


### multiqc output directory



  
> ID: dragen-somatic-pipeline--4.2.4/multiqc_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory for multiqc
  


### output normal bam



  
> ID: dragen-somatic-pipeline--4.2.4/normal_bam_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Bam file of the normal sample
  


### somatic snv vcf filetered



  
> ID: dragen-somatic-pipeline--4.2.4/somatic_snv_vcf_hard_filtered_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Output of the snv vcf filtered tumor calls
  


### somatic snv vcf



  
> ID: dragen-somatic-pipeline--4.2.4/somatic_snv_vcf_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Output of the snv vcf tumor calls
  


### somatic sv vcf filetered



  
> ID: dragen-somatic-pipeline--4.2.4/somatic_structural_vcf_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Output of the sv vcf filtered tumor calls.
Exists only if --enable-sv is set to true.
  


### output tumor bam



  
> ID: dragen-somatic-pipeline--4.2.4/tumor_bam_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Bam file of the tumor sample
  

  


## ICA

### ToC
  
- [development_workflows](#project-development_workflows)  
- [production_workflows](#project-production_workflows)  


### Project: development_workflows


> wfl id: wfl.32e346cdbb854f6487e7594ec17a81f9  

  
**workflow name:** dragen-somatic-pipeline_dev-wf  
**wfl version name:** 4.2.4  


### Project: production_workflows


> wfl id: wfl.aa0ccece4e004839aa7374d1d6530633  

  
**workflow name:** dragen-somatic-pipeline_prod-wf  
**wfl version name:** 4.2.4--ad23456  

  

