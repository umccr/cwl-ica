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
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

s:maintainer:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: dragen-somatic-pipeline--3.9.3
label: dragen-somatic-pipeline v(3.9.3)
doc: |
  Run tumor-normal dragen somatic pipeline
  v 3.9.3.
  Workflow takes in two separate lists of object stor version of the fastq_list.csv equivalent
  See the fastq_list_row schema definitions for more information.
  More information on the documentation can be found [here](https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/FrontPages/DRAGEN.htm)

requirements:
  StepInputExpressionRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement:
    expressionLib:
      - var pick_value_first_non_null = function(input_array){
          /*
          Iterate through input_array, return first non null input
          Replacement for pickValue of CWL 1.2
          */
          var return_val = null;
          var iterator = 0;
          while (return_val === null) {
            return_val = input_array[iterator];
            iterator += 1;
          }
          return return_val;
        }
      - var get_first_string_or_second_string_with_suffix = function(input_obj, suffix){
          /*
          Determine if first input has been determined.
          Fall back to second with suffix otherwise
          */
          return pick_value_first_non_null([input_obj[0], input_obj[1] + suffix]);
        }
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml

# Declare inputs
inputs:
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
  # Input bams
  bam_input:
    label: bam input
    doc: |
      Input a BAM file for the variant calling stage
    type: File?
    secondaryFiles:
      - pattern: ".bai"
        required: true
  tumor_bam_input:
    label: tumor bam input
    doc: |
      Input a BAM file for the variant calling stage
    type: File?
    secondaryFiles:
      - pattern: ".bai"
        required: true
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
  # Naming options
  output_directory:
    label: output directory
    doc: |
      Required - The output directory.
    type: string
  output_file_prefix:
    label: output file prefix
    doc: |
      Required - the output file prefix
    type: string
  # Optional operation modes
  # Given we're running from fastqs
  # --enable-variant-caller option must be set to true (set in arguments), --enable-map-align is then activated by default
  # --enable-map-align-output to keep bams
  # --enable-duplicate-marking to mark duplicate reads at the same time
  # --enable-sv to enable the structural variant calling step.
  enable_sort:
    label: enable sort
    doc: |
      True by default, only set this to false if using --bam-input and --tumor-bam-input parameters
    type: boolean?
  enable_map_align:
    label: enable map align
    doc: |
      Enabled by default since --enable-variant-caller option is set to true.
      Set this value to false if using bam_input AND tumor_bam_input
    type: boolean?
  enable_map_align_output:
    label: enable map align output
    doc: |
      Enables saving the output from the
      map/align stage. Default is true when only
      running map/align. Default is false if
      running the variant caller.
    type: boolean
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Enable the flagging of duplicate output
      alignment records.
    type: boolean
  enable_sv:
    label: enable sv
    doc: |
      Enable/disable structural variant
      caller. Default is false.
    type: boolean?
  # Structural Variant Caller Options
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
      The value must be in the format “chr:startPos-endPos”..
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
      You can enter any value between 0–1. The default maximum TiN contamination tolerance is 0.15.
    type: float?
  # Variant calling optons
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
      The –vc-enable-phasing option enables variants to be phased when possible. The default value is true.
    type: boolean?
  vc_enable_vcf_output:
    label: vc enable vcf output
    doc: |
      The –vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.
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
     --vc-tin-contam-tolerance enables liquid tumor mode and allows you to
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
      For example, C/T,G/A is not valid, because C→G and T→A are reverse compliments.
  # Post somatic calling filtering options
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
    type: boolean?
    doc: |
      Enables the non-homref normal filter. The default value is true. When set to true, the VCF filters out
      variants if the normal sample genotype is not a homozygous reference.
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
  # cnv pipeline
  enable_cnv:
    label: enable cnv calling
    doc: |
      Enable CNV processing in the DRAGEN Host Software.
    type: boolean?
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
  # RNA options
  enable_rna:
    label: enable rna
    doc: |
      Set this option for running RNA samples through T/N workflow
    type: boolean?
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

