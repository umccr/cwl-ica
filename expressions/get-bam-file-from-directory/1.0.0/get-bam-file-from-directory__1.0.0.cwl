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
id: get-bam-file-from-directory--1.0.0
label: get-bam-file-from-directory v(1.0.0)
doc: |
    Collect a bam file from the top level of the directory.
    Also find its index file and append it as a secondary file

requirements:
  LoadListingRequirement:
    loadListing: shallow_listing
  InlineJavascriptRequirement:
    expressionLib:
      - var get_bam_file_from_directory = function(input_dir, bam_nameroot){
          /*
          Initialise the output file object
          */
          var output_bam_obj = null;

          /*
          Iterate through the file listing
          */
          for (var input_dir_iter=0; input_dir_iter < input_dir.listing.length; input_dir_iter++){
            /*
            Get the bam file
            */
            if (input_dir.listing[input_dir_iter].basename !== bam_nameroot + ".bam"){
              /*
              Not the bam file, skipping
              */
              continue;
            }
              output_bam_obj = input_dir.listing[input_dir_iter];
          }

          /*
          Check input has been defined
          */
          if (output_bam_obj === null){
            throw new Error("Could not find bam file in directory");
          }

          /*
          Now iterate again and pick up the secondary files attribute
          */
          for (var input_dir_iter=0; input_dir_iter < input_dir.listing.length; input_dir_iter++){
            /*
            Get the bam file
            */
            if (input_dir.listing[input_dir_iter].basename !== bam_nameroot + ".bam.bai"){
              /*
              Not the bam index file, skipping
              */
              continue;
            }

            /*
            Append the index file object as a secondary file attribute
            */
            output_bam_obj["secondaryFiles"] = [input_dir.listing[input_dir_iter]];
            break;
          }

          /*
          Were done here
          */
          return output_bam_obj;
        }

inputs:
  input_dir:
    label: input dir
    doc: |
      Input directory with the bam file present
    type: Directory
  bam_nameroot:
    label: bam nameroot
    doc: |
      nameroot of the bam file
    type: string

outputs:
  bam_file:
    label: bam file
    doc: |
      The bam file output with the .bai attribute
    type: File
    secondaryFiles:
      - pattern: ".bai"
        required: true

expression: >-
  ${
    return {"bam_file": get_bam_file_from_directory(inputs.input_dir, inputs.bam_nameroot)};
  }
