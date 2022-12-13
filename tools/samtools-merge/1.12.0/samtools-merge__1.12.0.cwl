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
id: samtools-merge--1.12.0
label: samtools-merge v(1.12.0)
doc: |
  Merge multiple sorted alignment files, producing a single sorted output file that contains all the input records
  and maintains the existing sort order.
  If -h is specified the @SQ headers of input files will be merged into the specified header,
  otherwise they will be merged into a composite header created from the input headers. If in the process of merging @SQ lines for coordinate sorted input files, a conflict arises as to the order (for example input1.bam has @SQ for a,b,c and input2.bam has b,a,c) then the resulting output file will need to be re-sorted back into coordinate order.
  Unless the -c or -p flags are specified then when merging @RG and @PG records into the output header then any IDs
  found to be duplicates of existing IDs in the output header will have a suffix appended to them to differentiate
  them from similar header records from other files and the read records will be updated to reflect this.
  The ordering of the records in the input files must match the usage of the -n and -t command-line options.
  If they do not, the output order will be undefined. See sort for information about record ordering.

hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: xlarge
        coresMin: 4
        ramMin: 14000
    DockerRequirement:
        dockerPull: public.ecr.aws/biocontainers/samtools:1.12--h9aed4be_1

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_threads_val = function(specified_threads){
          /*
          Set thread count number of cores specified
          Since samtools uses this as the number of additional threads we subtract 1 from the number
          of runtime.cores
          */
          if (specified_threads === null){
            return runtime.cores - 1;
          } else {
            return specified_threads;
          }
        }

baseCommand: [ "samtools", "merge" ]

inputs:
  # Positional parameters (required)
  sorted_bams:
    label: sorted bams
    doc: |
      List of sorted bam files
    type: File[]
    inputBinding:
      # After all other parameters
      position: 100
    secondaryFiles:
      - pattern: ".bai"
        required: true
  output_bam_name:
    label: output bam name
    doc: |
      The output bam file
    type: string
    inputBinding:
      # After all other parameters (except input bams)
      position: 99
  # Keyword parameters (optional)
  sorted_by_read_name:
    label: sorted by read name
    doc: |
      Input files are sorted by read name
    type: boolean?
    inputBinding:
      prefix: "-n"
  sorted_by_tag_value:
    label: sorted by tag value
    doc: |
      Input files are sorted by tag value
    type: string?
    inputBinding:
      prefix: "-t"
  attach_rg_tag:
    label: attach rg tag
    doc: |
      Attach RG tag (inferred from file names)
    type: boolean?
    inputBinding:
      prefix: "-r"
  uncompressed_bam_output:
    label: uncompressed bam output
    doc: |
      Write out BAM output as uncompressed BAM. Makes reading faster
    type: boolean?
    inputBinding:
      prefix: "-u"
  compress_level:
    label: compress level
    doc: |
      Integer from 0-9 on compression level (default is -1 or uncompressed)
    type: int?
    inputBinding:
      prefix: "-l"
  merge_region:
    label: merge region
    doc: |
      Merge file in the specified region STR [all]
    type: string?
    inputBinding:
      prefix: "-R"
  copy_header:
    label: copy header
    doc: |
      Copy the header in FILE to <out.bam> [in1.bam]
    type: boolean?
    inputBinding:
      prefix: "-h"
  combine_rg_headers:
    label: combine rg headers
    doc: |
      Combine @RG headers with colliding IDs [alter IDs to be distinct]
    type: boolean?
    inputBinding:
      prefix: "-c"
  combine_pg_headers:
    label: combine pg headers
    doc: |
      Combine @PG headers with colliding IDs [alter IDs to be distinct]
    type: boolean?
    inputBinding:
      prefix: "-p"
  override_random_seed:
    label: override random seed
    doc: |
      Override random seed
    type: boolean?
    inputBinding:
      prefix: "-s"
  customise_index_files:
    label: customise index files
    doc: |
      Use customized index files
    type: boolean?
    inputBinding:
      prefix: "-X"
  region_filtering:
    label: region filtering
    doc: |
       Specify a bed file for multiple region filtering
    type: File?
    inputBinding:
      prefix: "-L"
  no_pg_line:
    label: no pg line
    doc: |
      do not add a PG line
    type: boolean?
    inputBinding:
      prefix: "--no-PG"
  reference:
    label: reference
    doc: |
      Reference sequence FASTA FILE [null]
    type: File?
    inputBinding:
      prefix: "--reference"
    secondaryFiles:
      - pattern: ".fai"
        required: true
  threads:
    label: threads
    doc: |
      Number of additional threads to use (set by runtime cores if not set here)
    type: int?
  write_index:
    label: write index
    doc: |
      Automatically index the output files
    type: boolean?
    inputBinding:
      prefix: "--write-index"
  verbosity:
    label: verbosity
    doc: |
      Set level of verbosity
    type: int?
    inputBinding:
      prefix: "--verbosity"

arguments:
  # Threads argument
  - prefix: "--threads"
    valueFrom: "$(get_threads_val(inputs.threads))"
    position: 1

outputs:
  # Output bam
  output_bam:
    label: output bam
    doc: |
      The output bam file
    type: File?
    outputBinding:
      glob: "$(inputs.output_bam_name)"
    secondaryFiles:
      # If --write-index specified
      - pattern: ".bai"
        required: false