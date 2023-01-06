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
id: dragen-alignment--3.7.5
label: dragen-alignment v(3.7.5)
doc: |
    Documentation for dragen-alignment v3.7.5


# Hints and requirements
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
        dockerPull: "699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:3.7.5"

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml
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
      - var get_fastq_list_path = function() {
          /*
          The fastq list path must be placed in working directory
          */
          return "fastq_list.csv"
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
          We also add in the fastq-list.csv into the working directory,
          since Read1File and Read2File are relative its position
          */

          var e = [{
                      "entryname": get_script_path(),
                      "entry": get_script_contents()
                    },
                   {
                      "entryname": get_fastq_list_path(),
                      "entry": inputs.fastq_list
                   }];

          /*
          Check if input_mounts record is defined
          The fastq-list.csv could be using presigned urls instead
          */
          if (inputs.fastq_list_mount_paths === null){
              return e;
          }

          /*
          Iterate through each file to mount
          Mount that object at the same reference to the mount point index.
          */
          inputs.fastq_list_mount_paths.forEach(function(mount_path_record){
            e.push({
                'entry': mount_path_record.file_obj,
                'entryname': mount_path_record.mount_path
            });
          });

          /*
          Return file paths
          */
          return e;
      }


# Base command and args
baseCommand: [ "bash" ]

arguments:
  # Script path
  - valueFrom: "$(get_script_path())"
    position: -1
  # Preset parameters
  - prefix: "--intermediate-results-dir"
    valueFrom: "$(get_intermediate_results_dir())"
  - prefix: "--output-format"
    valueFrom: "BAM"


