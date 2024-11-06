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

# ID/Docs
id: dragen-germline-pipeline--4.3.6
label: dragen-germline-pipeline v(4.3.6)
doc: |
    Documentation for dragen-germline-pipeline v4.3.6

requirements:
  InlineJavascriptRequirement: {}
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
  # Option 1:
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process.
      Read1File and Read2File may be presigned urls or use this in conjunction with
      the fastq_list_mount_paths inputs.
    type: File?
  # Option 2:
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects
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
  # Option 4
  cram_input:
    label: cram input
    doc: |
      Input a normal CRAM file for the variant calling stage
    type: File?
  cram_reference:
    label: cram reference
    doc: |
      Path to the reference fasta file for the CRAM input.
      Required only if the input is a cram file AND not the reference in the tarball
    type: File?
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File

  # Output naming options
  output_prefix:
    label: output prefix
    doc: |
      The prefix given to all output files
    type: string
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

  # Optional operation modes
  # Given we're running from fastqs
  # --enable-variant-caller option must be set to true (set in arguments), --enable-map-align is then activated by default
  # --enable-map-align-output to keep bams
  # --enable-duplicate-marking to mark duplicate reads at the same time
  # --enable-sv to enable the structural variant calling step.
  enable_map_align:
      label: enable map align
      doc: |
        Enabled by default since --enable-variant-caller option is set to true.
        Set this value to false if using bam_input
      type: boolean?
  enable_map_align_output:
    label: enable map align output
    doc: |
      Do you wish to have the output bam files present
    type: boolean?
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Mark identical alignments as duplicates
    type: boolean?
  dedup_min_qual:
    label: deduplicate minimum quality
    doc: |
      Specifies the Phred quality score below which a base should be excluded from the quality score
      calculation used for choosing among duplicate reads.
    type: int?
  enable_pgx:
    label: enable pgx
    doc: |
      Enable star allele caller. This also turns on other PGx callers such as CYP2D6, CYP2B6
    type: boolean?
  enable_targeted:
    label: enable targeted
    doc: |
      Enable targeted variant calling for repetitive regions
    type: boolean?

  # Structural Variant Caller Options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/StructuralVariantCalling.htm
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
      The -vc-enable-phasing option enables variants to be phased when possible. The default value is true.
    type: boolean?
  vc_enable_vcf_output:
    label: vc enable vcf output
    doc: |
      The -vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.
    type: boolean?
  vc_emit_ref_confidence:
    label: vc emit ref confidence
    doc: |
      A genomic VCF (gVCF) file contains information on variants and positions determined to be homozygous to the reference genome.
      For homozygous regions, the gVCF file includes statistics that indicate how well reads support the absence of variants or
      alternative alleles. To enable gVCF output, set to GVCF. By default, contiguous runs of homozygous reference calls with similar
      scores are collapsed into blocks (hom-ref blocks). Hom-ref blocks save disk space and processing time of downstream analysis tools.
      DRAGEN recommends using the default mode. To produce unbanded output, set --vc-emit-ref-confidence to BP_RESOLUTION.
    type: string?
  vc_ml_enable_recalibration:
    label: vc ml enable recalibration
    doc: |
      DRAGEN employs machine learning-based variant recalibration (DRAGEN-ML) for germline SNV VC.
      Variant calling accuracy is improved using powerful and efficient machine learning techniques that augment the variant caller,
      by exploiting more of the available read and context information that does not easily integrate into the Bayesian processing
      used by the haplotype variant caller.
    type: boolean?

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

  vc_haploid_call_af_threshold:
    label: vc haploid call af threshold
    doc: |
      Option --vc-haploid-call-af-threshold=<af_threshold> to control threshold.
      * Diploid model is applied to haploid (chrX/Y, non-PAR) regions in male samples.
      * Variants with only one alt allele and with AF>=85% are rewritten to haploid calls.
      * The potential mosaic calls with AF<85% will have GT of "0/1" and an INFO tag of
        "MOSAIC" will be added.
    type: float?

  # Downsampling options
  vc_max_reads_per_active_region:
    label: vc max reads per active region
    doc: |
      specifies the maximum number of reads covering a given active region.
      Default is 10000 for the germline workflow
    type: int?
  vc_max_reads_per_raw_region:
    label: vc max reads per raw region
    doc: |
      specifies the maximum number of reads covering a given raw region.
      Default is 30000 for the germline workflow
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

  # Germline variant small hard filtering options
  vc_hard_filter:
    label: vc hard fitler
    doc: |
      DRAGEN provides post-VCF variant filtering based on annotations present in the VCF records.
      However, due to the nature of DRAGEN's algorithms, which incorporate the hypothesis of correlated errors
      from within the core of variant caller, the pipeline has improved capabilities in distinguishing
      the true variants from noise, and therefore the dependency on post-VCF filtering is substantially reduced.
      For this reason, the default post-VCF filtering in DRAGEN is very simple
    type: string?

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

  # Repeat expansion calling
  repeat_genotype_enable:
    label: repeat genotype enable
    doc: |
      Enable DRAGEN repeat expansion detection
    type: boolean?
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

  # cnv pipeline - with this we must also specify one of --cnv-normal-b-allele-vcf,
  # More info at https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/DRAGEN/CNVExamples_fDG_dtREF.htm?Highlight=cnv-normal-b-allele-vcf
  enable_cnv:
    label: enable cnv calling
    doc: |
      Enable CNV processing in the DRAGEN Host Software.
    type: boolean?
  cnv_enable_self_normalization:
    label: cnv enable self normalization
    doc: |
      Enable CNV self normalization.
      Self Normalization requires that the DRAGEN hash table be generated with the enable-cnv=true option.
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

