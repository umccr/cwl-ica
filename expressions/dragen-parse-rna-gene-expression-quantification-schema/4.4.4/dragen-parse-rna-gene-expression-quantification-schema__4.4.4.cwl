cwlVersion: v1.2
class: ExpressionTool

# Extensions
$namespaces:
    s: https://schema.org/
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
    Documentation for dragen-parse-rna-gene-expression-
    quantification-schema v4.4.4

# Requirements
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.4/dragen-rna-gene-expression-quantification-options__4.4.4.yaml

# Inputs / Outputs
inputs:
  rna_gene_expression_quantification_options_input:
    label: rna gene expression quantification options input
    doc: |
      Alignment options or null
    type: ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.4/dragen-rna-gene-expression-quantification-options__4.4.4.yaml#dragen-rna-gene-expression-quantification-options

outputs:
  rna_gene_expression_quantification_options_output:
    label: rna gene expression quantification options output
    doc: |
      Alignment options
    type:
      - "null"
      - ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.4/dragen-rna-gene-expression-quantification-options__4.4.4.yaml#dragen-rna-gene-expression-quantification-options


expression: |
  ${
    return {
      "rna_gene_expression_quantification_options_output": inputs.rna_gene_expression_quantification_options_input
    };
  }