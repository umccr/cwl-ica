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
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

s:maintainer:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: dragen-alignment--4.2.4
label: dragen-alignment v(4.2.4)
doc: |
    Documentation for dragen-alignment v4.2.4

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
        dockerPull: 699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:4.2.4

requirements:
  ResourceRequirement:
    tmpdirMin: |
      ${
        /* 1 Tb */
        return 2 ** 20; 
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

          # Reset dragen
          /opt/edico/bin/dragen_reset

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

          # Confirm not both fastq_list and fastq_list_rows are defined
          if [[ "$(is_not_null(inputs.fastq_list))" == "true" && "$(is_not_null(inputs.fastq_list_rows))" == "true" ]]; then
            echo "Cannot set both CWL inputs fastq_list AND fastq_list_rows" 1>&2
            exit 1
          fi

          # Run dragen command and import options from cli
          "$(get_dragen_bin_path())" "\${@}"
      - |
        ${
          return generate_germline_mount_points(inputs);
        }

# Base command and args
baseCommand: [ "bash" ]

arguments:
  # Script path
  - valueFrom: "$(get_script_path())"
    position: -1
  # Set fastq list
  - prefix: "--fastq-list="
    separate: False
    valueFrom: "$(get_fastq_list_csv_path())"
  # Preset parameters
  - prefix: "--intermediate-results-dir="
    separate: False
    valueFrom: "$(get_intermediate_results_dir())"
  - prefix: "--output-format="
    separate: False
    valueFrom: "BAM"

# Inputs
inputs:
  # File inputs
  # Option 1:
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process.
      Read1File and Read2File must be presigned urls in order to use the fastq_list option.
      Otherwise use the fastq_list_rows option
    type: File?
  # Option 2:
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
    inputBinding:
      prefix: "--ref-dir="
      separate: False
      valueFrom: "$(get_ref_path(self))"
  # RNA options
  enable_rna:
    label: enable rna
    doc: |
      Enable rna specific settings
    type: boolean?
    inputBinding:
      prefix: "--enable-rna="
      separate: False
      valueFrom: "$(self.toString())"
  enable_rrna_filter:
    label: enable rrna filtering
    doc: |
      Use the DRAGEN RNA pipeline to filter rRNA reads during alignment. The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--rrna-filter-enable="
      separate: False
      valueFrom: "$(self.toString())"
  enable_rna_quantification:
    label: enable rna quantification
    doc: |
      If set to true, enables RNA quantification. Requires --enable-rna to be set to true.
    type: boolean?
    inputBinding:
      prefix: "--enable-rna-quantification="
      separate: False
      valueFrom: "$(self.toString())"
  annotation_file:
    label: annotation file
    doc: |
      Use to supply a gene annotation file. Required for quantification and gene-fusion.
    type: File?
    inputBinding:
      prefix: "--annotation-file="
      separate: False
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

  ### Start mapper options ###
  ann_sj_max_indel:
    label: ann sj max indel
    doc: |
      Maximum indel length to expect near an annotated splice junction.
      Range: 0 - 63
    type: int?
    inputBinding:
      prefix: "--Mapper.ann-sj-max-indel="
      separate: False
  edit_chain_limit:
    label: edit chain limit
    doc: |
      For edit-mode 1 or 2: Maximum seed chain length in a read to qualify for seed editing.
      Range: > 0
    type: int?
    inputBinding:
      prefix: "--Mapper.edit-chain-limit="
      separate: False
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
    inputBinding:
      prefix: "--Mapper.edit-mode="
      separate: False
  edit_read_len:
    label: edit read len
    doc: |
      For edit-mode 1 or 2: Read length in which to try edit-seed-num edited seeds.
      Range: > 0
    type: int?
    inputBinding:
      prefix: "--Mapper.edit-read-len="
      separate: False
  edit_seed_num:
    label: edit seed num
    doc: |
      For edit-mode 1 or 2: Requested number of seeds per read to allow editing on.
      Range: > 0
    type: int?
    inputBinding:
      prefix: "--Mapper.edit-seed-num="
      separate: False
  enable_map_align:
    label: enable map align
    doc: |
      Enable step of mapper/aligner.
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align="
      separate: False
      valueFrom: "$(self.toString())"
  enable_map_align_output:
    label: enable map align
    doc: |
      Enables saving the output from the map/align stage.
      If only running map/align, the default value is true.
      If running the variant caller, the default value is false.
      Therefore in the case of the dragen alignment pipeline, this will always be true.
      For sanity purposes, we have it as an option since its default state is not intuitive
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align-output="
      separate: False
      valueFrom: "$(self.toString())"
  max_intron_bases:
    label: max intron bases
    doc: |
      Maximum intron length reported.
    type: int?
    inputBinding:
      prefix: "--Mapper.max-intron-bases="
      separate: False
  min_intron_bases:
    label: min intron bases
    doc: |
      Minimum reference deletion length reported as an intron.
    type: int?
    inputBinding:
      prefix: "--Mapper.min-intron-bases="
      separate: False
  seed_density:
    label: seed density
    doc: |
      Requested density of seeds from reads queried in the hash table
      Range: 0 - 1
    type: float?
    inputBinding:
      prefix: "--Mapper.seed-density="
      separate: False
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
    inputBinding:
      prefix: "--Aligner.aln-min-score="
      separate: False
  dedup_min_qual:
    label: dedup min qual
    doc: |
      Minimum base quality for calculating read quality metric for deduplication.
      Range: 0-63
    type: int?
    inputBinding:
      prefix: "--Aligner.dedup-min-qual="
      separate: False
  en_alt_hap_aln:
    label: en alt hap aln
    doc: |
      Allows chimeric alignments to be output, as supplementary.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.en-alt-hap-aln="
      separate: False
      valueFrom: "$(Number(self))"
  en_chimeric_aln:
    label: en chimeric aln
    doc: |
      Allows chimeric alignments to be output, as supplementary.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.en-chimeric-aln="
      separate: False
      valueFrom: "$(Number(self))"
  gap_ext_pen:
    label: gap ext pen
    doc: |
      Score penalty for gap extension.
    type: int?
    inputBinding:
      prefix: "--Aligner.gap-ext-pen="
      separate: False
  gap_open_pen:
    label: gap open pen
    doc: |
      Score penalty for opening a gap (insertion or deletion).
    type: int?
    inputBinding:
      prefix: "--gap-open-pen="
      separate: False
  global:
    label: global
    doc: |
      If alignment is global (Needleman-Wunsch) rather than local (Smith-Waterman).
    type: boolean?
    inputBinding:
      prefix: "--Aligner.global="
      separate: False
      valueFrom: "$(Number(self))"
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
    inputBinding:
      prefix: "--Aligner.hard-clips="
      separate: False
      valueFrom: |
        ${
          return (self >> 0).toString(2);
        }
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
    inputBinding:
      prefix: "--Aligner.map-orientations="
      separate: False
  mapq_max:
    label: mapq max
    doc: |
      Ceiling on reported MAPQ. Max 255
    type: int?
    inputBinding:
      prefix: "--Aligner.mapq-max="
      separate: False
  mapq_strict_js:
    label: mapq strict js
    doc: |
      Specific to RNA. When set to 0, a higher MAPQ value is returned, expressing confidence that the alignment is at least partially correct. When set to 1, a lower MAPQ value is returned, expressing the splice junction ambiguity.
    type: boolean?
    inputBinding:
      prefix: "--mapq-strict-js="
      separate: False
      valueFrom: "$(Number(self))"
  match_n_score:
    label: match n score
    doc: |
      (signed) Score increment for matching a reference 'N' nucleotide IUB code.
      Range: -16 to 15
    type: int?
    inputBinding:
      prefix: "--Aligner.match-n-score="
      separate: False
  match_score:
    label: match score
    doc: |
      Score increment for matching reference nucleotide.
      When global = 0, match-score > 0; When global = 1, match-score >= 0
    type: float?
    inputBinding:
      prefix: "--Aligner.match-score="
      separate: False
  max_rescues:
    label: max rescues
    doc: |
      Maximum rescue alignments per read pair. Default is 10
    type: int?
    inputBinding:
      prefix: "--max-rescues="
      separate: False
  min_score_coeff:
    label: min score coeff
    doc: |
      Adjustment to aln-min-score per read base.
      Range: -64 to 63.999
    type: float?
    inputBinding:
      prefix: "--Aligner.min-score-coeff="
      separate: False
  mismatch_pen:
    label: mismatch pen
    doc: |
      Score penalty for a mismatch.
    type: int?
    inputBinding:
      prefix: "--Aligner.mismatch-pen="
      separate: False
  no_unclip_score:
    label: no unclip score
    doc: |
      When no-unclip-score is set to 1, any unclipped bonus (unclip-score) contributing to an alignment is removed from the alignment score before further processing.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.no-unclip-score="
      separate: False
      valueFrom: "$(Number(self))"
  no_unpaired:
    label: no unpaired
    doc: |
      If only properly paired alignments should be reported for paired reads.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.no-unpaired="
      separate: False
      valueFrom: "$(Number(self))"
  pe_max_penalty:
    label: pe max penalty
    doc: |
      Maximum pairing score penalty, for unpaired or distant ends.
      Range: 0-255
    type: int?
    inputBinding:
      prefix: "--Aligner.pe-max-penalty="
      separate: False
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
    inputBinding:
      prefix: "--Aligner.pe-orientation="
      separate: False
  rescue_sigmas:
    label: rescue sigmas
    doc: |
      Deviations from the mean read length used for rescue scan radius. Default is 2.5.
    type: float?
    inputBinding:
      prefix: "--Aligner.rescue-sigmas="
      separate: False
  sec_aligns:
    label: sec aligns
    doc: |
      Maximum secondary (suboptimal) alignments to report per read.
      Range: 0 - 30
    type: int?
    inputBinding:
      prefix: "--Aligner.sec-aligns="
      separate: False
  sec_aligns_hard:
    label: sec aligns hard
    doc: |
      Set to force unmapped when not all secondary alignments can be output.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.sec-aligns-hard="
      separate: False
      valueFrom: "$(Number(self))"
  sec_phred_delta:
    label: sec phred delta
    doc: |
      Only secondary alignments with likelihood within this Phred of the primary are reported.
      Range: 0 - 255
    type: int?
    inputBinding:
      prefix: "--Aligner.sec-phred-delta="
      separate: False
  sec_score_delta:
    label: sec score delta
    doc: |
      Secondary aligns allowed with pair score no more than this far below primary.
    type: float?
    inputBinding:
      prefix: "--Aligner.sec-score-delta="
      separate: False
  supp_aligns:
    label: supp aligns
    doc: |
      Maximum supplementary (chimeric) alignments to report per read.
    type: int?
    inputBinding:
      prefix: "--Aligner.supp-aligns="
      separate: False
  supp_as_sec:
    label: supp as sec
    doc: |
      If supplementary alignments should be reported with secondary flag.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.supp-as-sec="
      separate: False
      valueFrom: "$(Number(self))"
  supp_min_score_adj:
    label: supp min score adj
    doc: |
      Amount to increase minimum alignment score for supplementary alignments.
      This score is computed by host software as "8 * match-score" for DNA, and is default 0 for RNA.
    type: float?
    inputBinding:
      prefix: "--Aligner.supp-min-score-adj="
      separate: False
  unclip_score:
    label: unclip score
    doc: |
      Score bonus for reaching each edge of the read.
      Range: 0 - 127
    type: int?
    inputBinding:
      prefix: "--Aligner.unclip-score="
      separate: False
  unpaired_pen:
    label: unpaired pen
    doc: |
      Penalty for unpaired alignments in Phred scale.
      Range: 0 - 255
    type: int?
    inputBinding:
      prefix: "--Aligner.unpaired-pen="
      separate: False
  ### End Alignment options ###
  ### Start General software options
  # Alt aware mapping
  alt_aware:
    label: alt aware
    doc: |
      Enables special processing for alt contigs, if alt liftover was used in hash table.
      Enabled by default if reference was built with liftover.
    type: boolean?
    inputBinding:
      prefix: "--alt-aware="
      separate: False
      valueFrom: "$(self.toString())"
  # Duplicate marking
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Enable the flagging of duplicate output alignment records.
    type: boolean?
    inputBinding:
      prefix: "--enable-duplicate-marking="
      separate: False
      valueFrom: "$(self.toString())"
  remove_duplicates:
    label: remove duplicates
    doc: |
      If true, remove duplicate alignment records instead of just flagging them.
    type: boolean?
    inputBinding:
      prefix: "--remove-duplicates="
      separate: False
      valueFrom: "$(self.toString())"
  # Tag generation
  generate_md_tags:
    label: generate md tags
    doc: |
      Whether to generate MD tags with alignment output records. Default is false.
    type: boolean?
    inputBinding:
      prefix: "--generate-md-tags="
      separate: False
      valueFrom: "$(self.toString())"
  generate_sa_tags:
    label: generate sa tags
    doc: |
      Whether to generate SA:Z tags for records that have chimeric/supplemental alignments.
    type: boolean?
    inputBinding:
      prefix: "--generate-sa-tags="
      separate: False
      valueFrom: "$(self.toString())"
  generate_zs_tags:
    label: generate zs tags
    doc: |
      Whether to generate ZS tags for alignment output records. Default is false.
    type: boolean?
    inputBinding:
      prefix: "--generate-zs-tags="
      separate: False
      valueFrom: "$(self.toString())"
  # Sorting logic
  enable_sort:
    label: enable sort
    doc: |
      Enable sorting after mapping/alignment.
    type: boolean?
    inputBinding:
      prefix: "--enable-sort="
      separate: False
      valueFrom: "$(self.toString())"
  preserve_map_align_order:
    label: preserve map align order
    doc: |
      Produce output file that preserves original order of reads in the input file.
    type: boolean?
    inputBinding:
      prefix: "--preserve-map-align-order="
      separate: False
      valueFrom: "$(self.toString())"
  # Add in the lic-license-id-location
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
  # Verbosity
  verbose:
    label: verbose
    doc: |
      Enable verbose output from DRAGEN.
    type: boolean?
    inputBinding:
      prefix: "-v"

# Outputs
outputs:
  # Will also include mounted-files.txt
  dragen_alignment_output_directory:
    label: dragen alignment output directory
    doc: |
      The output directory containing all alignment output files and qc metrics
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory)"
  # Whilst these files reside inside the output directory, specifying them here as outputs
  # provides easier access and reference
  dragen_bam_out:
    label: dragen bam out
    doc: |
      The output alignment file
    type: File
    outputBinding:
      glob: "$(inputs.output_directory)/$(inputs.output_file_prefix).bam"
    secondaryFiles:
      - ".bai"

successCodes:
  - 0
