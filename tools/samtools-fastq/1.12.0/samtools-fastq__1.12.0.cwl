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
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: samtools-fastq--1.12.0
label: samtools-fastq v(1.12.0)
doc: |
  Converts a SAM, BAM or CRAM into either FASTQ or FASTA format depending on the command invoked.

  The files will be automatically compressed if the file names have a .gz or .bgzf extension.
  The input to this program must be collated by name. Run 'samtools collate' or 'samtools sort -n'.

  Reads are designated READ1 if FLAG READ1 is set and READ2 is not set.
  Reads are designated READ2 if FLAG READ1 is not set and READ2 is set.
  Reads are designated READ_OTHER if FLAGs READ1 and READ2 are either both set
  or both unset.
  Run 'samtools flags' for more information on flag codes and meanings.

  The index-format string describes how to parse the barcode and quality tags, for example:
     i14i8       the first 14 characters are index 1, the next 8 characters are index 2
     n8i14       ignore the first 8 characters, and use the next 14 characters for index 1
  If the tag contains a separator, then the numeric part can be replaced with '*' to mean
  'read until the separator or end of tag', for example:
     n*i*        ignore the left part of the tag until the separator, then use the second part
                 of the tag as index 1

  Examples:
   To get just the paired reads in separate files, use:
     samtools fastq -1 paired1.fq -2 paired2.fq -0 /dev/null -s /dev/null -n in.bam

   To get all non-supplementary/secondary reads in a single file, redirect the output:
     samtools fastq in.bam > all_reads.fq

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: xlarge
        coresMin: 4
        ramMin: 14000
    DockerRequirement:
        dockerPull: quay.io/biocontainers/samtools:1.12--h9aed4be_1

requirements:
  InlineJavascriptRequirement: {}

baseCommand: ["samtools", "fastq"]

inputs:
  bam_sorted:
    label: sorted bam file
    doc: |
      sorted bam file to be turned to fastqs
    type: File
    secondaryFiles:
      - pattern: ".bai"
        required: false
    inputBinding:
      # After all other options
      position: 100
  read_other:
    label: read other
    doc: |
      write reads designated READ_OTHER to FILE
    type: string?
    inputBinding:
      prefix: "-0"
  read_one:
    label: read one
    doc: |
      write reads designated READ1 to FILE
    type: string?
    inputBinding:
      prefix: "-1"
  read_two:
    label: read two
    doc: |
      write reads designated READ2 to FILE
    type: string?
    inputBinding:
      prefix: "-2"
  out_filename:
    label: out filename
    doc: |
      write reads designated READ1 or READ2 to FILE
      note: if a singleton file is specified with -s, only
      paired reads will be written to the -1 and -2 files.
    type: string?
    inputBinding:
      prefix: "-o"
  include_flags:
    label: include flags
    doc: |
      only include reads with all  of the FLAGs in INT present [0]
    type: int?
    inputBinding:
      prefix: "-f"
  exclude_any_flags:
    label: exclude any flags
    doc: |
      only include reads with none of the FLAGS in INT present [0x900]
    type: int?
    inputBinding:
      prefix: "-F"
  exclude_all_flass:
    label: exclude all flags
    doc: |
      only EXCLUDE reads with all  of the FLAGs in INT present [0]
    type: int?
    inputBinding:
      prefix: "-G"
  no_append_read_number:
    label: no append read number
    doc: |
      don't append /1 and /2 to the read name
    type: boolean?
    inputBinding:
      prefix: "-n"
  append_read_number:
    label: append read number
    doc: |
      always append /1 and /2 to the read name
    type: boolean?
    inputBinding:
      prefix: "-N"
  output_quality_tag:
    label: output quality tag
    doc: |
      output quality in the OQ tag if present
    type: boolean?
    inputBinding:
      prefix: "-O"
  singleton:
    label: singleton
    doc: |
      write singleton reads designated READ1 or READ2 to FILE
    type: string?
    inputBinding:
      prefix: "-s"
  add_tags:
    label: add tags
    doc: |
      copy RG, BC and QT tags to the FASTQ header line
    type: boolean?
    inputBinding:
      prefix: "-t"
  tag_list:
    label: tag list
    doc: |
      copy arbitrary tags to the FASTQ header line
    type: string?
    inputBinding:
      prefix: "-T"
  add_default_score:
    label: add default score
    doc: |
      default quality score if not given in file [1]
    type: int?
    inputBinding:
      prefix: "-v"
  add_illumina_casava:
    label: add illumina casava
    doc: |
      add Illumina Casava 1.8 format entry to header (eg 1:N:0:ATCACG)
    type: boolean?
    inputBinding:
      prefix: "-i"
  set_compression_level:
    label: set compression level
    doc: |
      compression level [0..9] to use when creating gz or bgzf fastq files [1]
    type: int?
    inputBinding:
      prefix: "-c"
  first_index_reads:
    label: --i1
    doc: |
      write first index reads to FILE
    type: string?
    inputBinding:
      prefix: "--i1"
  second_index_reads:
    label: --i2
    doc: |
      write second index reads to FILE
    type: string?
    inputBinding:
      prefix: "--i2"
  barcode_tag:
    label: barcode tag
    doc: |
      Barcode tag [default: BC]
    type: boolean?
    inputBinding:
      prefix: "--barcode-tag"
  quality_tag:
    label: quality tag
    doc: |
      Quality tag [default: QT]
    type: boolean?
    inputBinding:
      prefix: "--quality-tag"
  index_format:
    label: index format
    doc: |
      How to parse barcode and quality tags
    type: string?
    inputBinding:
      prefix: "--index-format"
  input_format_option:
      label: Input Format
      doc: |
        Specify a single input file format
      type:
        - type: enum
          symbols:
            - bam
            - sam
            - cram
        - "null"
      inputBinding:
        prefix: "--input-fmt-option"
  reference:
    label: reference
    doc: |
      Reference sequence fasta file
    type: File?
    inputBinding:
      prefix: "--reference"
  threads:
    label: threads
    doc: |
      Number of additional threads to use
    type: int?
    inputBinding:
      prefix: "--threads"
  verbosity:
    label: verbosity level
    doc: |
      Set level of verbosity
    type: int?
    inputBinding:
      prefix: "--verbosity"

outputs:
  read_other_out:
    label: read other out
    doc: |
      reads designated READ_OTHER to FILE
    type: File?
    outputBinding:
      glob: "$(inputs.read_other)"
  read_one_out:
    label: read one out
    doc: |
      Output file with read 1 files
    type: File?
    outputBinding:
      glob: "$(inputs.read_one)"
  read_two_out:
    label: read two out
    doc: |
      Output file with read 2 files
    type: File?
    outputBinding:
      glob: "$(inputs.read_two)"
  reads_out:
    label: reads out
    doc: |
      Output file with all reads
    type: File?
    outputBinding:
      glob: "$(inputs.out_filename)"
  singleton_out:
    label: singleton out
    doc: |
      Output of single reads only
    type: File?
    outputBinding:
      glob: "$(inputs.singleton)"
