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
id: get-file-from-directory--1.0.0
label: get-file-from-directory v(1.0.0)
doc: |
    Collect a file from a directory

requirements:
  LoadListingRequirement:
    loadListing: shallow_listing
  InlineJavascriptRequirement:
    expressionLib:
      - var get_file_obj_from_directory = function(input_dir, file_basename_regex){
          /*
          Iterate through listing of input directory
          Get the file object that basename attribute matches file_basename_regex input param
          */

          /*
          Initialise output object
          */
          var output_file_obj = null;

          /*
          Iterate through listing
          */
          for (var input_dir_iter=0; input_dir_iter < input_dir.listing.length; input_dir_iter++){
            /*
            Check match, append and break if match exists
            */
            if (input_dir.listing[input_dir_iter].basename.match(file_basename_regex) !== null ){
              /*
              This is a match, append to outputs
              */
              output_file_obj = input_dir.listing[input_dir_iter];
              break;
            }
          }

          return output_file_obj;
        }

inputs:
  input_dir:
    label: input dir
    doc: |
      Input directory with the file present
    type: Directory
  file_basename_regex:
    label: file basename regex
    doc: |
      The basename regex of the file we wish to extract from the directory
    type: string

outputs:
  output_file:
    label: output file
    doc: |
      File extracted from the directory
    type: File

expression: >-
  ${
    return {"output_file": get_file_obj_from_directory(inputs.input_dir, inputs.file_basename_regex)};
  }
