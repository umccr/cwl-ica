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
id: get-files-from-directory--1.0.0
label: get-files-from-directory v(1.0.0)
doc: |
    Given an array of strings, collect the matching files from the top level of a directory

requirements:
  LoadListingRequirement:
    loadListing: shallow_listing
  InlineJavascriptRequirement:
    expressionLib:
      - var get_file_objs_from_directory = function(input_dir, file_basename_list){
          /*
          Iterate through list of file basenames
          Iterate through listing of input directory
          Collect and append each file (if it exists) to the output array
          */

          /*
          Initialise array
          */
          var output_file_objs = [];

          /*
          Iterate through basenames
          */
          for (var file_basename_iter=0; file_basename_iter < file_basename_list.length; file_basename_iter++){
            /*
            Iterate through listing
            */
            for (var input_dir_iter=0; input_dir_iter < input_dir.listing.length; input_dir_iter++){
              /*
              Check match, append and break if match exists
              */
              if (input_dir.listing[input_dir_iter].basename === file_basename_list[file_basename_iter]){
                /*
                This is a match, append to outputs
                */
                output_file_objs.push(input_dir.listing[input_dir_iter]);
                break;
              }
            }
            /*
            If we get to here, then this file was not in the listing, ignore for now
            */
          }
          return output_file_objs;
        }

inputs:
  input_dir:
    label: input dir
    doc: |
      Input directory with the file present
    type: Directory
  file_basename_list:
    label: file basename list
    doc: |
      List of the file names we wish to extract from the directory
    type: string[]

outputs:
  output_files:
    label: output files
    doc: |
      List of files extracted from the directory
    type: File[]

expression: >-
  ${
    return {"output_files": get_file_objs_from_directory(inputs.input_dir, inputs.file_basename_list)};
  }
