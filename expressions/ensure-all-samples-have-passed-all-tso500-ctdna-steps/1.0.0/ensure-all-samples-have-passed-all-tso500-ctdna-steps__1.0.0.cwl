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
id: ensure-all-samples-have-passed-all-tso500-ctdna-steps--1.0.0
label: ensure-all-samples-have-passed-all-tso500-ctdna-steps v(1.0.0)
doc: |
    Documentation for ensure-all-samples-have-passed-all-
    tso500-ctdna-steps v1.0.0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var all_passing = function(sample_statuses){
          /*
          Ensure all elements of the array are true
          */
          for (var i=0; i < sample_statuses.length; i++){
            if ( sample_statuses[i] === false){
              /*
              Throw an error
              */
              throw new Error("At least one sample failed");
              return null
            }
          }
          return true;
        }

inputs:
  samples_statuses:
    label: sample statuses
    doc: |
      Array of booleans, ensure all samples are passing
    type: boolean[]

outputs:
  all_passing:
    label: all_passing
    type: boolean

expression: >-
  ${
    return {
      "passing": all_passing(inputs.samples_statuses)
    }
  }
