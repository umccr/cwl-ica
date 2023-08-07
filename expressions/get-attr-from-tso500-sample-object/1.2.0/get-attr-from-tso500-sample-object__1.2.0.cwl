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
id: get-attr-from-tso500-sample-object--1.2.0
label: get-attr-from-tso500-sample-object v(1.2.0)
doc: |
    Documentation for get-attr-from-tso500-sample-object v1.2.0

# Requirements
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/tso500-sample/1.2.0/tso500-sample__1.2.0.yaml

inputs:
  tso500_sample_object:
    label: tso500 sample object
    doc: |
      TSO500 sample object
    type: ../../../schemas/tso500-sample/1.2.0/tso500-sample__1.2.0.yaml#tso500-sample
  attribute_name:
    label: name of the attribute
    doc: |
      TSO500 sample object
    type: string

outputs:
  attribute_value:
    label: attribute value
    doc: |
      Value of the attribute
    type: string

expression: >-
  ${
    var attribute_value = null;
    for (var key in inputs.tso500_sample_object){
      if (key === inputs.attribute_name){
        attribute_value = inputs.tso500_sample_object[key];
      }
    }
    return {"attribute_value": attribute_value};
  }