# Inputs
inputs:
  # File inputs
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process.
      Read1File and Read2File may be presigned urls or use this in conjunction with
      the fastq_list_mount_paths inputs.
    type: File
    inputBinding:
      prefix: "--fastq-list"
  fastq_list_mount_paths:
    label: fastq list mount paths
    doc: |
      Path to fastq list mount path
    type: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml#predefined-mount-path[]?
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
    inputBinding:
      prefix: "--ref-dir"
      valueFrom: "$(get_ref_path(self))"
  # Output naming options
  output_file_prefix:
    label: output file prefix
    doc: |
      The prefix given to all output files
    type: string
    inputBinding:
      prefix: "--output-file-prefix"
  output_directory:
    label: output directory
    doc: |
      The directory where all output files are placed
    type: string
    inputBinding:
      prefix: "--output-directory"

  ### Start mapper options ###
  ann_sj_max_indel:
    label: ann sj max indel
    doc: |
      Maximum indel length to expect near an annotated splice junction.
      Range: 0 - 63
    type: int?
    inputBinding:
      prefix: "--Mapper.ann-sj-max-indel"
  edit_chain_limit:
    label: edit chain limit
    doc: |
      For edit-mode 1 or 2: Maximum seed chain length in a read to qualify for seed editing.
      Range: > 0
    type: int?
    inputBinding:
      prefix: "--Mapper.edit-chain-limit"
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
      prefix: "--Mapper.edit-mode"
  edit_read_len:
    label: edit read len
    doc: |
      For edit-mode 1 or 2: Read length in which to try edit-seed-num edited seeds.
      Range: > 0
    type: int?
    inputBinding:
      prefix: "--Mapper.edit-read-len"
  edit_seed_num:
    label: edit seed num
    doc: |
      For edit-mode 1 or 2: Requested number of seeds per read to allow editing on.
      Range: > 0
    type: int?
    inputBinding:
      prefix: "--Mapper.edit-seed-num"
  enable_map_align:
    label: enable map align
    doc: |
      Enable use of BAM input files for mapper/aligner.
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align"
      valueFrom: "$(self.toString())"
  max_intron_bases:
    label: max intron bases
    doc: |
      Maximum intron length reported.
    type: int?
    inputBinding:
      prefix: "--Mapper.max-intron-bases"
  min_intron_bases:
    label: min intron bases
    doc: |
      Minimum reference deletion length reported as an intron.
    type: int?
    inputBinding:
      prefix: "--Mapper.min-intron-bases"
  seed_density:
    label: seed density
    doc: |
      Requested density of seeds from reads queried in the hash table
      Range: 0 - 1
    type: float?
    inputBinding:
      prefix: "--Mapper.seed-density"
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
      prefix: "--Aligner.aln-min-score"
  dedup_min_qual:
    label: dedup min qual
    doc: |
      Minimum base quality for calculating read quality metric for deduplication.
      Range: 0-63
    type: int?
    inputBinding:
      prefix: "--Aligner.dedup-min-qual"
  en_alt_hap_aln:
    label: en alt hap aln
    doc: |
      Allows chimeric alignments to be output, as supplementary.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.en-alt-hap-aln"
      valueFrom: "$(Number(self))"
  en_chimeric_aln:
    label: en chimeric aln
    doc: |
      Allows chimeric alignments to be output, as supplementary.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.en-chimeric-aln"
      valueFrom: "$(Number(self))"
  gap_ext_pen:
    label: gap ext pen
    doc: |
      Score penalty for gap extension.
    type: int?
    inputBinding:
      prefix: "--Aligner.gap-ext-pen"
  gap_open_pen:
    label: gap open pen
    doc: |
      Score penalty for opening a gap (insertion or deletion).
    type: int?
    inputBinding:
      prefix: "--gap-open-pen"
  global:
    label: global
    doc: |
      If alignment is global (Needleman-Wunsch) rather than local (Smith-Waterman).
    type: boolean?
    inputBinding:
      prefix: "--Aligner.global"
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
      prefix: "--Aligner.hard-clips"
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
      prefix: "--Aligner.map-orientations"
  mapq_max:
    label: mapq max
    doc: |
      Ceiling on reported MAPQ. Max 255
    type: int?
    inputBinding:
      prefix: "--Aligner.mapq-max"
  mapq_strict_js:
    label: mapq strict js
    doc: |
      Specific to RNA. When set to 0, a higher MAPQ value is returned, expressing confidence that the alignment is at least partially correct. When set to 1, a lower MAPQ value is returned, expressing the splice junction ambiguity.
    type: boolean?
    inputBinding:
      prefix: "--mapq-strict-js"
      valueFrom: "$(Number(self))"
  match_n_score:
    label: match n score
    doc: |
      (signed) Score increment for matching a reference 'N' nucleotide IUB code.
      Range: -16 to 15
    type: int?
    inputBinding:
      prefix: "--Aligner.match-n-score"
  match_score:
    label: match score
    doc: |
      Score increment for matching reference nucleotide.
      When global = 0, match-score > 0; When global = 1, match-score >= 0
    type: float?
    inputBinding:
      prefix: "--Aligner.match-score"
  max_rescues:
    label: max rescues
    doc: |
      Maximum rescue alignments per read pair. Default is 10
    type: int?
    inputBinding:
      prefix: "--max-rescues"
  min_score_coeff:
    label: min score coeff
    doc: |
      Adjustment to aln-min-score per read base.
      Range: -64 to 63.999
    type: float?
    inputBinding:
      prefix: "--Aligner.min-score-coeff"
  mismatch_pen:
    label: mismatch pen
    doc: |
      Score penalty for a mismatch.
    type: int?
    inputBinding:
      prefix: "--Aligner.mismatch-pen"
  no_unclip_score:
    label: no unclip score
    doc: |
      When no-unclip-score is set to 1, any unclipped bonus (unclip-score) contributing to an alignment is removed from the alignment score before further processing.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.no-unclip-score"
      valueFrom: "$(Number(self))"
  no_unpaired:
    label: no unpaired
    doc: |
      If only properly paired alignments should be reported for paired reads.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.no-unpaired"
      valueFrom: "$(Number(self))"
  pe_max_penalty:
    label: pe max penalty
    doc: |
      Maximum pairing score penalty, for unpaired or distant ends.
      Range: 0-255
    type: int?
    inputBinding:
      prefix: "--Aligner.pe-max-penalty"
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
      prefix: "--Aligner.pe-orientation"
  rescue_sigmas:
    label: rescue sigmas
    doc: |
      Deviations from the mean read length used for rescue scan radius. Default is 2.5.
    type: float?
    inputBinding:
      prefix: "--Aligner.rescue-sigmas"
  sec_aligns:
    label: sec aligns
    doc: |
      Maximum secondary (suboptimal) alignments to report per read.
      Range: 0 - 30
    type: int?
    inputBinding:
      prefix: "--Aligner.sec-aligns"
  sec_aligns_hard:
    label: sec aligns hard
    doc: |
      Set to force unmapped when not all secondary alignments can be output.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.sec-aligns-hard"
      valueFrom: "$(Number(self))"
  sec_phred_delta:
    label: sec phred delta
    doc: |
      Only secondary alignments with likelihood within this Phred of the primary are reported.
      Range: 0 - 255
    type: int?
    inputBinding:
      prefix: "--Aligner.sec-phred-delta"
  sec_score_delta:
    label: sec score delta
    doc: |
      Secondary aligns allowed with pair score no more than this far below primary.
    type: float?
    inputBinding:
      prefix: "--Aligner.sec-score-delta"
  supp_aligns:
    label: supp aligns
    doc: |
      Maximum supplementary (chimeric) alignments to report per read.
    type: int?
    inputBinding:
      prefix: "--Aligner.supp-aligns"
  supp_as_sec:
    label: supp as sec
    doc: |
      If supplementary alignments should be reported with secondary flag.
    type: boolean?
    inputBinding:
      prefix: "--Aligner.supp-as-sec"
      valueFrom: "$(Number(self))"
  supp_min_score_adj:
    label: supp min score adj
    doc: |
      Amount to increase minimum alignment score for supplementary alignments.
      This score is computed by host software as "8 * match-score" for DNA, and is default 0 for RNA.
    type: float?
    inputBinding:
      prefix: "--Aligner.supp-min-score-adj"
  unclip_score:
    label: unclip score
    doc: |
      Score bonus for reaching each edge of the read.
      Range: 0 - 127
    type: int?
    inputBinding:
      prefix: "--Aligner.unclip-score"
  unpaired_pen:
    label: unpaired pen
    doc: |
      Penalty for unpaired alignments in Phred scale.
      Range: 0 - 255
    type: int?
    inputBinding:
      prefix: "--Aligner.unpaired-pen"
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
      prefix: "--alt-aware"
      valueFrom: "$(self.toString())"
  # Duplicate marking
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Enable the flagging of duplicate output alignment records.
    type: boolean?
    inputBinding:
      prefix: "--enable-duplicate-marking"
      valueFrom: "$(self.toString())"
  remove_duplicates:
    label: remove duplicates
    doc: |
      If true, remove duplicate alignment records instead of just flagging them.
    type: boolean?
    inputBinding:
      prefix: "--remove-duplicates"
      valueFrom: "$(self.toString())"
  # Tag generation
  generate_md_tags:
    label: generate md tags
    doc: |
      Whether to generate MD tags with alignment output records. Default is false.
    type: boolean?
    inputBinding:
      prefix: "--generate-md-tags"
      valueFrom: "$(self.toString())"
  generate_sa_tags:
    label: generate sa tags
    doc: |
      Whether to generate SA:Z tags for records that have chimeric/supplemental alignments.
    type: boolean?
    inputBinding:
      prefix: "--generate-sa-tags"
      valueFrom: "$(self.toString())"
  generate_zs_tags:
    label: generate zs tags
    doc: |
      Whether to generate ZS tags for alignment output records. Default is false.
    type: boolean?
    inputBinding:
      prefix: "--generate-zs-tags"
      valueFrom: "$(self.toString())"
  # Sorting logic
  enable_sort:
    label: enable sort
    doc: |
      Enable sorting after mapping/alignment.
    type: boolean?
    inputBinding:
      prefix: "--enable-sort"
      valueFrom: "$(self.toString())"
  preserve_map_align_order:
    label: preserve map align order
    doc: |
      Produce output file that preserves original order of reads in the input file.
    type: boolean?
    inputBinding:
      prefix: "--preserve-map-align-order"
      valueFrom: "$(self.toString())"
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
