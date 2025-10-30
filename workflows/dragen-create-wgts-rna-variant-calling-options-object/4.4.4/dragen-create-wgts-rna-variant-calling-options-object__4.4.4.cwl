cwlVersion: v1.2
class: Workflow

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
id: dragen-create-wgts-rna-variant-calling-options-object--4.4.4
label: dragen-create-wgts-rna-variant-calling-options-object v(4.4.4)
doc: |
    Documentation for dragen-create-wgts-rna-variant-calling-
    options-object v4.4.4

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SchemaDefRequirement:
      types:
        # Data inputs
        - $import: ../../../schemas/dragen-snv-variant-caller-options/4.4.0/dragen-snv-variant-caller-options__4.4.0.yaml
        - $import: ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.0/dragen-rna-gene-expression-quantification-options__4.4.0.yaml


inputs:
  snv_variant_caller_options:
    label: dragen-snv-variant-caller-options
    doc: |
      dragen-snv-variant-caller-options
    type: ../../../schemas/dragen-snv-variant-caller-options/4.4.0/dragen-snv-variant-caller-options__4.4.0.yaml#dragen-snv-variant-caller-options
  rna_gene_expression_quantification_options:
    label: dragen-rna-gene-expression-quantification-options
    doc: |
      dragen-rna-gene-expression-quantification-options
    type: ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.0/dragen-rna-gene-expression-quantification-options__4.4.0.yaml#dragen-rna-gene-expression-quantification-options

steps:
  parse_snv_variant_caller_options:
    in:
      snv_variant_caller_options_input: snv_variant_caller_options
    out:
      - id: snv_variant_caller_options_output
    run: ../../../expressions/dragen-parse-snv-variant-caller-schema/4.4.0/dragen-parse-snv-variant-caller-schema__4.4.0.cwl
  parse_rna_gene_expression_quantification_options:
    in:
      rna_gene_expression_quantification_options_input: rna_gene_expression_quantification_options
    out:
      - id: rna_gene_expression_quantification_options_output
    run: ../../../expressions/dragen-parse-rna-gene-expression-quantification-schema/4.4.0/dragen-parse-rna-gene-expression-quantification-schema__4.4.0.cwl

outputs:
  snv_variant_caller_options_output:
    label: snv_variant_caller_options_output
    doc: |
      snv_variant_caller_options_output
    outputSource: parse_snv_variant_caller_options/snv_variant_caller_options_output
    type: ../../../schemas/dragen-snv-variant-caller-options/4.4.0/dragen-snv-variant-caller-options__4.4.0.yaml#dragen-snv-variant-caller-options
  rna_gene_expression_quantification_options_output:
    label: rna_gene_expression_quantification_options_output
    doc: |
      rna_gene_expression_quantification_output
    outputSource: parse_rna_gene_expression_quantification_options/rna_gene_expression_quantification_options_output
    type: ../../../schemas/dragen-rna-gene-expression-quantification-options/4.4.0/dragen-rna-gene-expression-quantification-options__4.4.0.yaml#dragen-rna-gene-expression-quantification-options

