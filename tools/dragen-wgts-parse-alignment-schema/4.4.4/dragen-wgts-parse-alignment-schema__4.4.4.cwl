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
id: dragen-wgts-parse-alignment-schema--4.4.4
label: dragen-wgts-parse-alignment-schema v(4.4.4)
doc: |
  Documentation for dragen-wgts-parse-alignment-schema v4.4.4

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: standard
    ilmn-tes:resources/size: small
    coresMin: 2
    ramMin: 4000
  DockerRequirement:
    dockerPull: alpine:latest

requirements:
  InlineJavascriptRequirement: { }
  SchemaDefRequirement:
    types:
      # Nested schemas
      - $import: ../../../schemas/dragen-aligner-options/4.4.4/dragen-aligner-options__4.4.4.yaml
      - $import: ../../../schemas/dragen-mapper-options/4.4.4/dragen-mapper-options__4.4.4.yaml

      # I/O schemas
      - $import: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml

# Will always return 0
baseCommand: [ "true" ]

inputs:
  dragen_wgts_alignment_options:
    label: dragen wgts alignment options
    doc: |
      Alignment options or null
    type: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml#dragen-wgts-alignment-options

outputs:
  dragen_wgts_alignment_options_output:
    label: dragen wgts alignment options output
    doc: |
      Dragen wgts alignment options output
    type: ../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4.yaml#dragen-wgts-alignment-options
    outputBinding:
      outputEval: |
        ${
            return inputs.dragen_wgts_alignment_options;
        }

successCodes:
  - 0
