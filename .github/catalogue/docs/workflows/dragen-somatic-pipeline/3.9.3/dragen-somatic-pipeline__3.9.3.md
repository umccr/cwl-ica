
dragen-somatic-pipeline 3.9.3 workflow
======================================

## Table of Contents
  
- [Overview](#dragen-somatic-pipeline-v393-overview)  
- [Visual](#visual-workflow-overview)  
- [Links](#related-links)  
- [Inputs](#dragen-somatic-pipeline-v393-inputs)  
- [Steps](#dragen-somatic-pipeline-v393-steps)  
- [Outputs](#dragen-somatic-pipeline-v393-outputs)  
- [ICA](#ica)  


## dragen-somatic-pipeline v(3.9.3) Overview



  
> ID: dragen-somatic-pipeline--3.9.3  
> md5sum: 1e8a521f265bdd67c0665f52ad708e07

### dragen-somatic-pipeline v(3.9.3) documentation
  
Run tumor-normal dragen somatic pipeline
v 3.9.3.
Workflow takes in two separate lists of object stor version of the fastq_list.csv equivalent
See the fastq_list_row schema definitions for more information.
More information on the documentation can be found [here](https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/FrontPages/DRAGEN.htm)

### Categories
  
- dragen  
- variant-calling  


## Visual Workflow Overview
  
[![dragen-somatic-pipeline__3.9.3.svg](../../../../images/workflows/dragen-somatic-pipeline/3.9.3/dragen-somatic-pipeline__3.9.3.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/workflows/dragen-somatic-pipeline/3.9.3/dragen-somatic-pipeline__3.9.3.svg)
## Related Links
  
- [CWL File Path](../../../../../../workflows/dragen-somatic-pipeline/3.9.3/dragen-somatic-pipeline__3.9.3.cwl)  


### Uses
  
- [custom-touch-file 1.0.0 :construction:](../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.md)  
- [multiqc 1.12.0](../../../tools/multiqc/1.12.0/multiqc__1.12.0.md)  
- [dragen-somatic 3.9.3](../../../tools/dragen-somatic/3.9.3/dragen-somatic__3.9.3.md)  

  


## dragen-somatic-pipeline v(3.9.3) Inputs

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


### enable cnv calling



  
> ID: enable_cnv
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
Enable CNV processing in the DRAGEN Host Software.


### enable duplicate marking



  
> ID: enable_duplicate_marking
  
**Optional:** `False`  
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


### enable map align output



  
> ID: enable_map_align_output
  
**Optional:** `False`  
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
to process.


### Row of fastq lists



  
> ID: fastq_list_rows
  
**Optional:** `True`  
**Type:** `fastq-list-row[]`  
**Docs:**  
The row of fastq lists.
Each row has the following attributes:
  * RGID
  * RGLB
  * RGSM
  * Lane
  * Read1File
  * Read2File (optional)


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


### tumor fastq list



  
> ID: tumor_fastq_list
  
**Optional:** `True`  
**Type:** `File`  
**Docs:**  
CSV file that contains a list of FASTQ files
to process.


### Row of fastq lists



  
> ID: tumor_fastq_list_rows
  
**Optional:** `True`  
**Type:** `fastq-list-row[]`  
**Docs:**  
The row of fastq lists.
Each row has the following attributes:
  * RGID
  * RGLB
  * RGSM
  * Lane
  * Read1File
  * Read2File (optional)


### vc af call threshold



  
> ID: vc_af_call_threshold
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Set the allele frequency call threshold to emit a call in the VCF if the AF filter is enabled.
The default is 0.01.


### vc af filter threshold



  
> ID: vc_af_filter_threshold
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
Set the allele frequency filter threshold to mark emitted VCF calls as filtered if the AF filter is
enabled.
The default is 0.05.


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


### vc enable vcf output



  
> ID: vc_enable_vcf_output
  
**Optional:** `True`  
**Type:** `boolean`  
**Docs:**  
The –vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.


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


### vc tin contam tolerance



  
> ID: vc_tin_contam_tolerance
  
**Optional:** `True`  
**Type:** `float`  
**Docs:**  
--vc-tin-contam-tolerance enables liquid tumor mode and allows you to
 set the maximum contamination TiN tolerance. The maximum contamination TiN tolerance must be
 greater than zero. For example, vc-tin-contam-tolerance=-0.1.

  


## dragen-somatic-pipeline v(3.9.3) Steps

### Create dummy file


  
> ID: dragen-somatic-pipeline--3.9.3/create_dummy_file_step
  
**Step Type:** tool  
**Docs:**
  
Intermediate step for letting multiqc-interop be placed in stream mode

#### Links
  
[CWL File Path](../../../../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl)  
[CWL File Help Page :construction:](../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.md)  


### dragen qc step


  
> ID: dragen-somatic-pipeline--3.9.3/dragen_qc_step
  
**Step Type:** tool  
**Docs:**
  
The dragen qc step - this takes in an array of dirs

#### Links
  
[CWL File Path](../../../../../../tools/multiqc/1.12.0/multiqc__1.12.0.cwl)  
[CWL File Help Page](../../../tools/multiqc/1.12.0/multiqc__1.12.0.md)  


### run dragen somatic step


  
> ID: dragen-somatic-pipeline--3.9.3/run_dragen_somatic_step
  
**Step Type:** tool  
**Docs:**
  
Runs the dragen somatic workflow on the FPGA.
Takes in a normal and tumor fastq list and corresponding mount paths from the predefined_mount_paths.
All other options avaiable at the top of the workflow

#### Links
  
[CWL File Path](../../../../../../tools/dragen-somatic/3.9.3/dragen-somatic__3.9.3.cwl)  
[CWL File Help Page](../../../tools/dragen-somatic/3.9.3/dragen-somatic__3.9.3.md)  


## dragen-somatic-pipeline v(3.9.3) Outputs

### dragen somatic output directory



  
> ID: dragen-somatic-pipeline--3.9.3/dragen_somatic_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
Output directory containing all outputs of the somatic dragen run
  


### multiqc output directory



  
> ID: dragen-somatic-pipeline--3.9.3/multiqc_output_directory  

  
**Optional:** `False`  
**Output Type:** `Directory`  
**Docs:**  
The output directory for multiqc
  


### output normal bam



  
> ID: dragen-somatic-pipeline--3.9.3/normal_bam_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Bam file of the normal sample
  


### somatic snv vcf filetered



  
> ID: dragen-somatic-pipeline--3.9.3/somatic_snv_vcf_hard_filtered_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Output of the snv vcf filtered tumor calls
  


### somatic snv vcf



  
> ID: dragen-somatic-pipeline--3.9.3/somatic_snv_vcf_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Output of the snv vcf tumor calls
  


### somatic sv vcf filetered



  
> ID: dragen-somatic-pipeline--3.9.3/somatic_structural_vcf_out  

  
**Optional:** `True`  
**Output Type:** `File`  
**Docs:**  
Output of the sv vcf filtered tumor calls.
Exists only if --enable-sv is set to true.
  


### output tumor bam



  
> ID: dragen-somatic-pipeline--3.9.3/tumor_bam_out  

  
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
**wfl version name:** 3.9.3  


#### Run Instances

##### ToC
  
- [Run wfr.b19291caab384e78b7661a85c3f82003](#run-wfrb19291caab384e78b7661a85c3f82003)  
- [Run wfr.128790246e9c48f39e14d8f8ef7d868e](#run-wfr128790246e9c48f39e14d8f8ef7d868e)  
- [Run wfr.72d2a10d54ca472a96d4023556932b8e](#run-wfr72d2a10d54ca472a96d4023556932b8e)  
- [Run wfr.7241dd632c0f40df88236e210e257bd1](#run-wfr7241dd632c0f40df88236e210e257bd1)  


##### Run wfr.b19291caab384e78b7661a85c3f82003



  
> Run Name: Dragen-3.9-somatic-pipeline  

  
**Start Time:** 2021-09-20 01:58:45 UTC  
**Duration:** 2021-09-20 13:22:00 UTC  
**End Time:** 0 days 11:23:15  


###### Reproduce Run


```bash

# Run the submission template to create the workflow input json and launch script            
cwl-ica copy-workflow-submission-template --ica-workflow-run-instance-id wfr.b19291caab384e78b7661a85c3f82003

# Edit the input json file (optional)
# vim wfr.b19291caab384e78b7661a85c3f82003.template.json 

# Run the launch script
bash wfr.b19291caab384e78b7661a85c3f82003.launch.sh
                                    
```  


###### Run Inputs


```
{
    "cnv_use_somatic_vc_baf": true,
    "enable_cnv": true,
    "enable_duplicate_marking": true,
    "enable_map_align_output": true,
    "enable_sv": true,
    "fastq_list_rows": [
        {
            "lane": 2,
            "read_1": {
                "class": "File",
                "location": "gds://umccr-fastq-data-dev/210708_A00130_0166_AH7KTJDSX2/WGS_TsqNano/CMitchell/MDX210178_L2100747_S7_L002_R1_001.fastq.gz"
            },
            "read_2": {
                "class": "File",
                "location": "gds://umccr-fastq-data-dev/210708_A00130_0166_AH7KTJDSX2/WGS_TsqNano/CMitchell/MDX210178_L2100747_S7_L002_R2_001.fastq.gz"
            },
            "rgid": "GTTCCAAT.GCAGAATT.2.210708_A00130_0166_AH7KTJDSX2.MDX210178_L2100747",
            "rglb": "L2100747",
            "rgsm": "MDX210178"
        }
    ],
    "output_directory": "SBJ00913",
    "output_file_prefix": "MDX210179",
    "reference_tar": {
        "class": "File",
        "location": "gds://umccr-refdata-dev/dragen/genomes/hg38/3.7.5/hg38_alt_ht_3_7_5.tar.gz"
    },
    "tumor_fastq_list_rows": [
        {
            "lane": 2,
            "read_1": {
                "class": "File",
                "location": "gds://umccr-fastq-data-dev/210708_A00130_0166_AH7KTJDSX2/WGS_TsqNano/CMitchell/MDX210179_L2100748_S8_L002_R1_001.fastq.gz"
            },
            "read_2": {
                "class": "File",
                "location": "gds://umccr-fastq-data-dev/210708_A00130_0166_AH7KTJDSX2/WGS_TsqNano/CMitchell/MDX210179_L2100748_S8_L002_R2_001.fastq.gz"
            },
            "rgid": "ACCTTGGC.ATGAGGCC.2.210708_A00130_0166_AH7KTJDSX2.MDX210179_L2100748",
            "rglb": "L2100748",
            "rgsm": "MDX210179"
        }
    ]
}
```  


###### Run Engine Parameters


```
{
    "workDirectory": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline",
    "outputDirectory": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs",
    "tmpOutputDirectory": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/steps",
    "logDirectory": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/logs",
    "maxScatter": 32,
    "outputSetting": "move",
    "copyOutputInstanceType": "StandardHiCpu",
    "copyOutputInstanceSize": "Medium",
    "defaultInputMode": "'Download'",
    "inputModeOverrides": {},
    "tesUseInputManifest": "'auto'",
    "cwltool": "3.0.20201203173111",
    "engine": "1.17.0-202107161017-stratus-master"
}
```  


###### Run Outputs


```
{
    "dragen_somatic_output_directory": {
        "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913",
        "basename": "SBJ00913",
        "nameroot": "",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "multiqc_output_directory": {
        "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/MDX210179_dragen_somatic_multiqc",
        "basename": "MDX210179_dragen_somatic_multiqc",
        "nameroot": "",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "normal_bam_out": {
        "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913/MDX210179.bam",
        "basename": "MDX210179.bam",
        "nameroot": "MDX210179",
        "nameext": ".bam",
        "class": "File",
        "size": 86217561146,
        "secondaryFiles": [
            {
                "basename": "MDX210179.bam.bai",
                "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913/MDX210179.bam.bai",
                "class": "File",
                "nameroot": "MDX210179.bam",
                "nameext": ".bai",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "somatic_snv_vcf_hard_filtered_out": {
        "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913/MDX210179.hard-filtered.vcf.gz",
        "basename": "MDX210179.hard-filtered.vcf.gz",
        "nameroot": "MDX210179.hard-filtered.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 7926836,
        "secondaryFiles": [
            {
                "basename": "MDX210179.hard-filtered.vcf.gz.tbi",
                "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913/MDX210179.hard-filtered.vcf.gz.tbi",
                "class": "File",
                "nameroot": "MDX210179.hard-filtered.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "somatic_snv_vcf_out": {
        "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913/MDX210179.vcf.gz",
        "basename": "MDX210179.vcf.gz",
        "nameroot": "MDX210179.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 7402189,
        "secondaryFiles": [
            {
                "basename": "MDX210179.vcf.gz.tbi",
                "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913/MDX210179.vcf.gz.tbi",
                "class": "File",
                "nameroot": "MDX210179.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "somatic_structural_vcf_out": {
        "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913/MDX210179.sv.vcf.gz",
        "basename": "MDX210179.sv.vcf.gz",
        "nameroot": "MDX210179.sv.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 103833,
        "secondaryFiles": [
            {
                "basename": "MDX210179.sv.vcf.gz.tbi",
                "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913/MDX210179.sv.vcf.gz.tbi",
                "class": "File",
                "nameroot": "MDX210179.sv.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "tumor_bam_out": {
        "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913/MDX210179_tumor.bam",
        "basename": "MDX210179_tumor.bam",
        "nameroot": "MDX210179_tumor",
        "nameext": ".bam",
        "class": "File",
        "size": 194422191551,
        "secondaryFiles": [
            {
                "basename": "MDX210179_tumor.bam.bai",
                "location": "gds://wfr.b19291caab384e78b7661a85c3f82003/Dragen-3.9-somatic-pipeline/outputs/SBJ00913/MDX210179_tumor.bam.bai",
                "class": "File",
                "nameroot": "MDX210179_tumor.bam",
                "nameext": ".bai",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "output_dir_gds_session_id": "ssn.0564cec910cb4aafa684fa429f772b12",
    "output_dir_gds_folder_id": "fol.001eaafd65424230024308d96f77cdde"
}
```  


###### Run Resources Usage
  

  
[![Dragen-3.9-somatic-pipeline__wfr.b19291caab384e78b7661a85c3f82003.svg](../../../../images/runs/workflows/dragen-somatic-pipeline/3.9.3/Dragen-3.9-somatic-pipeline__wfr.b19291caab384e78b7661a85c3f82003.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/runs/workflows/dragen-somatic-pipeline/3.9.3/Dragen-3.9-somatic-pipeline__wfr.b19291caab384e78b7661a85c3f82003.svg)  


##### Run wfr.128790246e9c48f39e14d8f8ef7d868e



  
> Run Name: test-run  

  
**Start Time:** 2021-11-10 08:43:11 UTC  
**Duration:** 2021-11-10 12:15:12 UTC  
**End Time:** 0 days 03:32:00  


###### Reproduce Run


```bash

# Run the submission template to create the workflow input json and launch script            
cwl-ica copy-workflow-submission-template --ica-workflow-run-instance-id wfr.128790246e9c48f39e14d8f8ef7d868e

# Edit the input json file (optional)
# vim wfr.128790246e9c48f39e14d8f8ef7d868e.template.json 

# Run the launch script
bash wfr.128790246e9c48f39e14d8f8ef7d868e.launch.sh
                                    
```  


###### Run Inputs


```
{
    "enable_map_align_output": true,
    "fastq_list_rows": [
        {
            "lane": 1,
            "read_1": {
                "class": "File",
                "location": "gds://umccr-temp-data-dev/stephen/qc_reference_sample_data/1_raw/Chen/180718_A00130_0068_BH5M73DSXX_E199_PRJ180495_Missing_R1_001.fastq.gz"
            },
            "read_2": {
                "class": "File",
                "location": "gds://umccr-temp-data-dev/stephen/qc_reference_sample_data/1_raw/Chen/180718_A00130_0068_BH5M73DSXX_E199_PRJ180495_Missing_R2_001.fastq.gz"
            },
            "rgid": "TCATCCTT+AGCGAGCT.1.180718_A00130_0068_BH5M73DSXX.PRJ180495_UnknownLibrary",
            "rglb": "UnknownLibrary",
            "rgsm": "PRJ180495"
        }
    ],
    "output_directory": "PRJ180494_dragen_somatic",
    "output_file_prefix": "PRJ180494",
    "reference_tar": {
        "class": "File",
        "location": "gds://development/reference-data/dragen_hash_tables/v8/hg38/altaware-cnv-anchored/hg38-v8-altaware-cnv-anchored.tar.gz"
    },
    "tumor_fastq_list_rows": [
        {
            "lane": 1,
            "read_1": {
                "class": "File",
                "location": "gds://umccr-temp-data-dev/stephen/qc_reference_sample_data/1_raw/Chen/180718_A00130_0068_BH5M73DSXX_E199_PRJ180494_Missing_R1_001.fastq.gz"
            },
            "read_2": {
                "class": "File",
                "location": "gds://umccr-temp-data-dev/stephen/qc_reference_sample_data/1_raw/Chen/180718_A00130_0068_BH5M73DSXX_E199_PRJ180494_Missing_R2_001.fastq.gz"
            },
            "rgid": "GACGTCTT+GGTTCACC.1.180718_A00130_0068_BH5M73DSXX.PRJ180494_UnknownLibrary",
            "rglb": "UnknownLibrary",
            "rgsm": "PRJ180494"
        }
    ]
}
```  


###### Run Engine Parameters


```
{
    "workDirectory": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run",
    "outputDirectory": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/outputs",
    "tmpOutputDirectory": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/steps",
    "logDirectory": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/logs",
    "maxScatter": 32,
    "outputSetting": "move",
    "copyOutputInstanceType": "StandardHiCpu",
    "copyOutputInstanceSize": "Medium",
    "defaultInputMode": "'Download'",
    "inputModeOverrides": {},
    "tesUseInputManifest": "'auto'",
    "cwltool": "3.0.20201203173111",
    "engine": "1.18.0-202109141250-stratus-master"
}
```  


###### Run Outputs


```
{
    "dragen_somatic_output_directory": {
        "location": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/outputs/PRJ180494_dragen_somatic",
        "basename": "PRJ180494_dragen_somatic",
        "nameroot": "",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "multiqc_output_directory": {
        "location": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/outputs/PRJ180494_dragen_somatic_multiqc",
        "basename": "PRJ180494_dragen_somatic_multiqc",
        "nameroot": "",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "normal_bam_out": null,
    "somatic_snv_vcf_hard_filtered_out": {
        "location": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/outputs/PRJ180494_dragen_somatic/PRJ180494.hard-filtered.vcf.gz",
        "basename": "PRJ180494.hard-filtered.vcf.gz",
        "nameroot": "PRJ180494.hard-filtered.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 6924725,
        "secondaryFiles": [
            {
                "basename": "PRJ180494.hard-filtered.vcf.gz.tbi",
                "location": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/outputs/PRJ180494_dragen_somatic/PRJ180494.hard-filtered.vcf.gz.tbi",
                "class": "File",
                "nameroot": "PRJ180494.hard-filtered.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "somatic_snv_vcf_out": {
        "location": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/outputs/PRJ180494_dragen_somatic/PRJ180494.vcf.gz",
        "basename": "PRJ180494.vcf.gz",
        "nameroot": "PRJ180494.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 6525413,
        "secondaryFiles": [
            {
                "basename": "PRJ180494.vcf.gz.tbi",
                "location": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/outputs/PRJ180494_dragen_somatic/PRJ180494.vcf.gz.tbi",
                "class": "File",
                "nameroot": "PRJ180494.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "somatic_structural_vcf_out": null,
    "tumor_bam_out": {
        "location": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/outputs/PRJ180494_dragen_somatic/PRJ180494_tumor.bam",
        "basename": "PRJ180494_tumor.bam",
        "nameroot": "PRJ180494_tumor",
        "nameext": ".bam",
        "class": "File",
        "size": 130905159229,
        "secondaryFiles": [
            {
                "basename": "PRJ180494_tumor.bam.bai",
                "location": "gds://wfr.128790246e9c48f39e14d8f8ef7d868e/test-run/outputs/PRJ180494_dragen_somatic/PRJ180494_tumor.bam.bai",
                "class": "File",
                "nameroot": "PRJ180494_tumor.bam",
                "nameext": ".bai",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "output_dir_gds_session_id": "ssn.41d09b561d554528a7cfcf5d67e6fd02",
    "output_dir_gds_folder_id": "fol.b57f57339e194b6ffda008d9a06feefb"
}
```  


###### Run Resources Usage
  

  
[![test-run__wfr.128790246e9c48f39e14d8f8ef7d868e.svg](../../../../images/runs/workflows/dragen-somatic-pipeline/3.9.3/test-run__wfr.128790246e9c48f39e14d8f8ef7d868e.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/runs/workflows/dragen-somatic-pipeline/3.9.3/test-run__wfr.128790246e9c48f39e14d8f8ef7d868e.svg)  


##### Run wfr.72d2a10d54ca472a96d4023556932b8e



  
> Run Name: InlineCSV-pipeline-test2Mar  

  
**Start Time:** 2022-03-02 22:55:57 UTC  
**Duration:** 2022-03-03 09:13:00 UTC  
**End Time:** 0 days 10:17:02  


###### Reproduce Run


```bash

# Run the submission template to create the workflow input json and launch script            
cwl-ica copy-workflow-submission-template --ica-workflow-run-instance-id wfr.72d2a10d54ca472a96d4023556932b8e

# Edit the input json file (optional)
# vim wfr.72d2a10d54ca472a96d4023556932b8e.template.json 

# Run the launch script
bash wfr.72d2a10d54ca472a96d4023556932b8e.launch.sh
                                    
```  


###### Run Inputs


```
{
    "cnv_use_somatic_vc_baf": true,
    "enable_duplicate_marking": true,
    "enable_map_align_output": true,
    "enable_sv": true,
    "fastq_list_rows": [
        {
            "lane": 2,
            "read_1": {
                "class": "File",
                "location": "gds://development/primary_data/210708_A00130_0166_AH7KTJDSX2/20220121870cbe6f/WGS_TsqNano/MDX210178_L2100747_S7_L002_R1_001.fastq.gz"
            },
            "read_2": {
                "class": "File",
                "location": "gds://development/primary_data/210708_A00130_0166_AH7KTJDSX2/20220121870cbe6f/WGS_TsqNano/MDX210178_L2100747_S7_L002_R2_001.fastq.gz"
            },
            "rgid": "GTTCCAAT.GCAGAATT.2.210708_A00130_0166_AH7KTJDSX2.MDX210178_L2100747",
            "rglb": "L2100747",
            "rgsm": "MDX210178"
        }
    ],
    "output_directory": "L2100748_L2100747_dragen",
    "output_file_prefix": "MDX210179",
    "reference_tar": {
        "class": "File",
        "location": "gds://development/reference-data/dragen_hash_tables/v8/hg38/altaware-cnv-anchored/hg38-v8-altaware-cnv-anchored.tar.gz"
    },
    "tumor_fastq_list_rows": [
        {
            "lane": 2,
            "read_1": {
                "class": "File",
                "location": "gds://development/primary_data/210708_A00130_0166_AH7KTJDSX2/20220121870cbe6f/WGS_TsqNano/MDX210179_L2100748_S8_L002_R1_001.fastq.gz"
            },
            "read_2": {
                "class": "File",
                "location": "gds://development/primary_data/210708_A00130_0166_AH7KTJDSX2/20220121870cbe6f/WGS_TsqNano/MDX210179_L2100748_S8_L002_R2_001.fastq.gz"
            },
            "rgid": "ACCTTGGC.ATGAGGCC.2.210708_A00130_0166_AH7KTJDSX2.MDX210179_L2100748",
            "rglb": "L2100748",
            "rgsm": "MDX210179"
        }
    ]
}
```  


###### Run Engine Parameters


```
{
    "workDirectory": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar",
    "outputDirectory": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs",
    "tmpOutputDirectory": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/steps",
    "logDirectory": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/logs",
    "maxScatter": 32,
    "outputSetting": "move",
    "copyOutputInstanceType": "StandardHiCpu",
    "copyOutputInstanceSize": "Medium",
    "defaultInputMode": "'Download'",
    "inputModeOverrides": {},
    "tesUseInputManifest": "'auto'",
    "cwltool": "3.0.20201203173111",
    "engine": "1.20.0-202201191609-develop"
}
```  


###### Run Outputs


```
{
    "dragen_somatic_output_directory": {
        "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen",
        "basename": "L2100748_L2100747_dragen",
        "nameroot": "L2100748_L2100747_dragen",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "multiqc_output_directory": {
        "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/MDX210179_dragen_somatic_multiqc",
        "basename": "MDX210179_dragen_somatic_multiqc",
        "nameroot": "MDX210179_dragen_somatic_multiqc",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "normal_bam_out": {
        "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen/MDX210178_normal.bam",
        "basename": "MDX210178_normal.bam",
        "nameroot": "MDX210178_normal",
        "nameext": ".bam",
        "class": "File",
        "size": 86553070272,
        "secondaryFiles": [
            {
                "basename": "MDX210178_normal.bam.bai",
                "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen/MDX210178_normal.bam.bai",
                "class": "File",
                "nameroot": "MDX210178_normal.bam",
                "nameext": ".bai",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "somatic_snv_vcf_hard_filtered_out": {
        "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen/MDX210179.hard-filtered.vcf.gz",
        "basename": "MDX210179.hard-filtered.vcf.gz",
        "nameroot": "MDX210179.hard-filtered.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 7869436,
        "secondaryFiles": [
            {
                "basename": "MDX210179.hard-filtered.vcf.gz.tbi",
                "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen/MDX210179.hard-filtered.vcf.gz.tbi",
                "class": "File",
                "nameroot": "MDX210179.hard-filtered.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "somatic_snv_vcf_out": {
        "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen/MDX210179.vcf.gz",
        "basename": "MDX210179.vcf.gz",
        "nameroot": "MDX210179.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 7352154,
        "secondaryFiles": [
            {
                "basename": "MDX210179.vcf.gz.tbi",
                "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen/MDX210179.vcf.gz.tbi",
                "class": "File",
                "nameroot": "MDX210179.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "somatic_structural_vcf_out": {
        "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen/MDX210179.sv.vcf.gz",
        "basename": "MDX210179.sv.vcf.gz",
        "nameroot": "MDX210179.sv.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 99280,
        "secondaryFiles": [
            {
                "basename": "MDX210179.sv.vcf.gz.tbi",
                "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen/MDX210179.sv.vcf.gz.tbi",
                "class": "File",
                "nameroot": "MDX210179.sv.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "tumor_bam_out": {
        "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen/MDX210179_tumor.bam",
        "basename": "MDX210179_tumor.bam",
        "nameroot": "MDX210179_tumor",
        "nameext": ".bam",
        "class": "File",
        "size": 195321311241,
        "secondaryFiles": [
            {
                "basename": "MDX210179_tumor.bam.bai",
                "location": "gds://wfr.72d2a10d54ca472a96d4023556932b8e/InlineCSV-pipeline-test2Mar/outputs/L2100748_L2100747_dragen/MDX210179_tumor.bam.bai",
                "class": "File",
                "nameroot": "MDX210179_tumor.bam",
                "nameext": ".bai",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "output_dir_gds_session_id": "ssn.2760c7cf9fdf428a8b21da9e8354257c",
    "output_dir_gds_folder_id": "fol.dba2bcde6a7f4af2aef308d9ec2c2b52"
}
```  


###### Run Resources Usage
  

  
[![InlineCSV-pipeline-test2Mar__wfr.72d2a10d54ca472a96d4023556932b8e.svg](../../../../images/runs/workflows/dragen-somatic-pipeline/3.9.3/InlineCSV-pipeline-test2Mar__wfr.72d2a10d54ca472a96d4023556932b8e.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/runs/workflows/dragen-somatic-pipeline/3.9.3/InlineCSV-pipeline-test2Mar__wfr.72d2a10d54ca472a96d4023556932b8e.svg)  


##### Run wfr.7241dd632c0f40df88236e210e257bd1



  
> Run Name: InlineCSV-test-TO  

  
**Start Time:** 2022-03-02 22:56:07 UTC  
**Duration:** 2022-03-03 01:30:45 UTC  
**End Time:** 0 days 02:34:37  


###### Reproduce Run


```bash

# Run the submission template to create the workflow input json and launch script            
cwl-ica copy-workflow-submission-template --ica-workflow-run-instance-id wfr.7241dd632c0f40df88236e210e257bd1

# Edit the input json file (optional)
# vim wfr.7241dd632c0f40df88236e210e257bd1.template.json 

# Run the launch script
bash wfr.7241dd632c0f40df88236e210e257bd1.launch.sh
                                    
```  


###### Run Inputs


```
{
    "enable_duplicate_marking": true,
    "enable_map_align_output": true,
    "enable_sv": true,
    "output_directory": "L2100748_L2100747_dragen",
    "output_file_prefix": "MDX210179",
    "reference_tar": {
        "class": "File",
        "location": "gds://development/reference-data/dragen_hash_tables/v8/hg38/altaware-cnv-anchored/hg38-v8-altaware-cnv-anchored.tar.gz"
    },
    "tumor_fastq_list_rows": [
        {
            "lane": 2,
            "read_1": {
                "class": "File",
                "location": "gds://development/primary_data/210708_A00130_0166_AH7KTJDSX2/20220121870cbe6f/WGS_TsqNano/MDX210178_L2100747_S7_L002_R1_001.fastq.gz"
            },
            "read_2": {
                "class": "File",
                "location": "gds://development/primary_data/210708_A00130_0166_AH7KTJDSX2/20220121870cbe6f/WGS_TsqNano/MDX210178_L2100747_S7_L002_R2_001.fastq.gz"
            },
            "rgid": "ACCTTGGC.ATGAGGCC.2.210708_A00130_0166_AH7KTJDSX2.MDX210179_L2100748",
            "rglb": "L2100748",
            "rgsm": "MDX210179"
        }
    ]
}
```  


###### Run Engine Parameters


```
{
    "workDirectory": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO",
    "outputDirectory": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs",
    "tmpOutputDirectory": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/steps",
    "logDirectory": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/logs",
    "maxScatter": 32,
    "outputSetting": "move",
    "copyOutputInstanceType": "StandardHiCpu",
    "copyOutputInstanceSize": "Medium",
    "defaultInputMode": "'Download'",
    "inputModeOverrides": {},
    "tesUseInputManifest": "'auto'",
    "cwltool": "3.0.20201203173111",
    "engine": "1.20.0-202201191609-develop"
}
```  


###### Run Outputs


```
{
    "dragen_somatic_output_directory": {
        "location": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs/L2100748_L2100747_dragen",
        "basename": "L2100748_L2100747_dragen",
        "nameroot": "L2100748_L2100747_dragen",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "multiqc_output_directory": {
        "location": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs/MDX210179_dragen_somatic_multiqc",
        "basename": "MDX210179_dragen_somatic_multiqc",
        "nameroot": "MDX210179_dragen_somatic_multiqc",
        "nameext": "",
        "class": "Directory",
        "size": null
    },
    "normal_bam_out": null,
    "somatic_snv_vcf_hard_filtered_out": {
        "location": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs/L2100748_L2100747_dragen/MDX210179.hard-filtered.vcf.gz",
        "basename": "MDX210179.hard-filtered.vcf.gz",
        "nameroot": "MDX210179.hard-filtered.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 209221816,
        "secondaryFiles": [
            {
                "basename": "MDX210179.hard-filtered.vcf.gz.tbi",
                "location": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs/L2100748_L2100747_dragen/MDX210179.hard-filtered.vcf.gz.tbi",
                "class": "File",
                "nameroot": "MDX210179.hard-filtered.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "somatic_snv_vcf_out": {
        "location": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs/L2100748_L2100747_dragen/MDX210179.vcf.gz",
        "basename": "MDX210179.vcf.gz",
        "nameroot": "MDX210179.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 202612647,
        "secondaryFiles": [
            {
                "basename": "MDX210179.vcf.gz.tbi",
                "location": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs/L2100748_L2100747_dragen/MDX210179.vcf.gz.tbi",
                "class": "File",
                "nameroot": "MDX210179.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "somatic_structural_vcf_out": {
        "location": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs/L2100748_L2100747_dragen/MDX210179.sv.vcf.gz",
        "basename": "MDX210179.sv.vcf.gz",
        "nameroot": "MDX210179.sv.vcf",
        "nameext": ".gz",
        "class": "File",
        "size": 1576733,
        "secondaryFiles": [
            {
                "basename": "MDX210179.sv.vcf.gz.tbi",
                "location": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs/L2100748_L2100747_dragen/MDX210179.sv.vcf.gz.tbi",
                "class": "File",
                "nameroot": "MDX210179.sv.vcf.gz",
                "nameext": ".tbi",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "tumor_bam_out": {
        "location": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs/L2100748_L2100747_dragen/MDX210179_tumor.bam",
        "basename": "MDX210179_tumor.bam",
        "nameroot": "MDX210179_tumor",
        "nameext": ".bam",
        "class": "File",
        "size": 85794594341,
        "secondaryFiles": [
            {
                "basename": "MDX210179_tumor.bam.bai",
                "location": "gds://wfr.7241dd632c0f40df88236e210e257bd1/InlineCSV-test-TO/outputs/L2100748_L2100747_dragen/MDX210179_tumor.bam.bai",
                "class": "File",
                "nameroot": "MDX210179_tumor.bam",
                "nameext": ".bai",
                "http://commonwl.org/cwltool#generation": 0
            }
        ],
        "http://commonwl.org/cwltool#generation": 0
    },
    "output_dir_gds_session_id": "ssn.40483fb1b5f7483ca1d572a08750d4d4",
    "output_dir_gds_folder_id": "fol.59c4208996a14f65ee6808d9ebfc12bc"
}
```  


###### Run Resources Usage
  

  
[![InlineCSV-test-TO__wfr.7241dd632c0f40df88236e210e257bd1.svg](../../../../images/runs/workflows/dragen-somatic-pipeline/3.9.3/InlineCSV-test-TO__wfr.7241dd632c0f40df88236e210e257bd1.svg)](https://github.com/umccr/cwl-ica/raw/main/.github/catalogue/images/runs/workflows/dragen-somatic-pipeline/3.9.3/InlineCSV-test-TO__wfr.7241dd632c0f40df88236e210e257bd1.svg)  


### Project: production_workflows


> wfl id: wfl.aa0ccece4e004839aa7374d1d6530633  

  
**workflow name:** dragen-somatic-pipeline_prod-wf  
**wfl version name:** 3.9.3--75e015e  

  

