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
id: validate-dsdm-json--1.0.0
label: validate-dsdm-json v(1.0.0)
doc: |
    Look through the dsdm json and ensure that no sample has any steps in
    the executedAndFailed section

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var check_sample_steps = function(dsdm_json) {
          /*
          Samples failed execution
          */
          var sample_statuses = [];
          dsdm_json.samples.forEach(
            function(sample_object){
              /*
              dsdm json sample objects have the following keys
                didNotExecute
                executedAndFailed
                executedAndPassed
                identifier
                qualified
                stepsToRun
              */
              if (sample_object.executedAndFailed.length === 0){
                sample_statuses.push(true);
              } else {
                sample_statuses.push(false);
              }
            }
          );
          
          /*
          Ensure all elements in the array are true
          */
          for (var i=0; i < sample_statuses.length; i++){
            if ( sample_statuses[i] === false){
              return false;
            }
          }
          return true;
        }

inputs:
  dsdm_json:
    label: dsdm json
    doc: |
      dsdm json file
    type: File
    loadContents: true

outputs:
  passing:
    label: passing
    doc: |
      Return boolean of if all steps passing for all samples
    type: boolean

expression: >-
  ${
    return { 
      "passing": check_sample_steps(JSON.parse(inputs.dsdm_json.contents))
    }
  }
