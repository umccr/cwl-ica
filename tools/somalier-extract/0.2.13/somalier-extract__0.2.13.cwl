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
id: somalier-extract--0.2.13
label: somalier-extract v(0.2.13)
doc: |
    Extract informative sites, evaluate relatedness,
    and perform quality-control on BAM/CRAM/BCF/VCF/GVCF

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
        dockerPull: brentp/somalier:latest

requirements:
  InlineJavascriptRequirement: {}

baseCommand: ["somalier", "extract"]

inputs:
  bam_sorted:
    label: input bam
    doc: |
      Input and sorted bam file
    type: File
    streamable: true
    secondaryFiles:
      - pattern: ".bai"
        required: true
    inputBinding:
      # Positional argument after all other files
      position: 100
  output_directory_name:
    label: somalier output directory
    doc: |
      Output directory for somalier files
    type: string
    inputBinding:
      prefix: "--out-dir"
  sites:
    label: sites
    doc: |
      compressed (gzip) vcf with a list of known sites to analyse
    type: File
    secondaryFiles:
      - pattern: ".tbi"
        required: true
    inputBinding:
      prefix: "--sites"
  reference:
    label: reference
    doc: |
      Reference fasta file
    type: File
    secondaryFiles:
      - pattern: ".fai"
        required: true
    inputBinding:
      prefix: "--fasta"
  sample_prefix:
    label: sample prefix
    doc: |
      prefix for each output file in the output directory
    type: string
    inputBinding:
      prefix: "--sample-prefix"

outputs:
  output_directory:
    label: output directory
    doc: |
      Output directory for somalier extract command
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory_name)"

successCodes:
  - 0
