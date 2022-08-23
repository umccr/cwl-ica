cwlVersion: v1.1
class: ExpressionTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: http://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: assert-true--1.0.0
label: assert-true v(1.0.0)
doc: |
    Documentation for assert-true v1.0.0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var assert_true = function(bool_val){
          if (bool_val === true){
            return true;
          } else {
            /*
            Throw an error
            */
            throw new Error("At least one sample failed");
            return null;
          }
        }

inputs:
  boolean_val:
    label: boolean value
    doc: |
      A boolean value we wish to assert as true
    type: boolean


outputs:
  assertion:
    label: assertion
    doc: |
      Boolean value showing assertion was true
    type: boolean

expression: >- 
  ${
    return { 
      "assertion": assert_true(inputs.boolean_val)
    };
  }