steps:
  # Run dragen somatic workflow
  run_dragen_somatic_step:
    label: run dragen somatic step
    doc: |
      Runs the dragen somatic workflow on the FPGA.
      Takes in a normal and tumor fastq list and corresponding mount paths from the predefined_mount_paths.
      All other options avaiable at the top of the workflow
    in:
      fastq_list:
        source: fastq_list
      tumor_fastq_list:
        source: tumor_fastq_list
      fastq_list_rows:
        source: fastq_list_rows
      tumor_fastq_list_rows:
        source: tumor_fastq_list_rows
      bam_input:
        source: bam_input
      tumor_bam_input:
        source: tumor_bam_input
      reference_tar:
        source: reference_tar
      output_directory:
        source: output_directory
      output_file_prefix:
        source: output_file_prefix
      enable_sort:
        source: enable_sort
      enable_map_align:
        source: enable_map_align
      enable_map_align_output:
        source: enable_map_align_output
      enable_duplicate_marking:
        source: enable_duplicate_marking
      enable_sv:
        source: enable_sv
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
      sv_somatic_ins_tandup_hotspot_regions_bed:
        source: sv_somatic_ins_tandup_hotspot_regions_bed
      sv_enable_somatic_ins_tandup_hotspot_regions:
        source: sv_enable_somatic_ins_tandup_hotspot_regions
      sv_enable_liquid_tumor_mode:
        source: sv_enable_liquid_tumor_mode
      sv_tin_contam_tolerance:
        source: sv_tin_contam_tolerance
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
      dbsnp_annotation:
        source: dbsnp_annotation
      #cnv options
      enable_cnv:
        source: enable_cnv
      cnv_normal_b_allele_vcf:
        source: cnv_normal_b_allele_vcf
      cnv_population_b_allele_vcf:
        source: cnv_population_b_allele_vcf
      cnv_use_somatic_vc_baf:
        source: cnv_use_somatic_vc_baf
      cnv_normal_cnv_vcf:
        source: cnv_normal_cnv_vcf
      cnv_use_somatic_vc_vaf:
        source: cnv_use_somatic_vc_vaf
      cnv_somatic_enable_het_calling:
        source: cnv_somatic_enable_het_calling
      enable_hrd:
        source: enable_hrd
      qc_coverage_region_1:
        source: qc_coverage_region_1
      qc_coverage_region_2:
        source: qc_coverage_region_2
      qc_coverage_region_3:
        source: qc_coverage_region_3
      qc_coverage_ignore_overlaps:
        source: qc_coverage_ignore_overlaps
      enable_tmb:
        source: enable_tmb
      tmb_vaf_threshold:
        source: tmb_vaf_threshold
      tmb_db_threshold:
        source: tmb_db_threshold
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
      enable_rna:
        source: enable_rna
    out:
      - id: dragen_somatic_output_directory
      - id: tumor_bam_out
      - id: normal_bam_out
      - id: somatic_snv_vcf_out
      - id: somatic_snv_vcf_hard_filtered_out
      - id: somatic_structural_vcf_out
    run: ../../../tools/dragen-somatic/3.9.3/dragen-somatic__3.9.3.cwl
  # Create dummy file
  create_dummy_file_step:
    label: Create dummy file
    doc: |
      Intermediate step for letting multiqc-interop be placed in stream mode
    in: { }
    out:
      - id: dummy_file_output
    run: ../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl
  # Create a Dragen specific QC report
  dragen_qc_step:
    label: dragen qc step
    doc: |
      The dragen qc step - this takes in an array of dirs
    requirements:
      DockerRequirement:
        dockerPull: quay.io/umccr/multiqc:1.13dev--alexiswl--merge-docker-update-and-clean-names--a5e0179
    in:
      input_directories:
        source: run_dragen_somatic_step/dragen_somatic_output_directory
        valueFrom: |
          ${
            return [self];
          }
      output_directory_name:
        source: output_file_prefix
        valueFrom: "$(self)_dragen_somatic_multiqc"
      output_filename:
        source: output_file_prefix
        valueFrom: "$(self)_dragen_somatic_multiqc.html"
      title:
        source: output_file_prefix
        valueFrom: "UMCCR MultiQC Dragen Somatic Report for $(self)"
      dummy_file:
        source: create_dummy_file_step/dummy_file_output
    out:
      - id: output_directory
    run: ../../../tools/multiqc/1.14.0/multiqc__1.14.0.cwl

outputs:
  # Will also include mounted-files.txt
  dragen_somatic_output_directory:
    label: dragen somatic output directory
    doc: |
      Output directory containing all outputs of the somatic dragen run
    type: Directory
    outputSource: run_dragen_somatic_step/dragen_somatic_output_directory
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
    outputSource: run_dragen_somatic_step/normal_bam_out
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
    outputSource: dragen_qc_step/output_directory
