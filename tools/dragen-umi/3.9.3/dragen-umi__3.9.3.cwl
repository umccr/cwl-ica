cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: http://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: dragen-umi--3.9.3
label: dragen-umi v(3.9.3)
doc: |
    DRAGEN can process data from whole genome and hybrid-capture assays with unique molecular identifiers (UMI).
    This workflow can take forward, reverse and UMI tumor fastqs as inputs and perform the analysis in tumor-only mode.
    In additon, BAM from tumor and normal samples can be used as an input to perform analysis in tumor-normal mode. 
    More information on the documentation can be found [here](https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/DRAGEN/UMIs.htm)

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: fpga
        ilmn-tes:resources/size: medium
    DockerRequirement:
        dockerPull: "699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:3.9.3"

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_script_path = function(){
          /*
          Abstract script path, can then be referenced in baseCommand attribute too
          Makes things more readable.  FIXME
          */
          return "scripts/run-dragen-script.sh";
        }
      - var get_dragen_bin_path = function(){
          /*
          Return the path of the dragen binary
          */
          return "/opt/edico/bin/dragen";
        }
      - var get_scratch_mount = function(){
          /*
          Return the path of the scratch directory space
          */
          return "/ephemeral/";
        }
      - var get_intermediate_results_dir = function() {
          /*
          Place of the intermediate results files
          */
          return get_scratch_mount() + "intermediate-results/";
        }
      - var get_ref_mount = function() {
          /*
          Return the path of where the reference data is to be staged
          */
          return get_scratch_mount() + "ref/";
        }
      - var get_name_root_from_tarball = function(tar_file) {
          /*
          Get the name of the reference folder
          */
          var tar_ball_regex = /(\S+)\.tar\.gz/g;
          return tar_ball_regex.exec(tar_file)[1];
        }
      - var get_ref_path = function(input_obj) {
          /*
          Return the path of where the reference data is staged + the reference name
          */
          return get_ref_mount() + get_name_root_from_tarball(input_obj.basename) + "/";
        }
      - var get_script_contents = function(){
          /*
          Split dirent out from the listing JS.
          Makes things a little more readable
          Split arguments over multiple lines for greater readability
          Use full long arguments where possible
          */
          return "#!/usr/bin/env bash\n" +
          "\n" +
          "# Fail on non-zero exit of subshell\n" +
          "set -euo pipefail\n" +
          "\n" +
          "# Initialise dragen\n" +
          "/opt/edico/bin/dragen \\\n" +
          "  --partial-reconfig DNA-MAPPER \\\n" +
          "  --ignore-version-check true\n" +
          "\n" +
          "# Create directories\n" +
          "mkdir --parents \\\n" +
          "  \"" + get_ref_mount() + "\" \\\n" +
          "  \"" + get_intermediate_results_dir() + "\" \\\n" +
          "  \"" + inputs.output_directory + "\"\n" +
          "\n" +
          "# untar ref data into scratch space\n" +
          "tar \\\n" +
          "  --directory \"" + get_ref_mount() + "\" \\\n" +
          "  --extract \\\n" +
          "  --file \"" + inputs.reference_tar.path + "\"\n" +
          "\n" +
          "# Run dragen command and import options from cli\n" +
          "eval \"" + get_dragen_bin_path() + "\" '\"\$@\"' \n";
        }
  InitialWorkDirRequirement:
    listing: |
      ${
          /*
          Initialise the array of files to mount
          Add in the script path and the script contents
          */

          var e = [{
                      "entryname": get_script_path(),
                      "entry": get_script_contents()
                   }];

          /*
          Return file paths
          */
          return e;
      }


baseCommand: [ "bash" ]

arguments:
  # Run Script
  - position: -1
    valueFrom: "$(get_script_path())"
  # Mandatory arguments for the somatic workflow
  - prefix: "--enable-variant-caller"
    valueFrom: "true"
  # Parameters that are always true
  - prefix: "--intermediate-results-dir"
    valueFrom: "$(get_intermediate_results_dir())"

