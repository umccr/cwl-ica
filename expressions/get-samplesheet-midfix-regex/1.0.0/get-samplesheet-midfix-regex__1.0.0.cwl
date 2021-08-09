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
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: get-samplesheet-midfix-regex--1.0.0
label: get-samplesheet-midfix-regex v(1.0.0)
doc: |
    Documentation for get-samplesheet-midfix-regex v1.0.0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_batch_name_from_samplesheet = function(samplesheet_basename) {
          /*
          Get everything between SampleSheet and csv
          https://regex101.com/r/KlF7LW/1
          */
          var samplesheet_regex = /SampleSheet\.(\S+)\.csv/g;
          return samplesheet_regex.exec(samplesheet_basename)[1];
        }
      - var get_batch_names = function(file_objs) {
          /*
          For each file object extract the midfix
          */

          /*
          Initialise batch names
          */
          var batch_names = [];

          for (var i = 0; i < file_objs.length; i++){
              /*
              But of that basename, get the midfix
              */
              batch_names.push(get_batch_name_from_samplesheet(file_objs[i].basename));
          }

          return batch_names;
        }

inputs: 
  samplesheets:
    label: sample sheets
    doc: |
      Input samplesheet to extract midfix from
    type: File[]

outputs:
  batch_names:
    label: output batch names
    doc: |
      List of output batch names
    type: string[]

expression: >-
  ${
    return {"batch_names": get_batch_names(inputs.samplesheets)};
  }

