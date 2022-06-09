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
id: bamtofastq--2.0.0
label: bamtofastq v(2.0.0)
doc: |
  |
    Documentation for bamtofastq v2.0.0

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standardHiCpu
            size: medium
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: "quay.io/biocontainers/biobambam:2.0.183--h9f5acd7_1"
requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var boolean_to_int = function(input_object){
          if (input_object === true){
            return 1;
          } else {
            return 0
          }
        }
      - var get_script_path = function(){
          /*
          Abstract script path, can then be referenced in baseCommand attribute too
          Makes things more readable.
          */
          return "scripts/run-bamtofastq.sh";
        }
      - var get_eval_line = function(){
          /*
          Get the line eval bam2fastq...
          */
          return "eval \"bamtofastq\" '\"\$@\"'\n"
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: $(get_script_path())
        entry: |
          #!/usr/bin/env bash

          # Set to fail
          set -euo pipefail

          mkdir -p "$(inputs.output_dir)"
          $(get_eval_line())

baseCommand: ["bash"]

arguments:
  # Script path
  - valueFrom: "$(get_script_path())"
    position: -1

inputs:
  output_dir:
    label: output_dir
    type: string
    doc: |
      Output directory if outputperreadgroup=1. By default the output files are generated in the current directory.
    inputBinding:
      prefix: outputdir=
      separate: false
  first_mate:
    label: F1
    type: string?
    doc: |
      Matched pairs first mates
    inputBinding:
      prefix: F=
      separate: false
  second_mate:
    label: F2
    type: string?
    doc: |
      Matched pairs second mates
    inputBinding:
      prefix: F2=
      separate: false
  single_end:
    label: single end
    type: string?
    doc: |
      Single end
    inputBinding:
      prefix: S=
      separate: false
  unmatched_pairs_first_mate:
    label: unmatched pairs first mate
    type: string?
    doc: |
      Unmatched pairs first mates
    inputBinding:
      prefix: O=
      separate: false
  unmatched_pairs_second_mate:
    label: unmatched pairs mate2
    type: string?
    doc: |
      Unmatched pairs second mates
    inputBinding:
      prefix: O2=
      separate: false
  collate:
    label: collate
    type: boolean?
    doc: |
      Collate pairs
    inputBinding:
      prefix: collate=
      separate: false
      valueFrom: "$(boolean_to_int(self))"
  combs:
    label: combs
    type: boolean?
    doc: |
      Print some counts after collation based processing
    inputBinding:
      prefix: combs=
      separate: false
      valueFrom: "$(boolean_to_int(self))"
  filename:
    label: file name
    type: File
    doc: |
      Input filename
    streamable: true
    inputBinding:
      prefix: filename=
      separate: false
  input_format:
    label: input format
    type: string?
    doc: |
      Input format: cram, bam or sam [bam]
    inputBinding:
      prefix: inputformat=
      separate: false
  reference:
    label: reference
    type: File?
    doc: |
      Iame of reference FastA in case of inputformat=cram
    inputBinding:
      prefix: reference=
      separate: false
  ranges:
    label: ranges
    type: string?
    doc: |
      Input ranges (bam and cram input only, default: read complete file)
    inputBinding:
      prefix: ranges=
      separate: false
  exclude:
    label: exclude
    type: string?
    doc: |
      Exclude alignments matching any of the given flags [SECONDARY,SUPPLEMENTARY]
    inputBinding:
      prefix: exclude=
      separate: false
  disable_validation:
    label: disable validation
    type: boolean?
    doc: |
      Disable validation of input data [0]
    inputBinding:
      prefix: disablevalidation=
      separate: false
      valueFrom: "$(boolean_to_int(self))"
  colh_log:
    label: col h log
    type: int?
    doc: |
      Base 2 logarithm of hash table size used for collation [18]
    inputBinding:
      prefix: colhlog=
      separate: false
  cols_bs:
    label: cols bs
    type: int?
    doc: |
      Size of hash table overflow list in bytes [33554432]
    inputBinding:
      prefix: colsbs=
      separate: false
  tmp_file_name:
    label: t
    type: string?
    doc: |
      Temporary file name [bamtofastq_*]
    inputBinding:
      prefix: exclude=
      separate: false
  gzip:
    label: gz
    type: boolean?
    doc: |
      Compress output streams in gzip format (default: 0)
    inputBinding:
      prefix: gz=
      separate: false
      valueFrom: "$(boolean_to_int(self))"
  level:
    label: level
    type: int?
    doc: |
      Compression setting if gz=1 (-1=zlib default,0=uncompressed,1=fast,9=best)
    inputBinding:
      prefix: level=
      separate: false
  fasta:
    label: fasta
    type: boolean?
    doc: |
      Output FastA instead of FastQ
    inputBinding:
      prefix: fasta=
      separate: false
      valueFrom: "$(boolean_to_int(self))"
  input_buffer_size:
    label: input buffer size
    type: int?
    doc: |
      Size of input buffer
    inputBinding:
      prefix: inputbuffersize=
      separate: false
  output_per_readgroup:
    label: output per read group
    type: boolean?
    doc: |
      Split output per read group (for collate=1 only)
    inputBinding:
      prefix: outputperreadgroup=
      separate: false
      valueFrom: "$(boolean_to_int(self))"
  output_per_readgroup_suffix_f1:
    label: output per read group suffix F1
    type: string?
    doc: |
      Suffix for F category when outputperreadgroup=1 [_1.fq]
    inputBinding:
      prefix: outputperreadgroupsuffixF=
      separate: false
  output_per_readgroup_suffix_f2:
    label: output per read group suffix F2
    type: string?
    doc: |
      Suffix for F2 category when outputperreadgroup=1 [_2.fq]
    inputBinding:
      prefix: outputperreadgroupsuffixF2=
      separate: false
  output_per_readgroup_suffix_o1:
    label: output per read group suffix O
    type: string?
    doc: |
      Suffix for O category when outputperreadgroup=1 [_o1.fq]
    inputBinding:
      prefix: outputperreadgroupsuffixO=
      separate: false
  output_per_readgroup_suffix_o2:
    label: output per read group suffix O2
    type: string?
    doc: |
      Suffix for O2 category when outputperreadgroup=1 [_o2.fq]
    inputBinding:
      prefix: outputperreadgroupsuffixO2=
      separate: false
  output_per_readgroup_suffix_s:
    label: output per read group suffix S 
    type: string?
    doc: |
      Suffix for S category when outputperreadgroup=1 [_s.fq]
    inputBinding:
      prefix: outputperreadgroupsuffixS=
      separate: false
  try_oq:
    label: try oq
    type: boolean?
    doc: |
      Use OQ field instead of quality field if present (collate={0,1} only) [0]
    inputBinding:
      prefix: tryoq=
      separate: false
      valueFrom: "$(boolean_to_int(self))"
  split:
    label: split
    type: boolean?
    doc: |
      Split named output files into chunks of this amount of reads (0: do not split)
    inputBinding:
      prefix: split=
      separate: false
      valueFrom: "$(boolean_to_int(self))"
  split_prefix:
    label: split prefix
    type: string?
    doc: |
      File name prefix if collate=0 and split>0
    inputBinding:
      prefix: splitprefix=
      separate: false
  tags:
    label: tags
    type: string?
    doc: |
      List of aux tags to be copied (default: do not copy any aux fields)
    inputBinding:
      prefix: tags=
      separate: false
  output_per_readgroup_rgsm:
    label: output per readgroup rgsm
    type: boolean?
    doc: |
      Add read group field SM ahead of read group id when outputperreadgroup=1 (for collate=1 only)
    inputBinding:
      prefix: outputperreadgrouprgsm=
      separate: false
      valueFrom: "$(boolean_to_int(self))"
  output_per_readgroup_prefix:
    label: output per read group prefix
    type: string?
    doc: |
      Prefix added in front of file names if outputperreadgroup=1 (for collate=1 only)
    inputBinding:
      prefix: outputperreadgroupprefix=
      separate: false
outputs:
  output_directory:
    label: output dircetory
    type: Directory
    doc: |
      Output dircetory containing the fastq files
    outputBinding:
      glob: "$(inputs.output_dir)"
    
successCodes:
  - 0
