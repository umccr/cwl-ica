cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: https://platform.illumina.com/rdf/ica/
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

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: standard
    ilmn-tes:resources/size: small
    coresMin: 2
    ramMin: 4000
  DockerRequirement:
    dockerPull: alpine:latest


baseCommand: ["true"]


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

outputs:
  output_file:
    label: output file
    doc: |
      File extracted from the directory
    type: File
    outputBinding:
      outputEval: |
        ${
            return get_file_from_directory(inputs.input_dir, inputs.file_basename);
        }

successCodes:
  - 0
