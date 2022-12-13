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
id: get-file-from-directory--1.0.1
label: get-file-from-directory v(1.0.1)
doc: |
    Documentation for get-file-from-directory v1.0.1

requirements:
  LoadListingRequirement:
    loadListing: shallow_listing
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/get-file-from-directory/1.0.0/get-file-from-directory__1.0.0.cwljs

inputs:
  input_dir:
    label: input dir
    doc: |
      Input directory with the file present
    type: Directory
  file_basename:
    label: file basename
    doc: |
      The basename of the file we wish to extract from the directory
    type: string
  listing_level:
    label: listing level
    doc: |
      The listing level of the file we wish to extract from the directory
    type:
      - type: enum
        symbols:
          - shallow_listing
          - deep_listing
    default: shallow_listing

outputs:
  output_file:
    label: output file
    doc: |
      File extracted from the directory
    type: File

expression: >-
  ${
    var recursive_listing = false;
    if ( inputs.listing_level === "deep_listing" ){
      recursive_listing = true;
    }
    return {"output_file": get_file_from_directory(inputs.input_dir, inputs.file_basename, recursive_listing)};
  }
