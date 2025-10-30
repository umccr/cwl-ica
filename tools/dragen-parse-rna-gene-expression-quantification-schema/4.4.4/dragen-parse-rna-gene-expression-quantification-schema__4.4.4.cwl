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
id: dragen-parse-rna-gene-expression-quantification-schema--4.4.4
label: dragen-parse-rna-gene-expression-quantification-schema v(4.4.4)
doc: |
  Documentation for dragen-parse-rna-gene-expression-quantification-schema v4.4.4

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
      - $import: ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.0/dragen-rna-gene-expression-quantification-options__4.4.0.yaml

# Will always return 0
baseCommand: ["true"]

inputs:
  rna_gene_expression_quantification_options_input:
    label: alignment options input
    doc: |
      Alignment options or null
    type: ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.0/dragen-rna-gene-expression-quantification-options__4.4.0.yaml#dragen-rna-gene-expression-quantification-options

outputs:
  rna_gene_expression_quantification_options_output:
    label: alignment options output
    doc: |
      Alignment options
    type:
      - "null"
      - ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.0/dragen-rna-gene-expression-quantification-options__4.4.0.yaml#dragen-rna-gene-expression-quantification-options
    outputBinding:
      outputEval: |
        ${
            return inputs.rna_gene_expression_quantification_options_input;
        }

successCodes:
  - 0
