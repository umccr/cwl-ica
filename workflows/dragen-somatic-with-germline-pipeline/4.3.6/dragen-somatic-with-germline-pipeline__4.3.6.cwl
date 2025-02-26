cwlVersion: v1.1
class: Workflow

# Extensions
$namespaces:
    s: https://schema.org/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: dragen-somatic-with-germline-pipeline--4.3.6
label: dragen-somatic-with-germline-pipeline v(4.3.6)
doc: |
    Documentation for dragen-somatic-with-germline-pipeline
    v4.3.6

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/utils/1.0.0/utils__1.0.0.cwljs
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml

inputs:
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/OptionReference.htm
  # Inputs fastq list csv or actual fastq list file with presigned urls for Read1File and Read2File columns
  # File inputs
  # Option 1
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files for normal sample
      to process.
    type: File?
  tumor_fastq_list:
    label: tumor fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process.
    type: File?
  # Option 2
  fastq_list_rows:
    label: Row of fastq lists
    doc: |
      The row of fastq lists.
      Each row has the following attributes:
        * RGID
        * RGLB
        * RGSM
        * Lane
        * Read1File
        * Read2File (optional)
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
  tumor_fastq_list_rows:
    label: Row of fastq lists
    doc: |
      The row of fastq lists.
      Each row has the following attributes:
        * RGID
        * RGLB
        * RGSM
        * Lane
        * Read1File
        * Read2File (optional)
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
  # Option 3
  bam_input:
    label: bam input
    doc: |
      Input a normal BAM file for the variant calling stage
    type: File?
    secondaryFiles:
      - pattern: ".bai"
        required: true
  tumor_bam_input:
    label: tumor bam input
    doc: |
      Input a tumor BAM file for the variant calling stage
    type: File?
    secondaryFiles:
      - pattern: ".bai"
        required: true
  # Option 4
  cram_input:
    label: cram input
    doc: |
      Input a normal CRAM file for the variant calling stage
    type: File?
  tumor_cram_input:
    label: tumor cram input
    doc: |
      Input a tumor CRAM file for the variant calling stage
    type: File?
  cram_reference:
    label: cram reference
    doc: |
      Path to the reference fasta file for the CRAM input.
      Required only if the input is a cram file AND not the reference in the tarball
    type: File?
  # Add reference tar
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File

  # Output naming options
  # Germline
  output_prefix_germline:
    label: output prefix germline
    doc: |
      The prefix given to all outputs for the dragen germline pipeline
    type: string
  # Somatic
  output_prefix_somatic:
    label: output prefix somatic
    doc: |
      The prefix given to all outputs for the dragen somatic pipeline
    type: string

  # Optional operation modes
  # Given we're running from fastqs
  # --enable-variant-caller option must be set to true (set in arguments), --enable-map-align is then activated by default
  # --enable-map-align-output to keep bams
  # --enable-duplicate-marking to mark duplicate reads at the same time
  # --enable-sv to enable the structural variant calling step.
  # For the following inputs we also allow splitting options between somatic and germline outputs
  # --enable-sort
  # --enable-map-align
  # --enable-map-align-output
  # --enable-duplicate-marking
  # --dedup-min-qual
  enable_sort:
    label: enable sort
    doc: |
      True by default, only set this to false if using --bam-input parameter
    type: boolean?
  enable_sort_germline:
    label: enable sort germline
    doc: |
      True by default, only set this to false if using --bam-input parameter
    type: boolean?
  enable_sort_somatic:
    label: enable sort somatic
    doc: |
      True by default, only set this to false if using --bam-input parameter
    type: boolean?
  enable_map_align:
    label: enable map align
    doc: |
      Enabled by default since --enable-variant-caller option is set to true.
      Set this value to false if using bam_input
    type: boolean?
  enable_map_align_germline:
    label: enable map align germline
    doc: |
      Enabled by default since --enable-variant-caller option is set to true.
      Set this value to false if using bam_input
    type: boolean?
  enable_map_align_somatic:
    label: enable map align somatic
    doc: |
      Enabled by default since --enable-variant-caller option is set to true.
      Set this value to false if using bam_input
    type: boolean?
  enable_map_align_output:
    label: enable map align output
    doc: |
      Enables saving the output from the
      map/align stage. Default is true when only
      running map/align. Default is false if
      running the variant caller.
    type: boolean?
  enable_map_align_output_germline:
    label: enable map align output germline
    doc: |
      Enables saving the output from the
      map/align stage. Default is true when only
      running map/align. Default is false if
      running the variant caller.
    type: boolean?
  enable_map_align_output_somatic:
    label: enable map align output somatic
    doc: |
      Enables saving the output from the
      map/align stage. Default is true when only
      running map/align. Default is false if
      running the variant caller.
    type: boolean?
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Enable the flagging of duplicate output
      alignment records.
    type: boolean?
  enable_duplicate_marking_germline:
    label: enable duplicate marking germline
    doc: |
      Enable the flagging of duplicate output
      alignment records.
    type: boolean?
  enable_duplicate_marking_somatic:
    label: enable duplicate marking somatic
    doc: |
      Enable the flagging of duplicate output
      alignment records.
    type: boolean?
  enable_sv:
    label: enable sv
    doc: |
      Enable/disable structural variant
      caller. Default is false.
    type: boolean?
  enable_sv_germline:
    label: enable sv germline
    doc: |
      Enable/disable structural variant
      caller. Default is false.
    type: boolean?
  enable_sv_somatic:
    label: enable sv somatic
    doc: |
      Enable/disable structural variant
      caller. Default is false.
    type: boolean?
  enable_cnv:
    label: enable cnv calling
    doc: |
      Enable CNV processing in the DRAGEN Host Software.
    type: boolean?
  enable_cnv_germline:
    label: enable cnv germline
    doc: |
      Enable CNV processing in the DRAGEN Host Software (somatic only)
    type: boolean?
  enable_cnv_somatic:
    label: enable cnv somatic
    doc: |
      Enable CNV processing in the DRAGEN Host Software (germline only)
    type: boolean?

  # Phased / MNV Calling options
  vc_combine_phased_variants_distance_somatic:
    label: vc combine phased variants distance somatic
    doc: |
      When the specified value is greater than 0, combines all phased variants in the phasing set that have a distance
      less than or equal to the provided value. The max allowed phasing distance is 15.
      The default value is 0, which disables the option.
    type: int?
  vc_combine_phased_variants_max_vaf_delta_somatic:
    label: vc combine phased variants max vaf delta somatic
    doc: |
      Component SNVs/INDELs of MNV calls are output only if the VAF of the component
      call is greater than that of the MNV by more than 0.1. The VAF difference
      threshold for outputting component calls along with MNV calls can be controlled by
      the --vc-combine-phased-variants-max-vaf-delta option.
      This option is mutually exclusive with --vc-mnv-emit-component-calls
    type: float?
  vc_mnv_emit_component_calls_somatic:
    label: vc mnv emit component calls somatic
    doc: |
      To output all component SNVs/INDELs of MNVs, regardless of VAF difference,
      when enabled, use the option --vc-mnv-emit-component-calls.
      This option is mutually exclusive with --vc-combine-phased-variants-max-vaf-delta
    type: boolean?

  # Deduplication options
  dedup_min_qual:
    label: deduplicate minimum quality
    doc: |
      Specifies the Phred quality score below which a base should be excluded from the quality score
      calculation used for choosing among duplicate reads.
    type: int?
  dedup_min_qual_germline:
    label: deduplicate minimum quality germline
    doc: |
      Specifies the Phred quality score below which a base should be excluded from the quality score
      calculation used for choosing among duplicate reads.
    type: int?
  dedup_min_qual_somatic:
    label: deduplicate minimum quality somatic
    doc: |
      Specifies the Phred quality score below which a base should be excluded from the quality score
      calculation used for choosing among duplicate reads.
    type: int?

  # Structural Variant Caller Options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/StructuralVariantCalling.htm
  sv_call_regions_bed:
    label: sv call regions bed
    doc: |
      Specifies a BED file containing the set of regions to call.
    type: File?
  sv_region:
    label: sv region
    doc: |
      Limit the analysis to a specified region of the genome for debugging purposes.
      This option can be specified multiple times to build a list of regions.
      The value must be in the format "chr:startPos-endPos"..
    type: string?
  sv_exome:
    label: sv exome
    doc: |
      Set to true to configure the variant caller for targeted sequencing inputs,
      which includes disabling high depth filters.
      In integrated mode, the default is to autodetect targeted sequencing input,
      and in standalone mode the default is false.
    type: boolean?
  sv_output_contigs:
    label: sv output contigs
    doc: |
      Set to true to have assembled contig sequences output in a VCF file. The default is false.
    type: boolean?
  sv_forcegt_vcf:
    label: sv forcegt vcf
    doc: |
      Specify a VCF of structural variants for forced genotyping. The variants are scored and emitted
      in the output VCF even if not found in the sample data.
      The variants are merged with any additional variants discovered directly from the sample data.
    type: File?
  sv_discovery:
    label: sv discovery
    doc: |
      Enable SV discovery. This flag can be set to false only when --sv-forcegt-vcf is used.
      When set to false, SV discovery is disabled and only the forced genotyping input variants
      are processed. The default is true.
    type: boolean?
  sv_se_overlap_pair_evidence:
    label: sv use overlap pair evidence
    doc: |
      Allow overlapping read pairs to be considered as evidence.
      By default, DRAGEN uses autodetect on the fraction of overlapping read pairs if <20%.
    type: boolean?
  sv_somatic_ins_tandup_hotspot_regions_bed:
    label: sv somatic ins tandup hotspot regions bed
    doc: |
      Specify a BED of ITD hotspot regions to increase sensitivity for calling ITDs in somatic variant analysis.
      By default, DRAGEN SV automatically selects areference-specific hotspots BED file from
      /opt/edico/config/sv_somatic_ins_tandup_hotspot_*.bed.
    type: File?
  sv_enable_somatic_ins_tandup_hotspot_regions:
    label: sv enable somatic ins tandup hotspot regions
    doc: |
      Enable or disable the ITD hotspot region input. The default is true in somatic variant analysis.
    type: boolean?
  sv_enable_liquid_tumor_mode:
    label: sv enable liquid tumor mode
    doc: |
      Enable liquid tumor mode.
    type: boolean?
  sv_tin_contam_tolerance:
    label: sv tin contam tolerance
    doc: |
      Set the Tumor-in-Normal (TiN) contamination tolerance level.
      You can enter any value between 0-1. The default maximum TiN contamination tolerance is 0.15.
    type: float?

  # Variant calling options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/SmallVariantCaller.htm
  vc_base_qual_threshold:
    label: vc base qual threshold
    doc: |
      (Replaces --vc-min-base-qual)
      Specifies the minimum base quality to be considered in the active region detection of the small variant caller.
      The default value is 10.
    type: int?
  vc_base_qual_threshold_somatic:
    label: vc base qual threshold somatic
    doc: |
      (Replaces --vc-min-base-qual)
      Specifies the minimum base quality to be considered in the active region detection of the small variant caller.
      The default value is 10.
    type: int?
  vc_base_qual_threshold_germline:
    label: vc base qual threshold germline
    doc: |
      (Replaces --vc-min-base-qual)
      Specifies the minimum base quality to be considered in the active region detection of the small variant caller.
      The default value is 10.
    type: int?
  vc_target_bed:
    label: vc target bed
    doc: |
      This is an optional command line input that restricts processing of the small variant caller,
      target bed related coverage, and callability metrics to regions specified in a BED file.
    type: File?
  vc_target_bed_padding:
    label: vc target bed padding
    doc: |
      This is an optional command line input that can be used to pad all of the target
      BED regions with the specified value.
      For example, if a BED region is 1:1000-2000 and a padding value of 100 is used,
      it is equivalent to using a BED region of 1:900-2100 and a padding value of 0.

      Any padding added to --vc-target-bed-padding is used by the small variant caller
      and by the target bed coverage/callability reports. The default padding is 0.
    type: int?
  vc_target_coverage:
    label: vc target coverage
    doc: |
      The --vc-target-coverage option specifies the target coverage for down-sampling.
      The default value is 500 for germline mode and 50 for somatic mode.
    type: int?
  vc_target_vaf_somatic:
    label: vc target vaf somatic
    doc: |
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
    type: float?

  vc_enable_gatk_acceleration:
    label: vc enable gatk acceleration
    doc: |
      If is set to true, the variant caller runs in GATK mode
      (concordant with GATK 3.7 in germline mode and GATK 4.0 in somatic mode).
    type: boolean?
  vc_remove_all_soft_clips:
    label: vc remove all soft clips
    doc: |
      If is set to true, the variant caller does not use soft clips of reads to determine variants.
    type: boolean?
  vc_decoy_contigs:
    label: vc decoy contigs
    doc: |
      The --vc-decoy-contigs option specifies a comma-separated list of contigs to skip during variant calling.
      This option can be set in the configuration file.
    type: string?
  vc_enable_decoy_contigs:
    label: vc enable decoy contigs
    doc: |
      If --vc-enable-decoy-contigs is set to true, variant calls on the decoy contigs are enabled.
      The default value is false.
    type: boolean?
  vc_enable_phasing:
    label: vc enable phasing
    doc: |
      The -vc-enable-phasing option enables variants to be phased when possible. The default value is true.
    type: boolean?
  vc_enable_vcf_output:
    label: vc enable vcf output
    doc: |
      The -vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.
    type: boolean?
  # Downsampling options
  vc_max_reads_per_active_region:
    label: vc max reads per active region
    doc: |
      specifies the maximum number of reads covering a given active region.
      Default is 10000 for the somatic workflow
    type: int?
  vc_max_reads_per_raw_region:
    label: vc max reads per raw region
    doc: |
      specifies the maximum number of reads covering a given raw region.
      Default is 30000 for the somatic workflow
    type: int?
  # Ploidy support
  sample_sex:
    label: sample sex
    doc: |
      Specifies the sex of a sample
    type:
      - "null"
      - type: enum
        symbols:
          - male
          - female
  # ROH options
  vc_enable_roh:
    label: vc enable roh
    doc: |
      Enable or disable the ROH caller by setting this option to true or false. Enabled by default for human autosomes only.
    type: boolean?
  vc_roh_blacklist_bed:
    label: vc roh blacklist bed
    doc: |
      If provided, the ROH caller ignores variants that are contained in any region in the blacklist BED file.
      DRAGEN distributes blacklist files for all popular human genomes and automatically selects a blacklist to
      match the genome in use, unless this option is used explicitly select a file.
    type: File?
  # BAF options
  vc_enable_baf:
    label: vc enable baf
    doc: |
      Enable or disable B-allele frequency output. Enabled by default.
    type: boolean?
  # Somatic calling options
  vc_min_tumor_read_qual:
    label: vc min tumor read qual
    type: int?
    doc: |
      The --vc-min-tumor-read-qual option specifies the minimum read quality (MAPQ) to be considered for
      variant calling. The default value is 3 for tumor-normal analysis or 20 for tumor-only analysis.
  vc_callability_tumor_thresh:
    label: vc callability tumor thresh
    type: int?
    doc: |
      The --vc-callability-tumor-thresh option specifies the callability threshold for tumor samples. The
      somatic callable regions report includes all regions with tumor coverage above the tumor threshold.
  vc_callability_normal_thresh:
    label: vc callability normal thresh
    type: int?
    doc: |
      The --vc-callability-normal-thresh option specifies the callability threshold for normal samples.
      The somatic callable regions report includes all regions with normal coverage above the normal threshold.
  vc_somatic_hotspots:
    label: vc somatic hotspots
    type: File?
    doc: |
      The somatic hotspots option allows an input VCF to specify the positions where the risk for somatic
      mutations are assumed to be significantly elevated. DRAGEN genotyping priors are boosted for all
      postions specified in the VCF, so it is possible to call a variant at one of these sites with fewer supporting
      reads. The cosmic database in VCF format can be used as one source of prior information to boost
      sensitivity for known somatic mutations.
  vc_hotspot_log10_prior_boost:
    label: vc hotspot log10 prior boost
    type: int?
    doc: |
      The size of the hotspot adjustment can be controlled via vc-hotspotlog10-prior-boost,
      which has a default value of 4 (log10 scale) corresponding to an increase of 40 phred.
  vc_enable_liquid_tumor_mode:
    label: vc enable liquid tumor mode
    type: boolean?
    doc: |
      In a tumor-normal analysis, DRAGEN accounts for tumor-in-normal (TiN) contamination by running liquid
      tumor mode. Liquid tumor mode is disabled by default. When liquid tumor mode is enabled, DRAGEN is
      able to call variants in the presence of TiN contamination up to a specified maximum tolerance level.
      vc-enable-liquid-tumor-mode enables liquid tumor mode with a default maximum contamination
      TiN tolerance of 0.15. If using the default maximum contamination TiN tolerance, somatic variants are
      expected to be observed in the normal sample with allele frequencies up to 15% of the corresponding
      allele in the tumor sample.
  vc_tin_contam_tolerance:
    label: vc tin contam tolerance
    type: float?
    doc: |
      vc-tin-contam-tolerance enables liquid tumor mode and allows you to
      set the maximum contamination TiN tolerance. The maximum contamination TiN tolerance must be
      greater than zero. For example, vc-tin-contam-tolerance=-0.1.
  vc_enable_orientation_bias_filter:
    label: vc enable orientation bias filter
    type: boolean?
    doc: |
      Enables the orientation bias filter. The default value is false, which means the option is disabled.
  vc_enable_orientation_bias_filter_artifacts:
    label: vc enable orientation bias filter artifacts
    type: string?
    doc: |
      The artifact type to be filtered can be specified with the --vc-orientation-bias-filter-artifacts option.
      The default is C/T,G/T, which correspond to OxoG and FFPE artifacts. Valid values include C/T, or G/T, or C/T,G/T,C/A.
      An artifact (or an artifact and its reverse compliment) cannot be listed twice.
      For example, C/T,G/A is not valid, because C->G and T->A are reverse compliments.
  # Post somatic calling filtering options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/PostSomaticFilters.htm
  vc_hard_filter:
    label: vc hard filter
    doc: |
      DRAGEN provides post-VCF variant filtering based on annotations present in the VCF records.
      However, due to the nature of DRAGEN's algorithms, which incorporate the hypothesis of correlated errors
      from within the core of variant caller, the pipeline has improved capabilities in distinguishing
      the true variants from noise, and therefore the dependency on post-VCF filtering is substantially reduced.
      For this reason, the default post-VCF filtering in DRAGEN is very simple
    type: string?
  vc_sq_call_threshold:
    label: vc sq call threshold
    type: float?
    doc: |
      Emits calls in the VCF. The default is 3.
      If the value for vc-sq-filter-threshold is lower than vc-sq-callthreshold,
      the filter threshold value is used instead of the call threshold value
  vc_sq_filter_threshold:
    label: vc sq filter threshold
    type: float?
    doc: |
      Marks emitted VCF calls as filtered.
      The default is 17.5 for tumor-normal and 6.5 for tumor-only.
  vc_enable_triallelic_filter:
    label: vc enable triallelic filter
    type: boolean?
    doc: |
      Enables the multiallelic filter. The default is true.
  vc_enable_af_filter:
    label: vc enable af filter
    type: boolean?
    doc: |
      Enables the allele frequency filter. The default value is false. When set to true, the VCF excludes variants
      with allele frequencies below the AF call threshold or variants with an allele frequency below the AF filter
      threshold and tagged with low AF filter tag. The default AF call threshold is 1% and the default AF filter
      threshold is 5%.
      To change the threshold values, use the following command line options:
        --vc-af-callthreshold and --vc-af-filter-threshold.
  vc_af_call_threshold:
    label: vc af call threshold
    type: float?
    doc: |
      Set the allele frequency call threshold to emit a call in the VCF if the AF filter is enabled.
      The default is 0.01.
  vc_af_filter_threshold:
    label: vc af filter threshold
    type: float?
    doc: |
      Set the allele frequency filter threshold to mark emitted VCF calls as filtered if the AF filter is
      enabled.
      The default is 0.05.
  vc_enable_non_homref_normal_filter:
    label: vc enable non homoref normal filter
    doc: |
      Enables the non-homref normal filter. The default value is true. When set to true, the VCF filters out
      variants if the normal sample genotype is not a homozygous reference.
    type: boolean?

  # Mitochondrial allele frequency filters
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/MitochondrialCalling.htm
  vc_af_call_threshold_mito:
    label: vc af call threshold mito
    doc: |
      If the AF filter is enabled using --vc-enable-af-filter-mito=true,
      the option sets the allele frequency call threshold to emit a call in the VCF for mitochondrial variant calling.
      The default value is 0.01.
    type: boolean?
  vc_af_filter_threshold_mito:
    label: vc af filter threshold mito
    doc: |
      If the AF filter is enabled using --vc-enable-af-filter-mito=true,
      the option sets the allele frequency filter threshold to mark emitted VCF calls
      as filtered for mitochondrial variant calling. The default value is 0.02.
    type: float?

  # Enable non primary allelic filter
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/PostSomaticFilters.htm
  vc_enable_non_primary_allelic_filter:
    label: vc enable non primary allelic filter
    doc: |
      Similar to vc-enable-triallelic-filter, but less aggressive.
      Keep the allele per position with highest alt AD, and only filter the rest.
      The default is false. Not compatible with vc-enable-triallelic-filter.
    type: boolean?

  # Turn off ntd error bias estimation
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/SNVErrorEstimation.htm
  vc_enable_unequal_ntd:
    label: vc enable unequal ntd
    doc: |
      Nucleotide (NTD) Error Bias Estimation is on by default and recommended as a replacement for the orientation bias filter.
      Both methods take account of strand-specific biases (systematic differences between F1R2 and F2R1 reads).
      In addition, NTD error estimation accounts for non-strand-specific biases such as sample-wide elevation of a certain SNV type,
      eg C->T or any other transition or transversion.
      NTD error estimation can also capture the biases in a trinucleotide context.
    type:
      - "null"
      - boolean
      - type: enum
        symbols:
          - "true"
          - "false"
          - "auto"

  # dbSNP annotation
  dbsnp_annotation:
    label: dbsnp annotation
    doc: |
      In Germline, Tumor-Normal somatic, or Tumor-Only somatic modes,
      DRAGEN can look up variant calls in a dbSNP database and add annotations for any matches that it finds there.
      To enable the dbSNP database search, set the --dbsnp option to the full path to the dbSNP database
      VCF or .vcf.gz file, which must be sorted in reference order.
    type: File?
    secondaryFiles:
      - pattern: ".tbi"
        required: true

  # cnv pipeline - with this we must also specify one of --cnv-normal-b-allele-vcf,
  # --cnv-population-b-allele-vcf, or cnv-use-somatic-vc-baf.
  # If known, specify the sex of the sample.
  # If the sample sex is not specified, the caller attempts to estimate the sample sex from tumor alignments.
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/CopyNumVariantCalling.htm
  cnv_normal_b_allele_vcf:
    label: cnv normal b allele vcf
    doc: |
      Specify a matched normal SNV VCF.
    type: File?
  cnv_population_b_allele_vcf:
    label: cnv population b allele vcf
    doc: |
      Specify a population SNP catalog.
    type: File?
  cnv_use_somatic_vc_baf:
    label: cnv use somatic vc baf
    doc: |
      If running in tumor-normal mode with the SNV caller enabled, use this option
      to specify the germline heterozygous sites.
    type: boolean?
  # For more info on following options - see
  # https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/DRAGEN/SomaticWGSModes.htm#Germline
  cnv_normal_cnv_vcf:
    label: cnv normal cnv vcf
    doc: |
      Specify germline CNVs from the matched normal sample.
    type: boolean?
  cnv_use_somatic_vc_vaf:
    label: cnv use somatic vc vaf
    doc: |
      Use the variant allele frequencies (VAFs) from the somatic SNVs to help select
      the tumor model for the sample.
    type: boolean?
  cnv_somatic_enable_het_calling:
    label: cnv somatic enable het calling
    doc: |
      Enable HET-calling mode for heterogeneous segments.
    type: boolean?
  cnv_enable_self_normalization:
    label: cnv enable self normalization
    doc: |
      Enable CNV self normalization.
      Self Normalization requires that the DRAGEN hash table be generated with the enable-cnv=true option.
    type: boolean?
  cnv_somatic_enable_lower_ploidy_limit:
    label: cnv somatic enable lower ploidy limit
    doc: |
      To improve accuracy on the tumor ploidy model estimation, the somatic WGS CNV caller estimates whether the chosen model calls
      homozygous deletions on regions that are likely to reduce the overall fitness of cells,
      which are therefore deemed to be "essential" and under negative selection.
      In the current literature, recent efforts tried to map such cell-essential genes (eg, in 2015 - https://www.science.org/doi/10.1126/science.aac7041).
      The check on essential regions is controlled with --cnv-somatic-enable-lower-ploidy-limit (default true).
    type: boolean?
  cnv_somatic_essential_genes_bed:
    label: cnv somatic essential genes bed
    doc: |
      Default bedfiles describing the essential regions are provided for hg19, GRCh37, hs37d5, GRCh38,
      but a custom bedfile can also be provided in input through the
      --cnv-somatic-essential-genes-bed=<BEDFILE_PATH> parameter.
      In such case, the feature is automatically enabled.
      A custom essential regions bedfile needs to have the following format: 4-column, tab-separated,
      where the first 3 columns identify the coordinates of the essential region (chromosome, 0-based start, excluded end).
      The fourth column is the region id (string type). For the purpose of the algorithm, currently only the first 3 columns are used.
      However, the fourth might be helpful to investigate manually which regions drove the decisions on model plausibility made by the caller.
    type:
      - "null"
      - string
      - File

  # HRD
  enable_hrd:
    label: enable hrd
    doc: |
      Set to true to enable HRD scoring to quantify genomic instability.
      Requires somatic CNV calls.
    type: boolean?

  # QC options
  qc_coverage_region_1:
    label: qc coverage region 1
    doc: |
      Generates coverage region report using bed file 1.
    type: File?
  qc_coverage_region_2:
    label: qc coverage region 2
    doc: |
      Generates coverage region report using bed file 2.
    type: File?
  qc_coverage_region_3:
    label: qc coverage region 3
    doc: |
      Generates coverage region report using bed file 3.
    type: File?
  qc_coverage_ignore_overlaps:
    label: qc coverage ignore overlaps
    doc: |
      Set to true to resolve all of the alignments for each fragment and avoid double-counting any
      overlapping bases. This might result in marginally longer run times.
      This option also requires setting --enable-map-align=true.
    type: boolean?

  # TMB options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/Biomarkers_TMB.htm
  enable_tmb:
    label: enable tmb
    doc: |
      Enables TMB. If set, the small variant caller, Illumina Annotation Engine,
      and the related callability report are enabled.
    type: boolean?
  tmb_vaf_threshold:
    label: tmb vaf threshold
    doc: |
      Specify the minimum VAF threshold for a variant. Variants that do not meet the threshold are filtered out.
      The default value is 0.05.
    type: float?
  tmb_db_threshold:
    label: tmb db threshold
    doc: |
      Specify the minimum allele count (total number of observations) for an allele in gnomAD or 1000 Genome
      to be considered a germline variant.  Variant calls that have the same positions and allele are ignored
      from the TMB calculation. The default value is 10.
    type: int?

  # HLA calling
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/HLACaller.htm
  enable_hla:
    label: enable hla
    doc: |
      Enable HLA typing by setting --enable-hla flag to true
    type: boolean?
  hla_bed_file:
    label: hla bed file
    doc: |
      Use the HLA region BED input file to specify the region to extract HLA reads from.
      DRAGEN HLA Caller parses the input file for regions within the BED file, and then
      extracts reads accordingly to align with the HLA allele reference.
    type: File?
  hla_reference_file:
    label: hla reference file
    doc: |
      Use the HLA allele reference file to specify the reference alleles to align against.
      The input HLA reference file must be in FASTA format and contain the protein sequence separated into exons.
      If --hla-reference-file is not specified, DRAGEN uses hla_classI_ref_freq.fasta from /opt/edico/config/.
      The reference HLA sequences are obtained from the IMGT/HLA database.
    type: File?
  hla_allele_frequency_file:
    label: hla allele frequency file
    doc: |
      Use the population-level HLA allele frequency file to break ties if one or more HLA allele produces the same or similar results.
      The input HLA allele frequency file must be in CSV format and contain the HLA alleles and the occurrence frequency in population.
      If --hla-allele-frequency-file is not specified, DRAGEN automatically uses hla_classI_allele_frequency.csv from /opt/edico/config/.
      Population-level allele frequencies can be obtained from the Allele Frequency Net database.
    type: File?
  hla_tiebreaker_threshold:
    label: hla tiebreaker threshold
    doc: |
      If more than one allele has a similar number of reads aligned and there is not a clear indicator for the best allele,
      the alleles are considered as ties. The HLA Caller places the tied alleles into a candidate set for tie breaking based
      on the population allele frequency. If an allele has more than the specified fraction of reads aligned (normalized to
      the top hit), then the allele is included into the candidate set for tie breaking. The default value is 0.97.
    type: float?
  hla_zygosity_threshold:
    label: hla zygosity threshold
    doc: |
      If the minor allele at a given locus has fewer reads mapped than a fraction of the read count of the major allele,
      then the HLA Caller infers homozygosity for the given HLA-I gene. You can use this option to specify the fraction value.
      The default value is 0.15.
    type: float?
  hla_min_reads:
    label: hla min reads
    doc: |
      Set the minimum number of reads to align to HLA alleles to ensure sufficient coverage and perform HLA typing.
      The default value is 1000 and suggested for WES samples. If using samples with less coverage, you can use a
      lower threshold value.
    type: int?

  # RNA
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/TPipelineIntro_fDG.htm
  enable_rna:
    label: enable rna
    doc: |
      Set this option for running RNA samples through T/N workflow
    type: boolean?

  # Repeat Expansion
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/RepeatGenotyping.htm
  repeat_genotype_enable:
    label: repeat genotype enable
    doc: |
      Enables repeat expansion detection.
    type: boolean?
  repeat_genotype_specs:
    label: repeat genotype specs
    doc: |
      Specifies the full path to the JSON file that contains the
      repeat variant catalog (specification) describing the loci to call.
      If the option is not provided, DRAGEN attempts to autodetect the applicable catalog file
      from /opt/edico/repeat-specs/ based on the reference provided.
    type: File?
  repeat_genotype_use_catalog:
    label: repeat genotype use catalog
    doc: |
      Repeat variant catalog type to use (default - ~60 repeats, default_plus_smn -
      same as default with SMN repeat, expanded - ~50K repeats)
    type:
      - "null"
      - type: enum
        symbols:
          - default
          - default_plus_smn
          - expanded

  # Germline specific parameters
  # Force genotyping for gf
  vc_forcegt_vcf:
    label: vc forcegt vcf
    doc: |
      AGENsupports force genotyping (ForceGT) for Germline SNV variant calling.
      To use ForceGT, use the --vc-forcegt-vcf option with a list of small variants to force genotype.
      The input list of small variants can be a .vcf or .vcf.gz file.

      The current limitations of ForceGT are as follows:
      *	ForceGT is supported for Germline SNV variant calling in the V3 mode.
      The V1, V2, and V2+ modes are not supported.
      *	ForceGT is not supported for Somatic SNV variant calling.
      *	ForceGT variants do not propagate through Joint Genotyping.
    type: File?
    secondaryFiles:
      - pattern: ".tbi"
        required: true

  # Cross sample contamination
  qc_cross_cont_vcf:
    label: qc cross cont vcf
    doc: |
      The cross-contamination metric is enabled by including one of the following flags along with a compatible VCF.
      Pre-built contamination VCF files for different human references can be found at /opt/edico/config. 
      DRAGEN supports separate modes for germline and somatic samples. 
    type:
      - "null"
      - File
      - type: enum
        symbols:
          - "hg38"
          - "hg19"
          - "GRCh37"

  qc_somatic_contam_vcf:
    label: qc somatic contam vcf
    doc: |
      The cross-contamination metric is enabled by including one of the following flags along with a compatible VCF.
      Pre-built contamination VCF files for different human references can be found at /opt/edico/config. 
    type:
      - "null"
      - File
      - type: enum
        symbols:
          - "hg38"
          - "hg19"
          - "GRCh37"
    
  # Miscell
  lic_instance_id_location:
    label: license instance id location
    doc: |
      You may wish to place your own in.
      Optional value, default set to /opt/instance-identity
      which is a path inside the dragen container
    type:
      - File?
      - string?
    default: "/opt/instance-identity"


steps:
  # We run the germline and somatic tools in parallel
  # Run dragen germline workflow
  run_dragen_germline_step:
    label: run dragen germline step
    doc: |
      Runs the dragen germline workflow on the FPGA.
      Takes in either a fastq list as a file or a fastq_list_rows schema object
    in:
      # Option 1
      fastq_list_rows:
        source: fastq_list_rows
      # Option 2
      fastq_list:
        source: fastq_list
      # Option 3
      bam_input:
        source: bam_input
      # Option 4
      cram_input:
        source: cram_input
      cram_reference:
        source: cram_reference
      reference_tar:
        source: reference_tar
      output_file_prefix:
        source: output_prefix_germline
      output_directory:
        source: output_prefix_germline
        valueFrom: "$(self)_dragen_germline"
      enable_sort:
        source: [ enable_sort_germline, enable_sort]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      enable_map_align:
        source: [ enable_map_align_germline, enable_map_align ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      enable_map_align_output:
        source: [ enable_map_align_output_germline, enable_map_align_output ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      enable_duplicate_marking:
        source: [ enable_duplicate_marking_germline, enable_duplicate_marking ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      dedup_min_qual:
        source: [ dedup_min_qual_germline, dedup_min_qual ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      enable_sv:
        source: [ enable_sv_germline, enable_sv ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      enable_cnv:
        source: [ enable_cnv_germline, enable_cnv ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      # Variant calling options
      vc_base_qual_threshold:
        source: [ vc_base_qual_threshold_germline, vc_base_qual_threshold ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      vc_target_bed:
        source: vc_target_bed
      vc_target_bed_padding:
        source: vc_target_bed_padding
      vc_target_coverage:
        source: vc_target_coverage
      vc_enable_gatk_acceleration:
        source: vc_enable_gatk_acceleration
      vc_remove_all_soft_clips:
        source: vc_remove_all_soft_clips
      vc_decoy_contigs:
        source: vc_decoy_contigs
      vc_enable_decoy_contigs:
        source: vc_enable_decoy_contigs
      vc_enable_phasing:
        source: vc_enable_phasing
      vc_enable_vcf_output:
        source: vc_enable_vcf_output
      vc_max_reads_per_active_region:
        source: vc_max_reads_per_active_region
      vc_max_reads_per_raw_region:
        source: vc_max_reads_per_raw_region
      sample_sex:
        source: sample_sex
      vc_enable_roh:
        source: vc_enable_roh
      vc_roh_blacklist_bed:
        source: vc_roh_blacklist_bed
      vc_enable_baf:
        source: vc_enable_baf
      vc_hard_filter:
        source: vc_hard_filter
      vc_forcegt_vcf:
        source: vc_forcegt_vcf
      # Structural Variant Caller Options
      sv_call_regions_bed:
        source: sv_call_regions_bed
      sv_region:
        source: sv_region
      sv_exome:
        source: sv_exome
      sv_output_contigs:
        source: sv_output_contigs
      sv_forcegt_vcf:
        source: sv_forcegt_vcf
      sv_discovery:
        source: sv_discovery
      sv_se_overlap_pair_evidence:
        source: sv_se_overlap_pair_evidence
      sv_enable_liquid_tumor_mode:
        source: sv_enable_liquid_tumor_mode
      sv_tin_contam_tolerance:
        source: sv_tin_contam_tolerance
      dbsnp_annotation:
        source: dbsnp_annotation
      #cnv options
      cnv_enable_self_normalization:
        source: cnv_enable_self_normalization
      #qc options
      qc_coverage_region_1:
        source: qc_coverage_region_1
      qc_coverage_region_2:
        source: qc_coverage_region_2
      qc_coverage_region_3:
        source: qc_coverage_region_3
      qc_coverage_ignore_overlaps:
        source: qc_coverage_ignore_overlaps
      #hla
      enable_hla:
        source: enable_hla
      hla_bed_file:
        source: hla_bed_file
      hla_reference_file:
        source: hla_reference_file
      hla_allele_frequency_file:
        source: hla_allele_frequency_file
      hla_tiebreaker_threshold:
        source: hla_tiebreaker_threshold
      hla_zygosity_threshold:
        source: hla_zygosity_threshold
      hla_min_reads:
        source: hla_min_reads
      qc_cross_cont_vcf:
        source: qc_cross_cont_vcf
      lic_instance_id_location:
        source: lic_instance_id_location
    out:
      - id: dragen_germline_output_directory
      - id: dragen_bam_out
      - id: dragen_vcf_out
    run: ../../../tools/dragen-germline/4.3.6/dragen-germline__4.3.6.cwl
  run_dragen_somatic_step:
    label: run dragen somatic step
    doc: |
      Run dragen somatic v4.3.6
    in:
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/OptionReference.htm
      # Inputs fastq list csv or actual fastq list file with presigned urls for Read1File and Read2File columns
      # File inputs
      # Option 1
      fastq_list:
        source: fastq_list
      tumor_fastq_list:
        source: tumor_fastq_list
      # Option 2
      fastq_list_rows:
        source: fastq_list_rows
      tumor_fastq_list_rows:
        source: tumor_fastq_list_rows
      # Option 3
      bam_input:
        source: bam_input
      tumor_bam_input:
        source: tumor_bam_input
      # Option 4
      cram_input:
        source: cram_input
      tumor_cram_input:
        source: tumor_cram_input
      cram_reference:
        source: cram_reference
      reference_tar:
        source: reference_tar
      # Mandatory parameters
      output_file_prefix:
        source: output_prefix_somatic
      output_directory:
        source: output_prefix_somatic
        valueFrom: "$(self)_dragen_somatic"
      # Optional operation modes
      # Optional operation modes
      # Given we're running from fastqs
      # --enable-variant-caller option must be set to true (set in arguments), --enable-map-align is then activated by default
      # --enable-map-align-output to keep bams
      # --enable-duplicate-marking to mark duplicate reads at the same time
      # --enable-sv to enable the structural variant calling step.
      enable_sort:
        source: [ enable_sort_somatic, enable_sort ]
        valueFrom: |
          ${
              return get_first_non_null_input(self);
          }
      enable_map_align:
        source: [ enable_map_align_somatic, enable_map_align ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      enable_map_align_output:
        source: [ enable_map_align_output_somatic, enable_map_align_output ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      enable_duplicate_marking:
        source: [ enable_duplicate_marking_somatic, enable_duplicate_marking ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      dedup_min_qual:
        source: [ dedup_min_qual_somatic, dedup_min_qual ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      enable_sv:
        source: [ enable_sv_somatic, enable_sv ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      enable_cnv:
        source: [ enable_cnv_somatic, enable_cnv ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      # Phased / MNV Calling Options
      # Phased / MNV Calling options
      vc_combine_phased_variants_distance:
        source: vc_combine_phased_variants_distance_somatic
      vc_combine_phased_variants_max_vaf_delta:
        source: vc_combine_phased_variants_max_vaf_delta_somatic
      vc_mnv_emit_component_calls:
        source: vc_mnv_emit_component_calls_somatic
      # Structural Variant Caller Options
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/StructuralVariantCalling.htm
      sv_call_regions_bed:
        source: sv_call_regions_bed
      sv_region:
        source: sv_region
      sv_exome:
        source: sv_exome
      sv_output_contigs:
        source: sv_output_contigs
      sv_forcegt_vcf:
        source: sv_forcegt_vcf
      sv_discovery:
        source: sv_discovery
      sv_se_overlap_pair_evidence:
        source: sv_se_overlap_pair_evidence
      sv_somatic_ins_tandup_hotspot_regions_bed:
        source: sv_somatic_ins_tandup_hotspot_regions_bed
      sv_enable_somatic_ins_tandup_hotspot_regions:
        source: sv_enable_somatic_ins_tandup_hotspot_regions
      sv_enable_liquid_tumor_mode:
        source: sv_enable_liquid_tumor_mode
      sv_tin_contam_tolerance:
        source: sv_tin_contam_tolerance
      # Variant calling options
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/SmallVariantCaller.htm
      vc_base_qual_threshold:
        source: [ vc_base_qual_threshold_somatic, vc_base_qual_threshold ]
        valueFrom: |
          ${
            return get_first_non_null_input(self);
          }
      vc_target_bed:
        source: vc_target_bed
      vc_target_bed_padding:
        source: vc_target_bed_padding
      vc_target_coverage:
        source: vc_target_coverage
      vc_target_vaf:
        source: vc_target_vaf_somatic
      vc_enable_gatk_acceleration:
        source: vc_enable_gatk_acceleration
      vc_remove_all_soft_clips:
        source: vc_remove_all_soft_clips
      vc_decoy_contigs:
        source: vc_decoy_contigs
      vc_enable_decoy_contigs:
        source: vc_enable_decoy_contigs
      vc_enable_phasing:
        source: vc_enable_phasing
      vc_enable_vcf_output:
        source: vc_enable_vcf_output
      # Downsampling options
      vc_max_reads_per_active_region:
        source: vc_max_reads_per_active_region
      vc_max_reads_per_raw_region:
        source: vc_max_reads_per_raw_region
      # Ploidy support
      sample_sex:
        source: sample_sex
      # ROH options
      vc_enable_roh:
        source: vc_enable_roh
      vc_roh_blacklist_bed:
        source: vc_roh_blacklist_bed
      # BAF options
      vc_enable_baf:
        source: vc_enable_baf
      # Somatic calling options
      vc_hard_filter:
        source: vc_hard_filter
      vc_min_tumor_read_qual:
        source: vc_min_tumor_read_qual
      vc_callability_tumor_thresh:
        source: vc_callability_tumor_thresh
      vc_callability_normal_thresh:
        source: vc_callability_normal_thresh
      vc_somatic_hotspots:
        source: vc_somatic_hotspots
      vc_hotspot_log10_prior_boost:
        source: vc_hotspot_log10_prior_boost
      vc_enable_liquid_tumor_mode:
        source: vc_enable_liquid_tumor_mode
      vc_tin_contam_tolerance:
        source: vc_tin_contam_tolerance
      vc_enable_orientation_bias_filter:
        source: vc_enable_orientation_bias_filter
      vc_enable_orientation_bias_filter_artifacts:
        source: vc_enable_orientation_bias_filter_artifacts
      # Post somatic calling filtering options
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/PostSomaticFilters.htm
      vc_sq_call_threshold:
        source: vc_sq_call_threshold
      vc_sq_filter_threshold:
        source: vc_sq_filter_threshold
      vc_enable_triallelic_filter:
        source: vc_enable_triallelic_filter
      vc_enable_af_filter:
        source: vc_enable_af_filter
      vc_af_call_threshold:
        source: vc_af_call_threshold
      vc_af_filter_threshold:
        source: vc_af_filter_threshold
      vc_enable_non_homref_normal_filter:
        source: vc_enable_non_homref_normal_filter
      # Mitochondrial allele frequency filters
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/MitochondrialCalling.htm
      vc_af_call_threshold_mito:
        source: vc_af_call_threshold_mito
      vc_af_filter_threshold_mito:
        source: vc_af_filter_threshold_mito
      # Enable non primary allelic filter
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/PostSomaticFilters.htm
      vc_enable_non_primary_allelic_filter:
        source: vc_enable_non_primary_allelic_filter
      # Turn off ntd error bias estimation
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/SNVErrorEstimation.htm
      vc_enable_unequal_ntd:
        source: vc_enable_unequal_ntd
      # dbSNP annotation
      dbsnp_annotation:
        source: dbsnp_annotation
      # cnv pipeline - with this we must also specify one of --cnv-normal-b-allele-vcf,
      # --cnv-population-b-allele-vcf, or cnv-use-somatic-vc-baf.
      # If known, specify the sex of the sample.
      # If the sample sex is not specified, the caller attempts to estimate the sample sex from tumor alignments.
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/CopyNumVariantCalling.htm
      cnv_enable_self_normalization:
        source: cnv_enable_self_normalization
      cnv_normal_b_allele_vcf:
        source: cnv_normal_b_allele_vcf
      cnv_population_b_allele_vcf:
        source: cnv_population_b_allele_vcf
      cnv_use_somatic_vc_baf:
        source: cnv_use_somatic_vc_baf
      # For more info on following options - see
      # https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/DRAGEN/SomaticWGSModes.htm#Germline
      cnv_normal_cnv_vcf:
        source: cnv_normal_cnv_vcf
      cnv_use_somatic_vc_vaf:
        source: cnv_use_somatic_vc_vaf
      cnv_somatic_enable_het_calling:
        source: cnv_somatic_enable_het_calling
      # Somatic specific CNV calling options
      cnv_somatic_enable_lower_ploidy_limit:
        source: cnv_somatic_enable_lower_ploidy_limit
      cnv_somatic_essential_genes_bed:
        source: cnv_somatic_essential_genes_bed
      # HRD
      enable_hrd:
        source: enable_hrd
      # QC options
      qc_coverage_region_1:
        source: qc_coverage_region_1
      qc_coverage_region_2:
        source: qc_coverage_region_2
      qc_coverage_region_3:
        source: qc_coverage_region_3
      qc_coverage_ignore_overlaps:
        source: qc_coverage_ignore_overlaps
      # TMB options
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/Biomarkers_TMB.htm
      enable_tmb:
        source: enable_tmb
      tmb_vaf_threshold:
        source: tmb_vaf_threshold
      tmb_db_threshold:
        source: tmb_db_threshold
      # HLA calling
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/HLACaller.htm
      enable_hla:
        source: enable_hla
      hla_bed_file:
        source: hla_bed_file
      hla_reference_file:
        source: hla_reference_file
      hla_allele_frequency_file:
        source: hla_allele_frequency_file
      hla_tiebreaker_threshold:
        source: hla_tiebreaker_threshold
      hla_zygosity_threshold:
        source: hla_zygosity_threshold
      hla_min_reads:
        source: hla_min_reads
      # RNA
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/TPipelineIntro_fDG.htm
      enable_rna:
        source: enable_rna
      # Repeat Expansion
      # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/RepeatGenotyping.htm
      repeat_genotype_enable:
        source: repeat_genotype_enable
      repeat_genotype_specs:
        source: repeat_genotype_specs
      repeat_genotype_use_catalog:
        source: repeat_genotype_use_catalog
      qc_somatic_contam_vcf:
        source: qc_somatic_contam_vcf
      # Miscell
      lic_instance_id_location:
        source: lic_instance_id_location
    out:
      # Will also include mounted-files.txt
      - id: dragen_somatic_output_directory
      # Optional output files (inside the output directory) that we'll continue to append to as we need them
      - id: tumor_bam_out
      - id: normal_bam_out
      - id: somatic_snv_vcf_out
      - id: somatic_snv_vcf_hard_filtered_out
      - id: somatic_structural_vcf_out
    run: ../../../tools/dragen-somatic/4.3.6/dragen-somatic__4.3.6.cwl

  # Run the multiqc step
  run_dragen_qc_step:
    label: dragen qc step
    doc: |
      The dragen qc step - this takes in an array of dirs
    in:
      input_directories:
        source:
          - run_dragen_germline_step/dragen_germline_output_directory
          - run_dragen_somatic_step/dragen_somatic_output_directory
      output_directory_name:
        source: [ output_prefix_somatic, output_prefix_germline]
        valueFrom: "$(self[0])__$(self[1])_dragen_somatic_and_germline_multiqc"
      output_filename:
        source: [ output_prefix_somatic, output_prefix_germline]
        valueFrom: "$(self[0])__$(self[1])_dragen_somatic_and_germline_multiqc.html"
      title:
        source: [ output_prefix_somatic, output_prefix_germline]
        valueFrom: "UMCCR MultiQC Dragen Somatic And Germline Report for $(self[0])__$(self[1])"
    out:
      - id: output_directory
    run: ../../../tools/multiqc/1.25.1/multiqc__1.25.1.cwl
  get_normal_bam_out:
    label: get normal bam out
    doc: |
      Get the normal bam value from one of the two available options
      From the germline step (preferred)
      From the somatic step (backup option)
    in:
      input_bams:
        source:
          - run_dragen_germline_step/dragen_bam_out
          - run_dragen_somatic_step/normal_bam_out
    out:
      - id: output_bam_file
    run: ../../../expressions/get-first-non-null-bam-file/1.0.0/get-first-non-null-bam-file__1.0.0.cwl

outputs:
  # Will also include mounted-files.txt
  dragen_somatic_output_directory:
    label: dragen somatic output directory
    doc: |
      Output directory containing all outputs of the somatic dragen run
    type: Directory
    outputSource: run_dragen_somatic_step/dragen_somatic_output_directory
  dragen_germline_output_directory:
    label: dragen germline output directory
    doc: |
      The output directory containing all germline output files
    type: Directory
    outputSource: run_dragen_germline_step/dragen_germline_output_directory
  germline_snv_vcf_out:
    label: germline snv vcf out
    doc: |
      The output vcf file of germline step
    type: File?
    outputSource: run_dragen_germline_step/dragen_vcf_out
  # Optional output files (inside the output directory) that we'll continue to append to as we need them
  tumor_bam_out:
    label: output tumor bam
    doc: |
      Bam file of the tumor sample
    type: File?
    outputSource: run_dragen_somatic_step/tumor_bam_out
  normal_bam_out:
    label: output normal bam
    doc: |
      Bam file of the normal sample
    type: File?
    outputSource: get_normal_bam_out/output_bam_file
  somatic_snv_vcf_out:
    label: somatic snv vcf
    doc: |
      Output of the snv vcf tumor calls
    type: File?
    outputSource: run_dragen_somatic_step/somatic_snv_vcf_out
  somatic_snv_vcf_hard_filtered_out:
    label: somatic snv vcf filetered
    doc: |
      Output of the snv vcf filtered tumor calls
    type: File?
    outputSource: run_dragen_somatic_step/somatic_snv_vcf_hard_filtered_out
  somatic_structural_vcf_out:
    label: somatic sv vcf filetered
    doc: |
      Output of the sv vcf filtered tumor calls.
      Exists only if --enable-sv is set to true.
    type: File?
    outputSource: run_dragen_somatic_step/somatic_structural_vcf_out
  multiqc_output_directory:
    label: multiqc output directory
    doc: |
      The output directory for multiqc
    type: Directory
    outputSource: run_dragen_qc_step/output_directory