steps:
  # Run dragen germline workflow
  run_dragen_germline_step:
    label: run dragen germline step
    doc: |
      Runs the dragen germline workflow on the FPGA.
      Takes in either a fastq list as a file or a fastq_list_rows schema object
    in:
      fastq_list_rows:
        source: fastq_list_rows
      fastq_list:
        source: fastq_list
      bam_input:
        source: bam_input
      cram_input:
        source: cram_input
      cram_reference:
        source: cram_reference
      reference_tar:
        source: reference_tar
      output_file_prefix:
        source: output_prefix
      output_directory:
        source: output_prefix
        valueFrom: "$(self)_dragen_germline"
      output_format:
        source: output_format
      enable_map_align_output:
        source: enable_map_align_output
      enable_duplicate_marking:
        source: enable_duplicate_marking
      dedup_min_qual:
        source: dedup_min_qual
      enable_pgx:
        source: enable_pgx
      enable_targeted:
        source: enable_targeted
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
      vc_emit_ref_confidence:
        source: vc_emit_ref_confidence
      vc_ml_enable_recalibration:
        source: vc_ml_enable_recalibration
      vc_enable_sex_chr_diploid:
        source: vc_enable_sex_chr_diploid
      vc_haploid_call_af_threshold:
        source: vc_haploid_call_af_threshold
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

      # Structural Variant Caller Options
      enable_sv:
        source: enable_sv
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
      # repeat genotype options
      repeat_genotype_enable:
        source: repeat_genotype_enable
      repeat_genotype_use_catalog:
        source: repeat_genotype_use_catalog
      repeat_genotype_specs:
        source: repeat_genotype_specs
      #cnv options
      enable_cnv:
        source: enable_cnv
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
      lic_instance_id_location:
        source: lic_instance_id_location
    out:
      - id: dragen_germline_output_directory
      - id: dragen_bam_out
      - id: dragen_vcf_out
    run: ../../../tools/dragen-germline/4.3.6/dragen-germline__4.3.6.cwl

  # Run the qc step
  dragen_qc_step:
    label: dragen qc step
    doc: |
      The dragen qc step - this takes in an array of dirs
    in:
      input_directories:
        source: run_dragen_germline_step/dragen_germline_output_directory
        valueFrom: |
          ${
            return [self];
          }
      output_directory_name:
        source: output_prefix
        valueFrom: "$(self)_dragen_germline_multiqc"
      output_filename:
        source: output_prefix
        valueFrom: "$(self)_dragen_germline_multiqc.html"
      title:
        source: output_prefix
        valueFrom: "UMCCR MultiQC Dragen Germline Report for $(self)"
    out:
      - id: output_directory
    run: ../../../tools/multiqc/1.25.1/multiqc__1.25.1.cwl

outputs:
  dragen_germline_output_directory:
    label: dragen germline output directory
    doc: |
      The output directory containing all germline output files
    type: Directory
    outputSource: run_dragen_germline_step/dragen_germline_output_directory
  # provides easier access and reference
  # Only exists if --enable-map-align-output is set to true#
  dragen_bam_out:
    label: dragen bam out
    doc: |
      The output bam file, exists only if --enable-map-align-output is set to true
    type: File?
    secondaryFiles:
      - ".bai"
    outputSource: run_dragen_germline_step/dragen_bam_out
  # Should always be available as an output
  dragen_vcf_out:
    label: dragen vcf out
    doc: |
      The output germline vcf file
    type: File?
    secondaryFiles:
      - ".tbi"
    outputSource: run_dragen_germline_step/dragen_vcf_out
  # The multiqc output directory
  multiqc_output_directory:
    label: multiqc output directory
    doc: |
      The output directory for multiqc
    type: Directory
    outputSource: dragen_qc_step/output_directory
