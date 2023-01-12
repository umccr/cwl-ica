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
    s:name: Yinan Wang
    s:email: ywang16@illumina.com

s:maintainer:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: mosdepth--0.3.1
label: mosdepth v(0.3.1)
doc: |
    Output per-base depth in an easy to read format.

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
        dockerPull: public.ecr.aws/biocontainers/mosdepth:0.3.1--ha7ba039_0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_output_prefix = function(){
          /*
          Get inputs.output_prefix value, fall back to inputs.bam_or_cram nameroot
          */
          if (inputs.prefix !== null) {
            return inputs.prefix;
          }
          return inputs.bam_sorted.nameroot;
        }
      - var get_threads_val = function(){
          /*
          Set thread count number of cores specified
          of runtime.cores
          */
          if (inputs.threads === null){
            return runtime.cores;
          } else {
            return inputs.threads;
          }
        }

baseCommand: [ "mosdepth" ]

arguments:
  # Set threads
  - prefix: "--threads"
    valueFrom: "$(get_threads_val())"
  # Get output prefix
  - valueFrom: "$(get_output_prefix())"
    position: 99

inputs:
  # Positional args
  bam_sorted:
    label: bam sorted
    doc: |
      Sorted bam file
    type: File
    secondaryFiles:
      - pattern: .bai
        required: true
    inputBinding:
      position: 100
  prefix:
    label: prefix
    doc: |
      Prefix for output files
    type: string?   # Use nameroot of bam_sorted if not specified
  # Key-word arguments
  # Common Options
  threads:
    label: threads
    doc: |
      Number of BAM decompression threads [default: 0]
    type: int?
  chrom:
    label: chrom
    doc: |
      Chromosome to restrict depth calculation.
    type: string?
    inputBinding:
      prefix: "--chrom"
  by:
    label: by
    doc: |
      Optional BED file or (integer) window-sizes.
    type:
      - "null"
      - File
      - string
    inputBinding:
      prefix: "--by"
  no_per_base:
    label: no per base
    doc: |
      Dont output per-base depth. skipping this output will speed execution substantially.
      Prefer quantized or thresholded values if possible.
    type: boolean?
    inputBinding:
      prefix: "--no-per-base"
  # Other options
  flag:
    label: flag
    doc: |
      Exclude reads with any of the bits in FLAG set [default: 1796]
    type: int?
    inputBinding:
      prefix: "--flag"
  include_flag:
    label: include flag
    doc: |
      Only include reads with any of the bits in FLAG set. default is unset. [default: 0]
    type: int?
    inputBinding:
      prefix: "--include-flag"
  fast_mode :
    label: fast mode
    doc: |
      Dont look at internal cigar operations or correct mate overlaps (recommended for most use-cases).
    type: boolean?
    inputBinding:
      prefix: "--fast-mode "
  quantize:
    label: quantize
    doc: |
      Write quantized output see docs for description.
    type: string?
    inputBinding:
      prefix: "--quantize"
  mapq:
    label: mapq
    doc: |
      Mapping quality threshold. reads with a quality less than this value are ignored [default: 0]
    type: int?
    inputBinding:
      prefix: "--mapq"
  thresholds:
    label: thresholds
    doc: |
      For each interval in --by, write number of bases covered by at least threshold bases.
      Specify multiple integer values separated by ','.
    type: int[]?
    inputBinding:
      prefix: "--thresholds"
      itemSeparator: ","
  use_median:
    label: use median
    doc: |
      Output median of each region (in --by) instead of mean.
    type: boolean?
    inputBinding:
      prefix: "--use-median"
  read_groups:
    label: read groups
    doc: |
      Only calculate depth for these comma-separated read groups IDs.
    type: string?
    inputBinding:
      prefix: "--read-groups"

outputs:
  global_dist_txt:
    label: dist txt
    doc: |
      Output Global Distributions
    type: File
    outputBinding:
      glob: "$(get_output_prefix()).mosdepth.global.dist.txt"
  region_dist:
    label: dist txt
    doc: |
      Output Region Distributions (if --by is specified)
    type: File?
    outputBinding:
      glob: "$(get_output_prefix()).mosdepth.region.dist.txt"
  summary_txt:
    label: summary txt
    doc: |
      Summary text file
    type: File
    outputBinding:
      glob: "$(get_output_prefix()).mosdepth.summary.txt"
  per_base_bed_gz:
    label: per base bed gz
    doc: |
      Per base bed gz file (unless -n/--no-per-base is specified)
    type: File?
    outputBinding:
      glob: "$(get_output_prefix()).per-base.bed.gz"
  regions_bed_gz:
    label: regions bed gz
    doc: |
      Regions bed gz file  (if --by is specified)
    type: File?
    outputBinding:
      glob: "$(get_output_prefix()).regions.bed.gz"
  quantized_bed_gz:
    label: per base bed gz
    doc: |
     Quantized bed gz file (if --quantize is specified)
    type: File?
    outputBinding:
      glob: "$(get_output_prefix()).quantized.bed.gz"
  thresholds_bed_gz:
    label: thresholds bed gz
    doc: |
      Compressed output bed file with thresholds provided (if --thresholds is specified)
    type: File?
    outputBinding:
      glob: "$(get_output_prefix()).thresholds.bed.gz"

successCodes:
  - 0