inputs:
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball.
    type: File
    inputBinding:
      prefix: "--ref-dir"
      valueFrom: "$(get_ref_path(self))"
  fastq_file1:
    label: fastq file1
    doc: |
      Path to R1 fastq file
    type: File?
    inputBinding:
      prefix: "--fastq-file1"
  fastq_file2:
    label: fastq file2
    doc: |
      Path to R3 fastq file
    type: File?
    inputBinding:
      prefix: "--fastq-file2"
  umi_fastq:
    label: umi fastq
    doc: |
      Path to R2 fastq file (UMI). Made optional to be able to use this 
      file for normal samples as well (without UMIs)
    type: File?
    inputBinding:
      prefix: "--umi-fastq"
  # BAM inputs - Currently UMI Dragen pipeline does not support tumor-normal mode. 
  # To run ctDNA samples in this setting, bam files created separately from tumour-only 
  # UMI pipeline and normal sample can be used as an input for doing variant calling.
  # bam_input and tumor_bam_input are incompatible with fastq-file* inputs.
  tumor_bam_input:
    label: tumor bam
    doc: |
      Path to tumor bam
    type: File?
    secondaryFiles:
      - .bai
    inputBinding:
      prefix: "--tumor-bam-input"
  bam_input:
    label: normal bam
    doc: |
      Path to normal bam
    type: File?
    secondaryFiles:
      - .bai
    inputBinding:
      prefix: "--bam-input"
  # Output naming options
  output_file_prefix:
    label: output file prefix
    doc: |
      The prefix given to all output files.
    type: string
    inputBinding:
      prefix: "--output-file-prefix"
  output_directory:
    label: output directory
    doc: |
      The directory where all output files are placed.
    type: string
    inputBinding:
      prefix: "--output-directory"
  #RG options
  rgid_tumor:
    label: rgid tumor
    doc: |
      The read group ID of the tumor sample
    type: string?
    inputBinding:
      prefix: "--RGID-tumor"
  rgsm_tumor:
    label: rgsm tumor 
    doc: |
      The sample name of the tumor sample
    type: string?
    inputBinding:
      prefix: "--RGSM-tumor"
  rgid:
    label: rgid
    doc: |
      The read group ID of the normal sample
    type: string?
    inputBinding:
      prefix: "--RGID"
  rgsm:
    label: rgsm tumor 
    doc: |
      The sample name of the normal sample
    type: string?
    inputBinding:
      prefix: "--RGSM"
  # Optional operation modes
  # Given we're running from fastqs
  # --enable-variant-caller option must be set to true (set in arguments), --enable-map-align is then activated by default
  # --enable-map-align-output to keep bams
  # If using tumor and normal bam inputs, set --enable-map-align to false as
  # Dragen cannot enable map-align with multiple bam/cram inputs.
  # --enable-duplicate-marking to mark duplicate reads at the same time
  # --enable-sv to enable the structural variant calling step.
  enable_map_align:
    label: enable map align output
    doc: |
      Enables saving the output from the
      map/align stage. Default is true when only
      running map/align. Default is false if
      running the variant caller.
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align"
      valueFrom: "$(self.toString())"
  enable_map_align_output:
    label: enable map align output
    doc: |
      Enables saving the output from the
      map/align stage. Default is true when only
      running map/align. Default is false if
      running the variant caller.
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align-output"
      valueFrom: "$(self.toString())"
  enable_sort:
    label: enable sort
    doc: | 
      The map/align system produces a BAM file sorted by 
      reference sequence and position by default. 
    type: boolean?
    inputBinding:
      prefix: "‑‑enable-sort"
      valueFrom: "$(self.toString())"
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Enable the flagging of duplicate output
      alignment records.
    type: boolean?
    inputBinding:
      prefix: "--enable-duplicate-marking"
      valueFrom: "$(self.toString())"
  enable_sv:
    label: enable sv
    doc: |
      Enable/disable structural variant
      caller. Default is false.
    type: boolean?
    inputBinding:
      prefix: "--enable-sv"
      valueFrom: "$(self.toString())"
  #UMI pipeline specific parameters
  umi_source:
    label: umi source
    doc: |
      Value should be 'fastq' if UMI info is in separate fastq file
    type: string?
    inputBinding:
      prefix: "--umi-source"
  umi_library_type:
    label: umi library type
    doc: |
      Value should be 'random-simplex' for our use case. 
      Set the batch option for different UMIs correction
    type: string?
    inputBinding:
      prefix: "--umi-library-type"
  umi_metrics_interval_file:
    label: umi metrics interval file
    doc: |
      Valid target BED file
    type: File?
    inputBinding:
      prefix: "--umi-metrics-interval-file"
  umi_min_supporting_reads:
    label: umi min spporting reads
    doc: |
      The number of matching UMI inputs reads required 
      to generate a consensus read.
    type: int?
    inputBinding:
      prefix: "--umi-min-supporting-reads"
  umi_enable:
    label: umi enable
    doc: |
      To enable read collapsing, set the --umi-enable option to true. 
      If using the --umi-library-type option, --umi-enable is not required.
    type: boolean?
    inputBinding:
      prefix: "--umi-enable"
      valueFrom: "$(self.toString())"
  umi_emit_multiplicity:
    label: umi emit multiplicity
    doc: |
      Set the consensus sequence type to output.
      Default value is "both" that outputs both simplex and duplex sequences.
    type:
      - "null"
      - type: enum
        symbols:
          - both
          - duplex
          - simplex
    inputBinding:
      prefix: "--umi-emit-multiplicity"
  umi_correction_table:
    label: umi correction table
    doc: |
      Enter the path to a customized correction table.
    type: File?
    inputBinding:
      prefix: "--umi-correction-table"
  vc_enable_umi_solid:
    label: vc enable umi solid
    doc: |
      Enables solid tumor UMI settings. The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-umi-solid"
      valueFrom: "$(self.toString())"
  vc_enable_umi_liquid:
    label: vc enable umi liquid
    doc: |
      Enables liquid tumor UMI settings. The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-umi-liquid"
      valueFrom: "$(self.toString())"
  umi_correction_scheme:
    label: umi correction scheme
    doc: |
      Describes the methodology to use for correcting sequencing errors in UMIs.
    type:
      - "null"
      - type: enum
        symbols:
          - lookup
          - random
          - none
          - positional
    inputBinding:
      prefix: "--umi-correction-scheme"
  umi_nonrandom_whitelist:
    label: umi nonrandom whitelist
    doc: |
      Provides the path to a file containing valid nonrandom UMIs sequences. Enter one path per line.
    type: File?
    inputBinding:
      prefix: "--umi-nonrandom-whitelist"
  umi_fuzzy_window_size:
    label: umi fuzzy window size
    doc: |
      Collapses reads with matching UMIs and alignment positions up to the distance specified.
    type: int?
    inputBinding:
      prefix: "--umi-fuzzy-window-size"
  bin_memory:
    label: bin memory
    doc: |
      bin memory
    type: long?
    inputBinding:
      prefix: "--bin_memory"
  # Variant calling optons
  vc_target_bed:
    label: vc target bed
    doc: |
      This is an optional command line input that restricts processing of the small variant caller,
      target bed related coverage, and callability metrics to regions specified in a BED file.
    type: File?
    inputBinding:
      prefix: "--vc-target-bed"
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
    inputBinding:
      prefix: "--vc-target-bed-padding"
  vc_target_coverage:
    label: vc target coverage
    doc: |
      The --vc-target-coverage option specifies the target coverage for down-sampling.
      The default value is 500 for germline mode and 50 for somatic mode.
    type: int?
    inputBinding:
      prefix: "--vc-target-coverage"
  vc_enable_gatk_acceleration:
    label: vc enable gatk acceleration
    doc: |
      If is set to true, the variant caller runs in GATK mode
      (concordant with GATK 3.7 in germline mode and GATK 4.0 in somatic mode).
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-gatk-acceleration"
      valueFrom: "$(self.toString())"
  vc_remove_all_soft_clips:
    label: vc remove all soft clips
    doc: |
      If is set to true, the variant caller does not use soft clips of reads to determine variants.
    type: boolean?
    inputBinding:
      prefix: "--vc-remove-all-soft-clips"
      valueFrom: "$(self.toString())"
  vc_decoy_contigs:
    label: vc decoy contigs
    doc: |
      The --vc-decoy-contigs option specifies a comma-separated list of contigs to skip during variant calling.
      This option can be set in the configuration file.
    type: string?
    inputBinding:
      prefix: "--vc-decoy-contigs"
  vc_enable_decoy_contigs:
    label: vc enable decoy contigs
    doc: |
      If --vc-enable-decoy-contigs is set to true, variant calls on the decoy contigs are enabled.
      The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-decoy-contigs"
      valueFrom: "$(self.toString())"
  vc_enable_phasing:
    label: vc enable phasing
    doc: |
      The –vc-enable-phasing option enables variants to be phased when possible. The default value is true.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-phasing"
      valueFrom: "$(self.toString())"
  vc_enable_vcf_output:
    label: vc enable vcf output
    doc: |
      The –vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-vcf-output"
      valueFrom: "$(self.toString())"
  # Downsampling options
  vc_max_reads_per_active_region:
    label: vc max reads per active region
    doc: |
      specifies the maximum number of reads covering a given active region.
      Default is 10000 for the somatic workflow
    type: int?
    inputBinding:
      prefix: "--vc-max-reads-per-active-region"
  vc_max_reads_per_raw_region:
    label: vc max reads per raw region
    doc: |
      specifies the maximum number of reads covering a given raw region.
      Default is 30000 for the somatic workflow
    type: int?
    inputBinding:
      prefix: "--vc-max-read-per-raw-region"
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
    inputBinding:
      prefix: "--vc-enable-roh"
      valueFrom: "$(self.toString())"
  vc_roh_blacklist_bed:
    label: vc roh blacklist bed
    doc: |
      If provided, the ROH caller ignores variants that are contained in any region in the blacklist BED file.
      DRAGEN distributes blacklist files for all popular human genomes and automatically selects a blacklist to
      match the genome in use, unless this option is used explicitly select a file.
    type: File?
    inputBinding:
      prefix: "--vc-roh-blacklist-bed"
  # BAF options
  vc_enable_baf:
    label: vc enable baf
    doc: |
      Enable or disable B-allele frequency output. Enabled by default.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-baf"
  # Somatic calling options
  vc_min_tumor_read_qual:
    label: vc min tumor read qual
    type: int?
    doc: |
      The --vc-min-tumor-read-qual option specifies the minimum read quality (MAPQ) to be considered for
      variant calling. The default value is 3 for tumor-normal analysis or 20 for tumor-only analysis.
    inputBinding:
      prefix: --vc-min-tumor-read-qual
  vc_callability_tumor_thresh:
    label: vc callability tumor thresh
    type: int?
    doc: |
      The --vc-callability-tumor-thresh option specifies the callability threshold for tumor samples. The
      somatic callable regions report includes all regions with tumor coverage above the tumor threshold.
    inputBinding:
      prefix: --vc-callability-tumor-thresh
  vc_callability_normal_thresh:
    label: vc callability normal thresh
    type: int?
    doc: |
      The --vc-callability-normal-thresh option specifies the callability threshold for normal samples.
      The somatic callable regions report includes all regions with normal coverage above the normal threshold.
    inputBinding:
      prefix: --vc-callability-normal-thresh
  vc_somatic_hotspots:
    label: vc somatic hotspots
    type: File?
    doc: |
      The somatic hotspots option allows an input VCF to specify the positions where the risk for somatic
      mutations are assumed to be significantly elevated. DRAGEN genotyping priors are boosted for all
      postions specified in the VCF, so it is possible to call a variant at one of these sites with fewer supporting
      reads. The cosmic database in VCF format can be used as one source of prior information to boost
      sensitivity for known somatic mutations.
    inputBinding:
      prefix: --vc-somatic-hotspots
  vc_hotspot_log10_prior_boost:
    label: vc hotspot log10 prior boost
    type: int?
    doc: |
      The size of the hotspot adjustment can be controlled via vc-hotspotlog10-prior-boost,
      which has a default value of 4 (log10 scale) corresponding to an increase of 40 phred.
    inputBinding:
      prefix: --vc-hotspot-log10-prior-boost
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
    inputBinding:
      prefix: --vc-enable-liquid-tumor-mode
      valueFrom: "$(self.toString())"
  vc_tin_contam_tolerance:
    label: vc tin contam tolerance
    type: float?
    doc: |
     --vc-tin-contam-tolerance enables liquid tumor mode and allows you to
      set the maximum contamination TiN tolerance. The maximum contamination TiN tolerance must be
      greater than zero. For example, vc-tin-contam-tolerance=-0.1.
    inputBinding:
      prefix: --vc-tin-contam-tolerance
  # Post somatic calling filtering options
  vc_sq_call_threshold:
    label: vc sq call threshold
    type: float?
    doc: |
      Emits calls in the VCF. The default is 3.
      If the value for vc-sq-filter-threshold is lower than vc-sq-callthreshold,
      the filter threshold value is used instead of the call threshold value
    inputBinding:
      prefix: --vc-sq-call-threshold
  vc_sq_filter_threshold:
    label: vc sq filter threshold
    type: float?
    doc: |
      Marks emitted VCF calls as filtered.
      The default is 17.5 for tumor-normal and 6.5 for tumor-only.
    inputBinding:
      prefix: --vc-sq-filter-threshold
  vc_enable_triallelic_filter:
    label: vc enable triallelic filter
    type: boolean?
    doc: |
      Enables the multiallelic filter. The default is true.
    inputBinding:
      prefix: --vc-enable-triallelic-filter
      valueFrom: "$(self.toString())"
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
    inputBinding:
      prefix: --vc-enable-af-filter
      valueFrom: "$(self.toString())"
  vc_af_call_threshold:
    label: vc af call threshold
    type: float?
    doc: |
      Set the allele frequency call threshold to emit a call in the VCF if the AF filter is enabled.
      The default is 0.01.
    inputBinding:
      prefix: --vc-af-call-threshold
  vc_af_filter_threshold:
    label: vc af filter threshold
    type: float?
    doc: |
      Set the allele frequency filter threshold to mark emitted VCF calls as filtered if the AF filter is
      enabled.
      The default is 0.05.
    inputBinding:
      prefix: --vc-af-filter-threshold
  vc_enable_non_homref_normal_filter:
    label: vc enable non homoref normal filter
    type: boolean?
    doc: |
      Enables the non-homref normal filter. The default value is true. When set to true, the VCF filters out
      variants if the normal sample genotype is not a homozygous reference.
    inputBinding:
      prefix: --vc-enable-non-homref-normal-filter
      valueFrom: "$(self.toString())"
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
    inputBinding:
      prefix: "--dbsnp"
  # cnv pipeline
  enable_cnv:
    label: enable cnv calling
    type: boolean?
    doc: |
      Enable CNV processing in the DRAGEN Host Software.
    inputBinding:
      prefix: --enable-cnv
      valueFrom: "$(self.toString())"
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
    inputBinding:
      prefix: "--lic-instance-id-location"

outputs:
  dragen_umi_output_directory:
    label: dragen UMI analysis output
    doc: Output directory containing all outputs of the dragen UMI run
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory)"

successCodes:
  - 0
