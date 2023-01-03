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
id: sambamba-slice-and-index--0.8.0
label: sambamba-slice-and-index v(0.8.0)
doc: |
  Slice a bam file (with a regions bed file for reference) and then index it.
  Uses sambamba slice command.
  More info can be found [here](https://lomereiter.github.io/sambamba/docs/sambamba-slice.html)

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
  InitialWorkDirRequirement:
    listing:
      - entryname: sambamba-slice-and-index.sh
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Run the sambamba slice command
          eval sambamba slice '"\${@}"'

          # Index the output file
          sambamba index "$(inputs.output_filename)"

baseCommand: ["bash", "sambamba-slice-and-index.sh"]

inputs:
  # All args are mandatory
  bam_sorted:
    label: bam sorted
    doc: |
      Sorted bam file for input for slicing command
    type: File
    secondaryFiles:
      - .bai
    inputBinding:
      position: 100
  output_filename:
    label: output filename
    doc: |
      Name of output bam
    type: string
    inputBinding:
      prefix: "--output-filename"
  regions_bed:
    label: regions bed
    doc: positions to subset
    type: File
    inputBinding:
      prefix: "--regions"


outputs:
  bam_indexed:
    label: output bam
    doc: |
      Output indexed bam file
    type: File
    outputBinding:
      glob: "$(inputs.output_filename)"
    secondaryFiles:
      - .bai

successCodes:
  - 0