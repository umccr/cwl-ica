cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: https://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: dragen-germline--4.2.4
label: dragen-germline v(4.2.4)
doc: |
    Documentation for dragen-germline v4.2.4

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: fpga
    ilmn-tes:resources/size: medium
    coresMin: 16
    ramMin: 240000
  DockerRequirement:
      dockerPull: 699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:4.3.6

requirements:
  ResourceRequirement:
    tmpdirMin: |
      ${
        /* 1 Tb */
        return Math.pow(2, 20);
      }
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.0.3/dragen-tools__4.0.3.cwljs
      - $include: ../../../typescript-expressions/utils/1.0.0/utils__1.0.0.cwljs
  InitialWorkDirRequirement:
    listing:
      - entryname: $(get_script_path())
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Run partial reconfig
          /opt/edico/bin/dragen \\
            --partial-reconfig HMM \\
            --ignore-version-check true

          # Create directories
          mkdir --parents \\
            "$(get_ref_mount())" \\
            "$(get_intermediate_results_dir())" \\
            "$(inputs.output_directory)"

          # untar ref data into scratch space
          tar \\
            --directory "$(get_ref_mount())" \\
            --extract \\
            --file "$(inputs.reference_tar.path)"

          # Confirm either of fastq_list, fastq_list_rows, bam_input or cram_input is defined
          if [[ "$(boolean_to_int(is_not_null(inputs.fastq_list)) + boolean_to_int(is_not_null(inputs.fastq_list_rows)) + boolean_to_int(is_not_null(inputs.bam_input)) + boolean_to_int(is_not_null(inputs.cram_input)))" -ne "1" ]]; then
            echo "Please set one and only one of fastq_list, fastq_list_rows and bam_input for normal sample" 1>&2
            exit 1
          fi

          # Run dragen command and import options from cli
          "$(get_dragen_bin_path())" "\${@}"
      - |
        ${
          return generate_germline_mount_points(inputs);
        }

          # DRAGEN Multi-region Joint Detection (MRJD) is a de novo germline small variant caller for paralogous regions.
          # MRJD is compatible with the hg38, hg19 and GRCh37 reference genomes.
          # https://help.dragen.illumina.com/product-guides/dragen-v4.3/dragen-dna-pipeline/small-variant-calling/multi-region-joint-detection
          #
          # Multi Region Joint Detection (MRJD) Caller should be runs as standalone pipeline on DRAGEN™ server (not in integrated with Germline Small VC)
          # https://support.illumina.com/content/dam/illumina-support/documents/downloads/software/dragen/release-notes/200056923_00_DRAGEN_4_3_6_Customer-Release-Notes.pdf
          if [[ "$(is_not_null(inputs.bam_input))" == "true" && \
              ( "$(get_bool_value_as_str(inputs.enable_mrjd))" == "true" || \
                "$(get_bool_value_as_str(inputs.mrjd_enable_high_sensitivity_mode))" == "true" ) ]]; then 
            echo "optionally run MRJD if relevant parameter is enabled" 1>&2
            eval /opt/edico/bin/dragen \\
                "--ref-dir=$(get_ref_path(inputs.reference_tar))" \\
                "--bam-input=$(get_ref_path(inputs.bam_input))" \\
                --enable-map-align=false \\
                --enable-mrjd=true \\
                --mrjd-enable-high-sensitivity-mode=true \\
                "--output-directory=$(inputs.output_directory)" \\
                "--output-file-prefix=$(inputs.output_file_prefix)"
          fi

baseCommand: [ "bash" ]

arguments:
  # Script path
  - valueFrom: "$(get_script_path())"
    position: -1
  # Parameters that are always true
  - prefix: "--enable-variant-caller="
    separate: False
    valueFrom: "true"
  - prefix: "--intermediate-results-dir="
    separate: False
    valueFrom: "$(get_intermediate_results_dir())"


