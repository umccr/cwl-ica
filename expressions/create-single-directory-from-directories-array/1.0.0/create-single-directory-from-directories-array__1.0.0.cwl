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
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

requirements:
  InlineJavascriptRequirement: {}

# ID/Docs
id: create-single-directory-from-directories-array--1.0.0
label: create-single-directory-from-directories-array v(1.0.0)
doc: |
    Takes an array of files Directories and return a single Directory object with everything in “listing”. 
    The runner will stage those files to the new Directory. 

inputs:
  input_directories:
    label: input directories
    doc: |
      The input directories
    type: Directory[]
  output_directory_name:
    label: output directory name
    doc: |
      The name of output directory
    type: string?
    default: "single_directory"

outputs:
  output_directory:
    label: output directory
    doc: |
      The output directory
    type: Directory

expression: |
  ${
  return {"output_directory": {"class": "Directory", "basename": inputs.output_directory_name, "listing": inputs.input_directories}};
  }
