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
id: dragen-alignment-pipeline--3.9.3
label: dragen-alignment-pipeline v(3.9.3)
doc: |
    Documentation for dragen-alignment-pipeline v3.9.3

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml

inputs:
  # File input logic
  # Option 1
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
  # Option 2
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files for normal sample
      to process (read_1 and read_2 attributes must be presigned urls for each column)
    type: File?
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
  # Output naming options
  output_file_prefix:
    label: output file prefix
    doc: |
      The prefix given to all output files
    type: string
  output_directory:
    label: output directory
    doc: |
      The directory where all output files are placed
    type: string
  ### Start mapper options ###
  ann_sj_max_indel:
    label: ann sj max indel
    doc: |
      Maximum indel length to expect near an annotated splice junction.
      Range: 0 - 63
    type: int?
  edit_chain_limit:
    label: edit chain limit
    doc: |
      For edit-mode 1 or 2: Maximum seed chain length in a read to qualify for seed editing.
      Range: > 0
    type: int?
  edit_mode:
    label: edit mode
    doc: |
      0 = No edits, 1 = Chain len test, 2 = Paired chain len test, 3 = Edit all std seeds.
    type:
      - "null"
      - type: enum
        symbols:
          - "0"
          - "1"
          - "2"
          - "3"
  edit_read_len:
    label: edit read len
    doc: |
      For edit-mode 1 or 2: Read length in which to try edit-seed-num edited seeds.
      Range: > 0
    type: int?
  edit_seed_num:
    label: edit seed num
    doc: |
      For edit-mode 1 or 2: Requested number of seeds per read to allow editing on.
      Range: > 0
    type: int?
  enable_map_align_output:
    label: enable map align output
    doc: |
      Enable use of BAM input files for mapper/aligner.
    type: boolean
  max_intron_bases:
    label: max intron bases
    doc: |
      Maximum intron length reported.
    type: int?
  min_intron_bases:
    label: min intron bases
    doc: |
      Minimum reference deletion length reported as an intron.
    type: int?
  seed_density:
    label: seed density
    doc: |
      Requested density of seeds from reads queried in the hash table
      Range: 0 - 1
    type: float?
  ### End mapper options
  ### Start Alignment options ###
  aln_min_score:
    label: aln min score
    doc: |
      (signed) Minimum alignment score to report; baseline for MAPQ.

      When using local alignments (global = 0), aln-min-score is computed by the host software as "22 * match-score".

      When using global alignments (global = 1), aln-min-score is set to -1000000.

      Host software computation may be overridden by setting aln-min-score in configuration file.

      Range: −2,147,483,648 to 2,147,483,647
    type: int?
  dedup_min_qual:
    label: dedup min qual
    doc: |
      Minimum base quality for calculating read quality metric for deduplication.
      Range: 0-63
    type: int?
  en_alt_hap_aln:
    label: en alt hap aln
    doc: |
      Allows chimeric alignments to be output, as supplementary.
    type: boolean?
  en_chimeric_aln:
    label: en chimeric aln
    doc: |
      Allows chimeric alignments to be output, as supplementary.
    type: boolean?
  gap_ext_pen:
    label: gap ext pen
    doc: |
      Score penalty for gap extension.
    type: int?
  gap_open_pen:
    label: gap open pen
    doc: |
      Score penalty for opening a gap (insertion or deletion).
    type: int?
  global:
    label: global
    doc: |
      If alignment is global (Needleman-Wunsch) rather than local (Smith-Waterman).
    type: boolean?
  hard_clips:
    label: hard clips
    doc: |
      Flags for hard clipping: [0] primary, [1] supplementary, [2] secondary.
      The hard-clips option is used as a field of 3 bits, with values ranging from 0 to 7.
      The bits specify alignments, as follows:
        * Bit 0—primary alignments
        * Bit 1—supplementary alignments
        * Bit 2—secondary alignments
      Each bit determines whether local alignments of that type are reported with hard clipping (1)
      or soft clipping (0).
      The default is 6, meaning primary alignments use soft clipping and supplementary and
      secondary alignments use hard clipping.
    type: int?
  map_orientations:
    label: map orientations
    doc: |
      Constrain orientations to accept forward-only, reverse-complement only, or any alignments.
    type:
      - "null"
      - type: enum
        symbols:
          - "0"  # (any)
          - "1"  # (forward only)
          - "2"  # (reverse only)
  mapq_max:
    label: mapq max
    doc: |
      Ceiling on reported MAPQ. Max 255
    type: int?
  mapq_strict_js:
    label: mapq strict js
    doc: |
      Specific to RNA. When set to 0, a higher MAPQ value is returned, expressing confidence that the alignment is at least partially correct. When set to 1, a lower MAPQ value is returned, expressing the splice junction ambiguity.
    type: boolean?
  match_n_score:
    label: match n score
    doc: |
      (signed) Score increment for matching a reference 'N' nucleotide IUB code.
      Range: -16 to 15
    type: int?
  match_score:
    label: match score
    doc: |
      Score increment for matching reference nucleotide.
      When global = 0, match-score > 0; When global = 1, match-score >= 0
    type: float?
  max_rescues:
    label: max rescues
    doc: |
      Maximum rescue alignments per read pair. Default is 10
    type: int?
  min_score_coeff:
    label: min score coeff
    doc: |
      Adjustment to aln-min-score per read base.
      Range: -64 to 63.999
    type: float?
  mismatch_pen:
    label: mismatch pen
    doc: |
      Score penalty for a mismatch.
    type: int?
  no_unclip_score:
    label: no unclip score
    doc: |
      When no-unclip-score is set to 1, any unclipped bonus (unclip-score) contributing to an alignment is removed from the alignment score before further processing.
    type: boolean?
  no_unpaired:
    label: no unpaired
    doc: |
      If only properly paired alignments should be reported for paired reads.
    type: boolean?
  pe_max_penalty:
    label: pe max penalty
    doc: |
      Maximum pairing score penalty, for unpaired or distant ends.
      Range: 0-255
    type: int?
  pe_orientation:
    label: pe orientation
    doc: |
      Expected paired-end orientation: 0=FR, 1=RF, 2=FF.
    type:
      - "null"
      - type: enum
        symbols:
          - "0"  # FR
          - "1"  # RF
          - "2"  # FF
  rescue_sigmas:
    label: rescue sigmas
    doc: |
      Deviations from the mean read length used for rescue scan radius. Default is 2.5.
    type: float?
  sec_aligns:
    label: sec aligns
    doc: |
      Maximum secondary (suboptimal) alignments to report per read.
      Range: 0 - 30
    type: int?
  sec_aligns_hard:
    label: sec aligns hard
    doc: |
      Set to force unmapped when not all secondary alignments can be output.
    type: boolean?
  sec_phred_delta:
    label: sec phred delta
    doc: |
      Only secondary alignments with likelihood within this Phred of the primary are reported.
      Range: 0 - 255
    type: int?
  sec_score_delta:
    label: sec score delta
    doc: |
      Secondary aligns allowed with pair score no more than this far below primary.
    type: float?
  supp_aligns:
    label: supp aligns
    doc: |
      Maximum supplementary (chimeric) alignments to report per read.
    type: int?
  supp_as_sec:
    label: supp as sec
    doc: |
      If supplementary alignments should be reported with secondary flag.
    type: boolean?
  supp_min_score_adj:
    label: supp min score adj
    doc: |
      Amount to increase minimum alignment score for supplementary alignments.
      This score is computed by host software as "8 * match-score" for DNA, and is default 0 for RNA.
    type: float?
  unclip_score:
    label: unclip score
    doc: |
      Score bonus for reaching each edge of the read.
      Range: 0 - 127
    type: int?
  unpaired_pen:
    label: unpaired pen
    doc: |
      Penalty for unpaired alignments in Phred scale.
      Range: 0 - 255
    type: int?
  ### End Alignment options ###
  ### Start General software options
  # Alt aware mapping
  alt_aware:
    label: alt aware
    doc: |
      Enables special processing for alt contigs, if alt liftover was used in hash table.
      Enabled by default if reference was built with liftover.
    type: boolean?
  # Duplicate marking
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Enable the flagging of duplicate output alignment records.
    type: boolean
  remove_duplicates:
    label: remove duplicates
    doc: |
      If true, remove duplicate alignment records instead of just flagging them.
    type: boolean?
  # Tag generation
  generate_md_tags:
    label: generate md tags
    doc: |
      Whether to generate MD tags with alignment output records. Default is false.
    type: boolean?
  generate_sa_tags:
    label: generate sa tags
    doc: |
      Whether to generate SA:Z tags for records that have chimeric/supplemental alignments.
    type: boolean?
  generate_zs_tags:
    label: generate zs tags
    doc: |
      Whether to generate ZS tags for alignment output records. Default is false.
    type: boolean?
  # Sorting logic
  enable_sort:
    label: enable sort
    doc: |
      Enable sorting after mapping/alignment.
    type: boolean
  preserve_map_align_order:
    label: preserve map align order
    doc: |
      Produce output file that preserves original order of reads in the input file.
    type: boolean?
  # Verbosity
  verbose:
    label: verbose
    doc: |
      Enable verbose output from DRAGEN.
    type: boolean?


