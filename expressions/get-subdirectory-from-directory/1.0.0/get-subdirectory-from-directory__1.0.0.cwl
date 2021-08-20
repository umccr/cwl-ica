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
id: get-subdirectory-from-directory--1.0.0
label: get-subdirectory-from-directory v(1.0.0)
doc: |
    Collect a subdirectory (and contents) from a directory

requirements:
  LoadListingRequirement:
    loadListing: deep_listing
  InlineJavascriptRequirement:
    expressionLib:
      - var get_sub_dir_obj_from_directory = function(input_dir, directory_basename){
          /*
          Iterate through listing of input directory
          Get the directory object that basename attribute matches
          */

          /*
          Initialise output object
          */
          var output_dir_obj = null;

          /*
          Iterate through listing
          */
          for (var input_dir_iter=0; input_dir_iter < input_dir.listing.length; input_dir_iter++){
            /*
            Check match, append and break if match exists
            */
            if (input_dir.listing[input_dir_iter].basename === directory_basename){
              /*
              This is a match, append to outputs
              */
              output_dir_obj = input_dir.listing[input_dir_iter];
              break;
            }
          }

          return output_dir_obj;
        }

inputs:
  input_dir:
    label: input dir
    doc: |
      Input directory with the directory present
    type: Directory
  sub_directory_basename:
    label: sub-directory basename
    doc: |
      The name of the sub directory
    type: string

outputs:
  output_directory:
    label: output directory
    doc: |
      Output directory extracted from directory
    type: Directory

expression: >-
  ${
    return {"output_directory": get_sub_dir_obj_from_directory(inputs.input_dir, inputs.sub_directory_basename)};
  }
