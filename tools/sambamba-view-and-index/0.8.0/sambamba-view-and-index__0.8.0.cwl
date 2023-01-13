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
id: sambamba-view-and-index--0.8.0
label: sambamba-view-and-index v(0.8.0)
doc: |
  Get specific reads through filter step.
  Docs can be found [here](https://lomereiter.github.io/sambamba/docs/sambamba-view.html).

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
        dockerPull: public.ecr.aws/biocontainers/sambamba:0.8.0--h984e79f_0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_num_threads = function(){
          /*
          Returns the number of threads if specified
          Otherwise returns runtime.cores value
          */
          if (inputs.nthreads !== null){
            return inputs.nthreads;
          } else {
            return runtime.cores;
          }
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: sambamba-view-and-index.sh
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Run sambamba view
          eval sambamba view '"\${@}"'

          # If --output-format is a bam file (and actually exists) then index it
          if [[ "$(inputs.output_format)" == "bam" ]] && [[ -s "$(inputs.output_filename)" ]]; then
            # Index output bam file
            sambamba index "$(inputs.output_filename)"
          fi


baseCommand: ["bash", "sambamba-view-and-index.sh"]

arguments:
  # Threads
  - prefix: "--nthreads"
    valueFrom: "$(get_num_threads())"
    # Before positional arguments
    position: 1

inputs:
  # Mandatory args
  bam_sorted:
    label: Bam Sorted
    doc: |
      Input, sorted and indexed bam file we wish to filter on
    type: File
    secondaryFiles:
      - .bai
    inputBinding:
      # Positional argument
      # Goes after all options
      position: 100
  output_filename:
    label: Output filename
    doc: |
      Name of the output file
    type: string
    inputBinding:
      prefix: "--output-filename"
  # Optional args
  filter:
    label: filter
    doc: |
      set custom filter for alignments
    type: string?
    inputBinding:
      prefix: "--filter"
  num_filter:
    label: num filter
    doc: |
      filter flag bits; 'i1/i2' corresponds to -f i1 -F i2 samtools arguments;
      either of the numbers can be omitted
    type: string?
    inputBinding:
      prefix: "--num-filter"
  output_format:
    label: Output file format
    doc: |
      The output file format of the filtered bam file.
      Can be bam, sam or cram. Sam by default.
    type:
      - type: enum
        symbols:
          - bam
          - sam
          - cram
      - "null"
    inputBinding:
      prefix: "--format"
  with_header:
    label: with header
    doc: |
       print header before reads (always done for BAM output)
    type: boolean?
    inputBinding:
      prefix: "--with-header"
  regions:
    label: regions
    doc: |
      output only reads overlapping one of regions from the BED file
    type: File?
    inputBinding:
      prefix: "--regions"
  valid:
    label: valid
    doc: |
      Output only valid alignments
    type: boolean?
    inputBinding:
      prefix: "--valid"
  compression_level:
    label: compression level
    doc: |
      Specify compression level (from 0 to 9, works only for bam output)
    type: int?
    inputBinding:
      prefix: "--compression-level"
  nthreads:
    label: Number of threads
    doc: |
      The number of threads used
    type: int?
  subsample:
    label: subsample
    doc: |
      subsample reads (read pairs)
    type: float?
    inputBinding:
      prefix: "--subsample"
  subsample_seed:
    label: subsample seed
    doc: |
      set seed for subsampling
    type: int?
    inputBinding:
      prefix: "--subsampling-seed"

outputs:
  bam_indexed:
    label: bam indexed
    doc: |
      Output indexed bam file
    type: File
    # With index
    secondaryFiles:
      - .bai
    outputBinding:
      glob: "$(inputs.output_filename)"


successCodes:
  - 0
