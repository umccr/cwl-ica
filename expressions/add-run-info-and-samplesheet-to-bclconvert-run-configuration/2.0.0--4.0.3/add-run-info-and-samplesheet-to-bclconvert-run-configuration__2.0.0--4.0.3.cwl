cwlVersion: v1.1
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
id: add-run-info-and-samplesheet-to-bclconvert-run-configuration--2.0.0--4.0.3
label: add-run-info-and-samplesheet-to-bclconvert-run-configuration v(2.0.0--4.0.3)
doc: |
    Documentation for add-run-info-and-samplesheet-to-
    bclconvert-run-configuration v2.0.0--4.0.3

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/bclconvert-run-configuration-expressions/2.0.0--4.0.3/bclconvert-run-configuration-expressions__2.0.0--4.0.3.cwljs

inputs:
  bclconvert_run_configuration:
    label: bclconvert run configuration
    doc: |
      BCLConvert run configuration object
    type: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml#bclconvert-run-configuration
  run_info:
    label: run info
    doc: |
      Run info file to add to bclconvert run configuration object
    type: File
  samplesheet:
    label: samplesheet
    doc: |
      Samplesheet object to add to bclconvert run configuration object
    type: File

outputs:
  bclconvert_run_configuration_out:
    label: bclconvert run configuration out
    doc: |
      BCLConvert run configuration object with output run info file
    type: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml#bclconvert-run-configuration

expression: >-
  ${
    return {"bclconvert_run_configuration_out": add_run_info_and_samplesheet_to_bclconvert_run_configuration(inputs.bclconvert_run_configuration, inputs.run_info, inputs.samplesheet)};
  }
