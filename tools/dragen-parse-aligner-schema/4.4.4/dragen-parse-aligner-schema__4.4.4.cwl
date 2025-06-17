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
id: dragen-parse-aligner-schema--4.4.4
label: dragen-parse-aligner-schema v(4.4.4)
doc: |
    Documentation for dragen-parse-aligner-schema v4.4.4

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
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/dragen-aligner-options/4.4.4/dragen-aligner-options__4.4.4.yaml

# Will always return 0
baseCommand: ["true"]

inputs:
  aligner_options_input:
    label: alignment options input
    doc: |
      Alignment options or null
    type: ../../../schemas/dragen-aligner-options/4.4.4/dragen-aligner-options__4.4.4.yaml#dragen-aligner-options

outputs:
  aligner_options_output:
    label: alignment options output
    doc: |
      Alignment options
    type: ../../../schemas/dragen-aligner-options/4.4.4/dragen-aligner-options__4.4.4.yaml#dragen-aligner-options
    outputBinding:
      outputEval: |
        ${
            return inputs.aligner_options_input;
        }

successCodes:
  - 0
