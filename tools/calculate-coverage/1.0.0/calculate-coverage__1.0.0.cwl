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
id: calculate-coverage--1.0.0
label: calculate-coverage v(1.0.0)
doc: |
    Documentation for calculate-coverage v1.0.0
    https://github.com/c-BIG/wgs-sample-qc/tree/main/example_implementations/sg-npm 

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
      ilmn-tes:resources:
        tier: standard
        type: standardHiCpu
        size: medium
    DockerRequirement:
        dockerPull: quay.io/umccr/calculate-coverage:1.7

baseCommand: ["python"]

arguments: [$(inputs.script)]

inputs:
  script:
    label: script
    doc: |
      Path to PRECISE python script on GitHub
    type: File
    default:
      class: File
      location: https://raw.githubusercontent.com/c-BIG/wgs-sample-qc/main/example_implementations/sg-npm/calculate_coverage.py
  map_quality:
    label: map quality
    doc: |
      Mapping quality threshold. Default: 20.
    type: int?
    inputBinding:
      prefix: "--mapq"
  ref_seq:
    label: ref seq
    doc: |
      Path to genome fasta. Required when providing an input CRAM
    type: File?
    secondaryFiles:
      - pattern: ".fai"
        required: true
    inputBinding:
      prefix: "--ref-seq"
  sample_bam:
    label: sample bam
    doc: |
      Path to input BAM or CRAM
    type: File
    secondaryFiles:
      - pattern: ".bai"
        required: false
    streamable: true
    inputBinding:
      prefix: "--bam"
  target_regions:
    label: input bed
    doc: |
      Path to BED file to be used as a mask for metrics calculation. 
      Only regions in the provided BED will be considered.
    type: File?
    inputBinding:
      prefix: "--bed"
  out_directory:
    label: out directory
    doc: |
      Path to scratch directory. Default: ./
    type: Directory?
    inputBinding:
      prefix: "--scratch_dir"
  output_json:
    label: output json
    doc: |
      output file
    type: string
    inputBinding:
      prefix: "--out_json"
  log_level:
    label: log level
    doc: |
      Set logging level to INFO (default), WARNING or DEBUG.
    type: string?
    inputBinding:
      prefix: "--loglevel"

outputs:
  output_filename:
    label: output file
    doc: |
      JSON output file containing QC metrics
    type: File
    outputBinding:
      glob: "$(inputs.output_json)"

successCodes:
  - 0
