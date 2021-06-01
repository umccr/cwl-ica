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

# ID/Docs
id: dragen-somatic--3.7.5
label: dragen-somatic v(3.7.5)
doc: |
  Run tumor-normal dragen somatic pipeline
  v 3.7.5.
  Workflow takes in two separate lists of object stor version of the fastq_list.csv equivalent
  See the fastq_list_row schema definitions for more information.
  More information on the documentation can be found [here](https://sapac.support.illumina.com/content/dam/illumina-support/help/Illumina_DRAGEN_Bio_IT_Platform_v3_7_1000000141465/Content/SW/Informatics/Dragen/GPipelineSomCom_appDRAG.htm)

requirements:
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
      - $import: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml

# Declare inputs
inputs:
  # File inputs
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
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]
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
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]
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
  enable_map_align_output:
    label: enable map align output
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
  enable_sv:
    label: enable sv
    doc: |
      Enable/disable structural variant
      caller. Default is false.
    type: boolean?
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
  # Create fastq_list.csv
  create_fastq_list_csv_step:
    label: create fastq list csv step
    doc: |
      Create the normal fastq list csv to then run the somatic tool.
      Takes in an array of fastq_list_row schema.
      Returns a csv file along with predefined_mount_path schema
    in:
      fastq_list_rows:
        source: fastq_list_rows
    out:
      - fastq_list_csv_out
      - predefined_mount_paths_out
    run: ../../../tools/custom-create-csv-from-fastq-list-rows/1.0.0/custom-create-csv-from-fastq-list-rows__1.0.0.cwl
  # Create fastq_list.csv
  create_tumor_fastq_list_csv_step:
    label: create tumor fastq list csv step
    doc: |
      Create the tumor fastq list csv to then run the somatic tool.
      Takes in an array of fastq_list_row schema.
      Returns a csv file along with predefined_mount_path schema
    in:
      fastq_list_rows:
        source: tumor_fastq_list_rows
    out:
      - fastq_list_csv_out
      - predefined_mount_paths_out
    run: ../../../tools/custom-create-csv-from-fastq-list-rows/1.0.0/custom-create-csv-from-fastq-list-rows__1.0.0.cwl
  # Run dragen somatic workflow
  run_dragen_somatic_step:
    label: run dragen somatic step
    doc: |
      Runs the dragen somatic workflow on the FPGA.
      Takes in a normal and tumor fastq list and corresponding mount paths from the predefined_mount_paths.
      All other options avaiable at the top of the workflow
    in:
      fastq_list:
        source: create_fastq_list_csv_step/fastq_list_csv_out
      fastq_list_mount_paths:
        source: create_fastq_list_csv_step/predefined_mount_paths_out
      tumor_fastq_list:
        source: create_tumor_fastq_list_csv_step/fastq_list_csv_out
      tumor_fastq_list_mount_paths:
        source: create_tumor_fastq_list_csv_step/predefined_mount_paths_out
      reference_tar:
        source: reference_tar
      output_directory:
        source: output_directory
      output_file_prefix:
        source: output_file_prefix
      enable_map_align_output:
        source: enable_map_align_output
      enable_duplicate_marking:
        source: enable_duplicate_marking
      enable_sv:
        source: enable_sv
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
      lic_instance_id_location:
        source: lic_instance_id_location
    out:
      - dragen_somatic_output_directory
      - tumor_bam_out
      - normal_bam_out
      - somatic_snv_vcf_out
      - somatic_snv_vcf_hard_filtered_out
      - somatic_structural_vcf_out
    run: ../../../tools/dragen-somatic/3.7.5/dragen-somatic__3.7.5.cwl

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
