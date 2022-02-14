cwlVersion: v1.1
class: CommandLineTool

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
id: custom-gzip-file--1.0.0
label: custom-gzip-file v(1.0.0)
doc: |
    Compress a file with gzip. Output is the same name as the file but with '.gz' suffix

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/ICA_CLI/Content/SW/ICA/IAPWES_RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: xlarge
        coresMin: 4
        ramMin: 14000
    DockerRequirement:
        dockerPull: bash:5.1.12-alpine3.14

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: "run_gzip.sh"
        entry: |
          #!/usr/bin/env bash

          # Set to fail
          set -euo pipefail

          # Copy decompressed file over
          cp "$(inputs.uncompressed_file.path)" "$(inputs.uncompressed_file.basename)"

          # Run gzip
          eval gzip '"\${@}"'


baseCommand: [ "bash", "run_gzip.sh" ]

inputs:
  uncompressed_file:
    label: uncompressed file
    doc: |
      Compressed file
    type: File
    inputBinding:
      position: 100
      valueFrom: |
        ${
          return self.basename;
        }
  compression_level:
    label: compression level
    doc: |
      Set the compression level
    type: int?
    inputBinding:
      prefix: "-"
      separate: false
      valueFrom: "$(self.toString())"


outputs:
  compressed_out_file:
    label: compressed out file
    doc: |
      The compressed output file
    type: File
    outputBinding:
      glob: "$(inputs.uncompressed_file.basename).gz"

successCodes:
  - 0
