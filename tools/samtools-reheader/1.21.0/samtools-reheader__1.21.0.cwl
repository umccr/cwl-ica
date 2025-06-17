cwlVersion: v1.2
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
id: samtools-reheader--1.21.0
label: samtools-reheader v(1.21.0)
doc: |
    Documentation for samtools-reheader v1.21.0

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: large
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: public.ecr.aws/biocontainers/samtools:1.21--h50ea8bc_0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_output_filename = function(){
          /*
          Abstract script path, can then be referenced in baseCommand attribute too
          Makes things more readable.
          */
          return inputs.alignment_file.nameroot + ".reheader" + inputs.alignment_file.nameext;
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: run-reheader.sh
        entry: |
          #!/usr/bin/env bash

          # Set to fail
          set -euo pipefail

          # Vars

          # Reheader
          samtools reheader "$@" > "$(runtime.outdir)/$(get_output_filename())"

          # Index
          samtools index "$(runtime.outdir)/$(get_output_filename())"


baseCommand: [ "bash", "run-reheader.sh" ]

inputs:
  alignment_file:
    type: File
    inputBinding:
      position: 100  # After all keyword arguments
    doc: |
      The alignment file to reheader, either in SAM, BAM or CRAM format.
    secondaryFiles:
      # Either .bam or .cram format, will fail if at least one is not provided
      - pattern: .bai
        required: false
      - pattern: .crai
        required: false
  # --in-place option not supported here as we don't know if the original path is writable
  no_pg:
    type: boolean
    inputBinding:
      position: 1
      prefix: --no-PG
    doc: |
      Do not add a PG (program tag) line to the header.
  command:
    type: string
    inputBinding:
      position: 2
    doc: |
      The command to execute.
      Looks something like "perl -pe 's%(@RG.*SM:)NA%\1L1234%'" for example.
      This would replace SM:NA with SM:L1234 in the read group header.

outputs:
  output_alignment_file:
    type: File
    outputBinding:
      glob: |
        ${
          return get_output_filename();
        }
    secondaryFiles:
      # Either .bam or .cram format, will fail if at least one is not provided
      - pattern: .bai
        required: false
      - pattern: .crai
        required: false

successCodes:
  - 0
