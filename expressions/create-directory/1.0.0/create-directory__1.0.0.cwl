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
id: create-directory--1.0.0
label: create-directory v(1.0.0)
doc: |
    Documentation for create-directory v1.0.0

requirements:
  InlineJavascriptRequirement: {}
  LoadListingRequirement:
    loadListing: deep_listing

# Inputs and outputs
inputs:
  input_files:
    label: input files
    doc: |
      List of input files to go into the output directory
    type: File[]?
  input_directories:
    label: input directories
    doc: |
      List of input directories to go into the output directory
    type: Directory[]?
  output_directory_name:
    label: output directory name
    doc: |
      The name of the output directory
    type: string

outputs:
  output_directory:
    label: output directory
    doc: |
      The output directory with all of the outputs collected
    type: Directory

expression: |
  ${
    /*
    Generate output listing
    */

    /* Initiate the listing */
    var listing = [];

    /* Add the input files */
    if (inputs.input_files !== null) {
      for (var i=0; i < inputs.input_files.length; i++) {
        listing.push(inputs.input_files[i]);
      }
    }

    /* Add the input directories */
    if (inputs.input_directories !== null) {
      for (var i=0; i < inputs.input_directories.length; i++) {
        listing.push(inputs.input_directories[i]);
      }
    }

    /* Add the output directory */
    return {
      "output_directory": {
        "class": "Directory",
        "basename": inputs.output_directory_name,
        "listing": listing
      }
    };
  }
