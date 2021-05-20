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
id: get-faidx-file-from-reference-file--1.0.0
label: get-faidx-file-from-reference-file v(1.0.0)
doc: |
    Given a reference fasta file (with a fasta index as a secondary file),
    return the secondary file as an object

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_faidx_file_secondary_file_from_reference_fasta_file = function(input_reference_fasta){
          /*
          Get the faidx file
          */
          for (var i = 0; i < input_reference_fasta.secondaryFiles.length; i++){
            if (input_reference_fasta.secondaryFiles[i].basename === input_reference_fasta.basename + ".fai"){
              return input_reference_fasta.secondaryFiles[i];
            }
          }
          return null;
        }

inputs:
  reference_fasta:
    label: reference fasta file with faidx secondary file
    doc: |
      Standard .fa reference fasta file
    type: File
    secondaryFiles:
      - pattern: ".fai"
        required: true

outputs:
  faidx_file:
    label: fasta index file
    doc: |
      Created with samtools faidx, must match reference_fasta + ".fai"
    type: File

expression: >-
  ${
    return {"faidx_file": (get_faidx_file_secondary_file_from_reference_fasta_file(inputs.reference_fasta))};
  }