inputs:
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/OptionReference.htm
  # Inputs fastq list csv or actual fastq list file with presigned urls for Read1File and Read2File columns
  # File inputs
  # Option 1:
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process.
      Read1File and Read2File may be presigned urls or use this in conjunction with
      the fastq_list_mount_paths inputs.
    type: File?
    inputBinding:
      loadContents: true
      prefix: "--fastq-list="
      separate: False
      valueFrom: "$(get_fastq_list_csv_path())"
  # Option 2:
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
    inputBinding:
      prefix: "--fastq-list="
      separate: False
      valueFrom: "$(get_fastq_list_csv_path())"
  # Option 3
  bam_input:
    label: bam input
    doc: |
      Input a normal BAM file for the variant calling stage
    type: File?
    inputBinding:
      prefix: "--bam-input="
      separate: False
    secondaryFiles:
      - pattern: ".bai"
        required: true
  # Option 4
  cram_input:
    label: cram input
    doc: |
      Input a normal CRAM file for the variant calling stage
    type: File?
    inputBinding:
      prefix: "--cram-input="
      separate: False
    secondaryFiles:
      - pattern: ".crai"
        required: true
  cram_reference:
    label: cram reference
    doc: |
      Path to the reference fasta file for the CRAM input.
      Required only if the input is a cram file AND not the reference in the tarball
    type: File?
    inputBinding:
      prefix: "--cram-reference="
      separate: False
    secondaryFiles:
      - pattern: ".fai"
        required: true
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
    inputBinding:
      prefix: "--ref-dir="
      separate: False
      valueFrom: "$(get_ref_path(self))"
  # Output naming options
  output_file_prefix:
    label: output file prefix
    doc: |
      The prefix given to all output files
    type: string
    inputBinding:
      prefix: "--output-file-prefix="
      separate: False
  output_directory:
    label: output directory
    doc: |
      The directory where all output files are placed
    type: string
    inputBinding:
      prefix: "--output-directory="
      separate: False
  output_format :
    label: output format
    doc: |
      For mapping and aligning, the output is sorted and compressed into BAM format by default before saving to disk.
      You can control the output format from the map/align stage with the --output-format <SAM|BAM|CRAM> option.
    type:
      - "null"
      - type: enum
        symbols:
          - SAM
          - BAM
          - CRAM
    inputBinding:
      prefix: "--output-format="
      separate: False

  # Optional operation modes
  # Given we're running from fastqs
  # --enable-variant-caller option must be set to true (set in arguments), --enable-map-align is then activated by default
  # --enable-map-align-output to keep bams
  # --enable-duplicate-marking to mark duplicate reads at the same time
  # --enable-sv to enable the structural variant calling step.
  enable_sort:
    label: enable sort
    doc: |
      True by default, only set this to false if using --bam-input parameter
    type: boolean?
    inputBinding:
      prefix: "--enable-sort="
      separate: False
      valueFrom: "$(self.toString())"
  enable_map_align:
    label: enable map align
    doc: |
      Enabled by default since --enable-variant-caller option is set to true.
      Set this value to false if using bam_input
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align="
      separate: False
      valueFrom: "$(self.toString())"
  enable_map_align_output:
    label: enable map align output
    doc: |
      Do you wish to have the output bam files present
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align-output="
      separate: False
      valueFrom: "$(self.toString())"
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Mark identical alignments as duplicates
    type: boolean?
    inputBinding:
      prefix: "--enable-duplicate-marking="
      separate: False
      valueFrom: "$(self.toString())"
  dedup_min_qual:
    label: deduplicate minimum quality
    doc: |
      Specifies the Phred quality score below which a base should be excluded from the quality score
      calculation used for choosing among duplicate reads.
    type: int?
    inputBinding:
      prefix: "--dedup-min-qual="
      separate: False
      valueFrom: "$(self.toString())"
  enable_pgx:
    label: enable pgx
    doc: |
      Enable star allele caller. This also turns on other PGx callers such as CYP2D6, CYP2B6
    type: boolean?
    inputBinding:
      prefix: "--enable-pgx="
      separate: False
      valueFrom: "$(self.toString())"
  enable_targeted:
    label: enable targeted
    doc: |
      Enable targeted variant calling for repetitive regions
    type: boolean?
    inputBinding:
      prefix: "--enable-targeted="
      separate: False
      valueFrom: "$(self.toString())"

  # Structural Variant Caller Options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/StructuralVariantCalling.htm
  enable_sv:
    label: enable sv
    doc: |
      Enable/disable structural variant
      caller. Default is false.
    type: boolean?
    inputBinding:
      prefix: "--enable-sv="
      separate: False
      valueFrom: "$(self.toString())"
  # Structural Variant Caller Options
  sv_call_regions_bed:
    label: sv call regions bed
    doc: |
      Specifies a BED file containing the set of regions to call.
    type: File?
    inputBinding:
      prefix: "--sv-call-regions-bed="
      separate: False
  sv_region:
    label: sv region
    doc: |
      Limit the analysis to a specified region of the genome for debugging purposes.
      This option can be specified multiple times to build a list of regions.
      The value must be in the format "chr:startPos-endPos"..
    type: string?
    inputBinding:
      prefix: "--sv-region="
      separate: False
      valueFrom: "$(self.toString())"
  sv_exome:
    label: sv exome
    doc: |
      Set to true to configure the variant caller for targeted sequencing inputs,
      which includes disabling high depth filters.
      In integrated mode, the default is to autodetect targeted sequencing input,
      and in standalone mode the default is false.
    type: boolean?
    inputBinding:
      prefix: "--sv-exome="
      separate: False
      valueFrom: "$(self.toString())"
  sv_output_contigs:
    label: sv output contigs
    doc: |
      Set to true to have assembled contig sequences output in a VCF file. The default is false.
    type: boolean?
    inputBinding:
      prefix: "--sv-output-contigs="
      separate: False
      valueFrom: "$(self.toString())"
  sv_forcegt_vcf:
    label: sv forcegt vcf
    doc: |
      Specify a VCF of structural variants for forced genotyping. The variants are scored and emitted
      in the output VCF even if not found in the sample data.
      The variants are merged with any additional variants discovered directly from the sample data.
    type: File?
    inputBinding:
      prefix: "--sv-forcegt-vcf="
      separate: False
  sv_discovery:
    label: sv discovery
    doc: |
      Enable SV discovery. This flag can be set to false only when --sv-forcegt-vcf is used.
      When set to false, SV discovery is disabled and only the forced genotyping input variants
      are processed. The default is true.
    type: boolean?
    inputBinding:
      prefix: "--sv-discovery="
      separate: False
      valueFrom: "$(self.toString())"
  sv_se_overlap_pair_evidence:
    label: sv use overlap pair evidence
    doc: |
      Allow overlapping read pairs to be considered as evidence.
      By default, DRAGEN uses autodetect on the fraction of overlapping read pairs if <20%.
    type: boolean?
    inputBinding:
      prefix: "--sv-use-overlap-pair-evidence="
      separate: False
      valueFrom: "$(self.toString())"
  sv_enable_liquid_tumor_mode:
    label: sv enable liquid tumor mode
    doc: |
      Enable liquid tumor mode.
    type: boolean?
    inputBinding:
      prefix: "--sv-enable-liquid-tumor-mode="
      separate: False
      valueFrom: "$(self.toString())"
  sv_tin_contam_tolerance:
    label: sv tin contam tolerance
    doc: |
      Set the Tumor-in-Normal (TiN) contamination tolerance level.
      You can enter any value between 0-1. The default maximum TiN contamination tolerance is 0.15.
    type: float?
    inputBinding:
      prefix: "--sv-tin-contam-tolerance="
      separate: False

  # Variant calling options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/SmallVariantCaller.htm
  vc_target_bed:
    label: vc target bed
    doc: |
      This is an optional command line input that restricts processing of the small variant caller,
      target bed related coverage, and callability metrics to regions specified in a BED file.
    type: File?
    inputBinding:
      prefix: "--vc-target-bed="
      separate: False
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
      prefix: "--vc-target-bed-padding="
      separate: False
  vc_target_coverage:
    label: vc target coverage
    doc: |
      The --vc-target-coverage option specifies the target coverage for down-sampling.
      The default value is 500 for germline mode and 50 for somatic mode.
    type: int?
    inputBinding:
      prefix: "--vc-target-coverage="
      separate: False
  vc_enable_gatk_acceleration:
    label: vc enable gatk acceleration
    doc: |
      If is set to true, the variant caller runs in GATK mode
      (concordant with GATK 3.7 in germline mode and GATK 4.0 in somatic mode).
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-gatk-acceleration="
      separate: False
      valueFrom: "$(self.toString())"
  vc_remove_all_soft_clips:
    label: vc remove all soft clips
    doc: |
      If is set to true, the variant caller does not use soft clips of reads to determine variants.
    type: boolean?
    inputBinding:
      prefix: "--vc-remove-all-soft-clips="
      separate: False
      valueFrom: "$(self.toString())"
  vc_decoy_contigs:
    label: vc decoy contigs
    doc: |
      The --vc-decoy-contigs option specifies a comma-separated list of contigs to skip during variant calling.
      This option can be set in the configuration file.
    type: string?
    inputBinding:
      prefix: "--vc-decoy-contigs="
      separate: False
  vc_enable_decoy_contigs:
    label: vc enable decoy contigs
    doc: |
      If --vc-enable-decoy-contigs is set to true, variant calls on the decoy contigs are enabled.
      The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-decoy-contigs="
      separate: False
      valueFrom: "$(self.toString())"
  vc_enable_phasing:
    label: vc enable phasing
    doc: |
      The -vc-enable-phasing option enables variants to be phased when possible. The default value is true.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-phasing="
      separate: False
      valueFrom: "$(self.toString())"
  vc_enable_vcf_output:
    label: vc enable vcf output
    doc: |
      The -vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-vcf-output="
      separate: False
      valueFrom: "$(self.toString())"
  vc_emit_ref_confidence:
    label: vc emit ref confidence
    doc: |
      A genomic VCF (gVCF) file contains information on variants and positions determined to be homozygous to the reference genome.
      For homozygous regions, the gVCF file includes statistics that indicate how well reads support the absence of variants or
      alternative alleles. To enable gVCF output, set to GVCF. By default, contiguous runs of homozygous reference calls with similar
      scores are collapsed into blocks (hom-ref blocks). Hom-ref blocks save disk space and processing time of downstream analysis tools.
      DRAGEN recommends using the default mode. To produce unbanded output, set --vc-emit-ref-confidence to BP_RESOLUTION.
    type: string?
    inputBinding:
      prefix: "--vc-emit-ref-confidence="
      separate: False
  vc_ml_enable_recalibration:
    label: vc ml enable recalibration
    doc: |
      DRAGEN employs machine learning-based variant recalibration (DRAGEN-ML) for germline SNV VC.
      Variant calling accuracy is improved using powerful and efficient machine learning techniques that augment the variant caller,
      by exploiting more of the available read and context information that does not easily integrate into the Bayesian processing
      used by the haplotype variant caller.
    type: boolean?
    inputBinding:
      prefix: "--vc-ml-enable-recalibration="
      separate: False
      valueFrom: "$(self.toString())"

  # Sex chromosome mosaic variants options
  vc_enable_sex_chr_diploid:
    label: vc enable sex chr diploid
    doc: |
      For male samples in germline calling mode, DRAGEN calls potential mosaic variants in non-PAR regions of sex chromosomes.
      A variant is called as mosaic when the allele frequency (FORMAT/AF) is below 85% or if multiple alt alleles are called,
      suggesting incompatibility with the haploid assumption. The GT field for bi-allelic mosaic variants is "0/1",
      denoting a mixture of reference and alt alleles, as opposed to the regular GT of "1" for haploid variants.
      The GT field for multi-allelic mosaic variants is "1/2" in VCF.
      You can disable the calling of mosaic variants by setting --vc-enable-sex-chr-diploid to false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-sex-chr-diploid="
      separate: False
      valueFrom: "$(self.toString())"
  vc_haploid_call_af_threshold:
    label: vc haploid call af threshold
    doc: |
      Option --vc-haploid-call-af-threshold=<af_threshold> to control threshold.
      * Diploid model is applied to haploid (chrX/Y, non-PAR) regions in male samples.
      * Variants with only one alt allele and with AF>=85% are rewritten to haploid calls.
      * The potential mosaic calls with AF<85% will have GT of "0/1" and an INFO tag of
        "MOSAIC" will be added.
    type: float?
    inputBinding:
      prefix: "--vc-haploid-call-af-threshold="
      separate: False

  # Downsampling options
  vc_max_reads_per_active_region:
    label: vc max reads per active region
    doc: |
      specifies the maximum number of reads covering a given active region.
      Default is 10000 for the germline workflow
    type: int?
    inputBinding:
      prefix: "--vc-max-reads-per-active-region="
      separate: False
  vc_max_reads_per_raw_region:
    label: vc max reads per raw region
    doc: |
      specifies the maximum number of reads covering a given raw region.
      Default is 30000 for the germline workflow
    type: int?
    inputBinding:
      prefix: "--vc-max-read-per-raw-region="
      separate: False

  # Ploidy support
  sample_sex:
    label: sample sex
    doc: |
      Specifies the sex of a sample
    type:
      - "null"
      - type: enum
        symbols:
          - none
          - auto
          - male
          - female
    inputBinding:
      prefix: "--sample-sex="
      separate: False
  # ROH options
  vc_enable_roh:
    label: vc enable roh
    doc: |
      Enable or disable the ROH caller by setting this option to true or false. Enabled by default for human autosomes only.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-roh="
      separate: False
      valueFrom: "$(self.toString())"
  vc_roh_blacklist_bed:
    label: vc roh blacklist bed
    doc: |
      If provided, the ROH caller ignores variants that are contained in any region in the blacklist BED file.
      DRAGEN distributes blacklist files for all popular human genomes and automatically selects a blacklist to
      match the genome in use, unless this option is used explicitly select a file.
    type: File?
    inputBinding:
      prefix: "--vc-roh-blacklist-bed="
      separate: False

  # BAF options
  vc_enable_baf:
    label: vc enable baf
    doc: |
      Enable or disable B-allele frequency output. Enabled by default.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-baf="
      separate: False
      valueFrom: "$(self.toString())"

  # Germline variant small hard filtering options
  vc_hard_filter:
    label: vc hard filter
    doc: |
      DRAGEN provides post-VCF variant filtering based on annotations present in the VCF records.
      However, due to the nature of DRAGEN's algorithms, which incorporate the hypothesis of correlated errors
      from within the core of variant caller, the pipeline has improved capabilities in distinguishing
      the true variants from noise, and therefore the dependency on post-VCF filtering is substantially reduced.
      For this reason, the default post-VCF filtering in DRAGEN is very simple
    type: string?
    inputBinding:
      prefix: "--vc-hard-filter="
      separate: False
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
      prefix: "--dbsnp="
      separate: False

  # Repeat expansion calling
  repeat_genotype_enable:
    label: repeat genotype enable
    doc: |
      Enable DRAGEN repeat expansion detection
    type: boolean?
    inputBinding:
      prefix: "--repeat-genotype-enable="
      separate: False
      valueFrom: "$(self.toString())"
  repeat_genotype_use_catalog:
    label: repeat genotype use catalog
    doc: |
      The repeat-specification (also called variant catalog) JSON file defines the repeat regions for ExpansionHunter to analyze.
      Default repeat-specification for some pathogenic and polymorphic repeats are in the /opt/edico/repeat-specs/ directory,
      based on the reference genome used with DRAGEN. Users can choose between any of the three default repeat-specification files
      packaged with DRAGEN using <default|default_plus_smn|expanded>
    type:
      - "null"
      - type: enum
        symbols:
        - default
        - default_plus_smn
        - expanded
    inputBinding:
      prefix: "--repeat-genotype-use-catalog="
      separate: False
  repeat_genotype_specs:
    label: repeat genotype specs
    doc: |
      Specifies the full path to the JSON file that contains the repeat variant catalog (specification) describing the loci to call.
      --repeat-genotype-specs is required for ExpansionHunter.
      If the option is not provided,
      DRAGEN attempts to autodetect the applicable catalog file from /opt/edico/repeat-specs/ based on the reference provided.
    type:
      - "null"
      - File
      - string
    inputBinding:
      prefix: "--repeat-genotype-specs="
      separate: False
  # Force genotyping
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
    inputBinding:
      prefix: "--vc-forcegt-vcf="
      separate: False

  # cnv pipeline - with this we must also specify one of --cnv-normal-b-allele-vcf,
  # More info at https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/DRAGEN/CNVExamples_fDG_dtREF.htm?Highlight=cnv-normal-b-allele-vcf
  enable_cnv:
    label: enable cnv calling
    doc: |
      Enable CNV processing in the DRAGEN Host Software.
    type: boolean?
    inputBinding:
      prefix: "--enable-cnv="
      separate: False
      valueFrom: "$(self.toString())"
  cnv_enable_self_normalization:
    label: cnv enable self normalization
    doc: |
      Enable CNV self normalization.
      Self Normalization requires that the DRAGEN hash table be generated with the enable-cnv=true option.
    type: boolean?
    inputBinding:
      prefix: "--cnv-enable-self-normalization="
      separate: False
      valueFrom: "$(self.toString())"

  # QC options
  qc_coverage_region_1:
    label: qc coverage region 1
    doc: |
      Generates coverage region report using bed file 1.
    type: File?
    inputBinding:
      prefix: "--qc-coverage-region-1="
      separate: False
  qc_coverage_region_2:
    label: qc coverage region 2
    doc: |
      Generates coverage region report using bed file 2.
    type: File?
    inputBinding:
      prefix: "--qc-coverage-region-2="
      separate: False
  qc_coverage_region_3:
    label: qc coverage region 3
    doc: |
      Generates coverage region report using bed file 3.
    type: File?
    inputBinding:
      prefix: "--qc-coverage-region-3="
      separate: False
  qc_coverage_ignore_overlaps:
    label: qc coverage ignore overlaps
    doc: |
      Set to true to resolve all of the alignments for each fragment and avoid double-counting any
      overlapping bases. This might result in marginally longer run times.
      This option also requires setting --enable-map-align=true.
    type: boolean?
    inputBinding:
      prefix: "--qc-coverage-ignore-overlaps="
      separate: False
      valueFrom: "$(self.toString())"

  # HLA calling
  enable_hla:
    label: enable hla
    doc: |
      Enable HLA typing for class I genes by setting --enable-hla flag to true
    type: boolean?
    inputBinding:
      prefix: "--enable-hla="
      separate: False
      valueFrom: "$(self.toString())"
  hla_enable_class_2:
    label: hla enable class 2
    doc: |
      Enable HLA typing for class II genes by setting --hla-enable-class-2 flag to true
    type: boolean?
    inputBinding:
      prefix: "--hla-enable-class-2="
      separate: False
      valueFrom: "$(self.toString())"
  hla_bed_file:
    label: hla bed file
    doc: |
      Use the HLA region BED input file to specify the region to extract HLA reads from.
      DRAGEN HLA Caller parses the input file for regions within the BED file, and then
      extracts reads accordingly to align with the HLA allele reference.
    type: File?
    inputBinding:
      prefix: "--hla-bed-file="
      separate: False
  hla_reference_file:
    label: hla reference file
    doc: |
      Use the HLA allele reference file to specify the reference alleles to align against.
      The input HLA reference file must be in FASTA format and contain the protein sequence separated into exons.
      If --hla-reference-file is not specified, DRAGEN uses hla_classI_ref_freq.fasta from /opt/edico/config/.
      The reference HLA sequences are obtained from the IMGT/HLA database.
    type: File?
    inputBinding:
      prefix: "--hla-reference-file="
      separate: False
  hla_allele_frequency_file:
    label: hla allele frequency file
    doc: |
      Use the population-level HLA allele frequency file to break ties if one or more HLA allele produces the same or similar results.
      The input HLA allele frequency file must be in CSV format and contain the HLA alleles and the occurrence frequency in population.
      If --hla-allele-frequency-file is not specified, DRAGEN automatically uses hla_classI_allele_frequency.csv from /opt/edico/config/.
      Population-level allele frequencies can be obtained from the Allele Frequency Net database.
    type: File?
    inputBinding:
      prefix: "--hla-allele-frequency-file="
      separate: False
  hla_tiebreaker_threshold:
    label: hla tiebreaker threshold
    doc: |
      If more than one allele has a similar number of reads aligned and there is not a clear indicator for the best allele,
      the alleles are considered as ties. The HLA Caller places the tied alleles into a candidate set for tie breaking based
      on the population allele frequency. If an allele has more than the specified fraction of reads aligned (normalized to
      the top hit), then the allele is included into the candidate set for tie breaking. The default value is 0.97.
    type: float?
    inputBinding:
      prefix: "--hla-tiebreaker-threshold="
      separate: False
  hla_zygosity_threshold:
    label: hla zygosity threshold
    doc: |
      If the minor allele at a given locus has fewer reads mapped than a fraction of the read count of the major allele,
      then the HLA Caller infers homozygosity for the given HLA-I gene. You can use this option to specify the fraction value.
      The default value is 0.15.
    type: float?
    inputBinding:
      prefix: "--hla zygosity threshold="
      separate: False
  hla_min_reads:
    label: hla min reads
    doc: |
      Set the minimum number of reads to align to HLA alleles to ensure sufficient coverage and perform HLA typing.
      The default value is 1000 and suggested for WES samples. If using samples with less coverage, you can use a
      lower threshold value.
    type: int?
    inputBinding:
      prefix: "--hla-min-reads="
      separate: False

  # Multi-Region Joint Detection
  enable_mrjd:
    label: enable multi-region joint detection
    doc: |
      In DRAGEN v4.3, MRJD covers regions that include six clinically relevant genes: NEB, TTN, SMN1/2, PMS2, STRC, and IKBKG.
      With this option enabled, the following two types of variants are reported: 1. Uniquely placed variants; 2. Region-ambiguous variants.
    type: boolean?
  mrjd_enable_high_sensitivity_mode:
    label: enable multi-region joint detection high sensitivity mode 
    doc: |
      In addition to 1. Uniquely placed variants and 2. Region-ambiguous variants, with this option enabled, 
      the following two types of variants are reported: 3. Positions where the reference alleles in all paralogous regions are not the same; 
      4. Variants that have been placed uniquely in one of the paralogous regions and no variant in the corresponding position in the other region
    type: boolean?

  # Miscellaneous options
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
      prefix: "--lic-instance-id-location="
      separate: False

outputs:
  # Will also include mounted-files.txt
  dragen_germline_output_directory:
    label: dragen germline output directory
    doc: |
      The output directory containing all germline output files
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory)"
  # Optional files to be used in downstream workflows.
  # Whilst these files reside inside the germline directory, specifying them here as outputs
  # provides easier access and reference
  # Only exists if --enable-map-align-output is set to true#
  dragen_bam_out:
    label: dragen bam out
    doc: |
      The output bam file, exists only if --enable-map-align-output is set to true
    type: File?
    outputBinding:
      glob: "$(inputs.output_directory)/$(inputs.output_file_prefix).bam"
    secondaryFiles:
      - ".bai"
  # Should always be available as an output
  dragen_vcf_out:
    label: dragen vcf out
    doc: |
      The output germline vcf file
    type: File?
    outputBinding:
      glob: "$(inputs.output_directory)/$(inputs.output_file_prefix).vcf.gz"
    secondaryFiles:
      - ".tbi"


successCodes:
  - 0
