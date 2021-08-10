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
id: get-compresed-vcf-file-from-directory--1.0.0
label: get-compresed-vcf-file-from-directory v(1.0.0)
doc: |
    Collect a bgzipped vcf file from the top level of a directory.
    Also collect the respective vcf index file.

requirements:
  LoadListingRequirement:
    loadListing: shallow_listing
  InlineJavascriptRequirement:
    expressionLib:
      - var get_compressed_vcf_file_from_directory = function(input_dir, vcf_nameroot){
          /*
          Initialise the output file object
          */
          var output_compressed_vcf_obj = null;

          /*
          Iterate through the file listing
          */
          for (var input_dir_iter=0; input_dir_iter < input_dir.listing.length; input_dir_iter++){
            /*
            Get the vcf file
            */
            if (input_dir.listing[input_dir_iter].basename !== vcf_nameroot + ".vcf.gz"){
              /*
              Not the vcf file, skipping
              */
              continue;
            }
              output_compressed_vcf_obj = input_dir.listing[input_dir_iter];
          }

          /*
          Check input has been defined
          */
          if (output_compressed_vcf_obj === null){
            throw new Error("Could not find vcf file in directory");
          }

          /*
          Now iterate again and pick up the secondary files attribute
          */
          for (var input_dir_iter=0; input_dir_iter < input_dir.listing.length; input_dir_iter++){
            /*
            Get the vcf file
            */
            if (input_dir.listing[input_dir_iter].basename !== vcf_nameroot + ".vcf.gz.tbi"){
              /*
              Not the vcf index file, skipping
              */
              continue;
            }

            /*
            Append the index file object as a secondary file attribute
            */
            output_compressed_vcf_obj.setAttribute("secondaryFiles", input_dir.listing[input_dir_iter]);
            break;
          }

          /*
          Were done here
          */
          return output_compressed_vcf_obj;
        }

inputs:
  input_dir:
    label: input dir
    doc: |
      Input directory with the vcf file present
    type: Directory
  vcf_nameroot:
    label: vcf nameroot
    doc: |
      nameroot of the vcf file (excludes .vcf.gz)
    type: string

outputs:
  compressed_vcf_file:
    label: compressed vcf file
    doc: |
      The compressed file output with the .tbi attribute
    type: File
    secondaryFiles:
      - pattern: ".tbi"
        required: true

expression: >-
  ${
    return {"compressed_vcf_file": get_compressed_vcf_file_from_directory(inputs.input_dir, inputs.vcf_nameroot)};
  }
