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
id: parse-samplesheet--2.0.0--4.0.3
label: parse-samplesheet v(2.0.0--4.0.3)
doc: |
    Parse either a samplesheet or a file as output

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/samplesheet/2.0.0--4.0.3/samplesheet__2.0.0--4.0.3.yaml

inputs:
  samplesheet:
    label: samplesheet
    doc: |
      The samplesheet of either type samplesheet or type file
    type:
      - ../../../schemas/samplesheet/2.0.0--4.0.3/samplesheet__2.0.0--4.0.3.yaml#samplesheet
      - File

outputs:
  samplesheet_out:
    label: samplesheet out
    doc: |
      The output samplesheet
    type:
      - ../../../schemas/samplesheet/2.0.0--4.0.3/samplesheet__2.0.0--4.0.3.yaml#samplesheet
      - File

expression: >-
  ${
    return {"samplesheet_out": inputs.samplesheet};
  }
