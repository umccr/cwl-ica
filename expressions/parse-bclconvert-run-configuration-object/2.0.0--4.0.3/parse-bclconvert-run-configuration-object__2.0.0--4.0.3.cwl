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
id: parse-bclconvert-run-configuration-object--2.0.0--4.0.3
label: parse-bclconvert-run-configuration-object v(2.0.0--4.0.3)
doc: |
    Documentation for parse-bclconvert-run-configuration-object
    v2.0.0--4.0.3

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml

inputs:
  bclconvert_run_configuration:
    label: bclconvert run configuration
    doc: |
      The BCLConvert run configuration
    type: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml#bclconvert-run-configuration

outputs:
  bclconvert_run_configuration_out:
    label: bclconvert run configuration out
    doc: |
      The bclconvert run configuration output
    type: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml#bclconvert-run-configuration

expression: >-
  ${
    return {"bclconvert_run_configuration_out": inputs.bclconvert_run_configuration};
  }