steps:
  # Run Dragen
  run_dragen_alignment_step:
    label: run dragen alignment step
    doc: |
      Runs the alignment step on a dragen fpga
      Takes in a fastq list and corresponding mount paths from the predefined mount paths
      All other options available at the top of the workflow
    in:
      fastq_list:
        source: fastq_list
      fastq_list_rows:
        source: fastq_list_rows
      reference_tar:
        source: reference_tar
      output_file_prefix:
        source: output_file_prefix
      output_directory:
        source: output_directory
      ann_sj_max_indel:
        source: ann_sj_max_indel
      edit_chain_limit:
        source: edit_chain_limit
      edit_mode:
        source: edit_mode
      edit_read_len:
        source: edit_read_len
      edit_seed_num:
        source: edit_seed_num
      enable_map_align_output:
        source: enable_map_align_output
      max_intron_bases:
        source: max_intron_bases
      min_intron_bases:
        source: min_intron_bases
      seed_density:
        source: seed_density
      aln_min_score:
        source: aln_min_score
      dedup_min_qual:
        source: dedup_min_qual
      en_alt_hap_aln:
        source: en_alt_hap_aln
      en_chimeric_aln:
        source: en_chimeric_aln
      gap_ext_pen:
        source: gap_ext_pen
      gap_open_pen:
        source: gap_open_pen
      global:
        source: global
      hard_clips:
        source: hard_clips
      map_orientations:
        source: map_orientations
      mapq_max:
        source: mapq_max
      mapq_strict_js:
        source: mapq_strict_js
      match_n_score:
        source: match_n_score
      match_score:
        source: match_score
      max_rescues:
        source: max_rescues
      min_score_coeff:
        source: min_score_coeff
      mismatch_pen:
        source: mismatch_pen
      no_unclip_score:
        source: no_unclip_score
      no_unpaired:
        source: no_unpaired
      pe_max_penalty:
        source: pe_max_penalty
      pe_orientation:
        source: pe_orientation
      rescue_sigmas:
        source: rescue_sigmas
      sec_aligns:
        source: sec_aligns
      sec_aligns_hard:
        source: sec_aligns_hard
      sec_phred_delta:
        source: sec_phred_delta
      sec_score_delta:
        source: sec_score_delta
      supp_aligns:
        source: supp_aligns
      supp_as_sec:
        source: supp_as_sec
      supp_min_score_adj:
        source: supp_min_score_adj
      unclip_score:
        source: unclip_score
      unpaired_pen:
        source: unpaired_pen
      alt_aware:
        source: alt_aware
      enable_duplicate_marking:
        source: enable_duplicate_marking
      remove_duplicates:
        source: remove_duplicates
      generate_md_tags:
        source: generate_md_tags
      generate_sa_tags:
        source: generate_sa_tags
      generate_zs_tags:
        source: generate_zs_tags
      enable_sort:
        source: enable_sort
      preserve_map_align_order:
        source: preserve_map_align_order
      verbose:
        source: verbose
    out:
      - id: dragen_alignment_output_directory
      - id: dragen_bam_out
    run: ../../../tools/dragen-alignment/3.9.3/dragen-alignment__3.9.3.cwl

  # Create dummy file
  create_dummy_file_step:
    label: Create dummy file
    doc: |
      Intermediate step for letting multiqc-interop be placed in stream mode
    in: {}
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
        source: run_dragen_alignment_step/dragen_alignment_output_directory
        valueFrom: |
          ${
            return [self];
          }
      output_directory_name:
        source: output_file_prefix
        valueFrom: "$(self)_dragen_alignment_multiqc"
      output_filename:
        source: output_file_prefix
        valueFrom: "$(self)_dragen_alignment_multiqc.html"
      title:
        source: output_file_prefix
        valueFrom: "UMCCR MultiQC Dragen Alignment Report for $(self)"
      dummy_file:
        source: create_dummy_file_step/dummy_file_output
    out:
      - id: output_directory
    run: ../../../tools/multiqc/1.14.0/multiqc__1.14.0.cwl

outputs:
  # All output files will be under the output directory
  dragen_alignment_output_directory:
    label: dragen alignment output directory
    doc: |
      The output directory containing all alignment output files and qc metrics
    type: Directory
    outputSource: run_dragen_alignment_step/dragen_alignment_output_directory
  # Whilst these files reside inside the output directory, specifying them here as outputs
  # provides easier access and reference
  dragen_bam_out:
    label: dragen bam out
    doc: |
      The output alignment file
    type: File
    outputSource: run_dragen_alignment_step/dragen_bam_out
    secondaryFiles:
      - ".bai"
  #multiQC output
  multiqc_output_directory:
    label: dragen QC report out
    doc: |
      The dragen multiQC output
    type: Directory
    outputSource: dragen_qc_step/output_directory
