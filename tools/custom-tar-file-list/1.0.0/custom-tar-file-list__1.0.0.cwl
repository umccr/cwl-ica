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
id: custom-tar-file-list--1.0.0
label: custom-tar-file-list v(1.0.0)
doc: |
    Tar an array of files, uses compression and strictly no "tar bomb". Files are placed under dir name
    with the output file being 'dir name.tar.gz'

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: xlarge
        coresMin: 4
        ramMin: 14000
    DockerRequirement:
        dockerPull: bash:5.1.12-alpine3.14


requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: run_tar.sh
        entry: |
          #!/usr/bin/env bash

          # Using shell since bash is not present in alpine
          # Set up to fail
          set -euo pipefail

          # Create output directory
          mkdir "$(inputs.dir_name)"

          # Symlink all files into the input directory
          input_file_path_array=( $(inputs.file_list.map(function(a) {return '"' + a.path + '"';}).join(' ')) )

          # Iterate through input files and symlink into directory
          for input_file_path in "\${input_file_path_array[@]}"; do
            ln -s "\${input_file_path}" "$(inputs.dir_name)/"
          done

          # Tar up everything
          tar -h -czf "$(inputs.dir_name).tar.gz" "$(inputs.dir_name)"

          # Now unlink everything - otherwise ICA tries to upload them onto gds (and fails)
          for input_file_path in "\${input_file_path_array[@]}"; do
            unlink "$(inputs.dir_name)/\$(basename \${input_file_path})"
          done

          # Then delete the directory for safe measure
          rm -r "$(inputs.dir_name)/"

baseCommand: [ "bash", "run_tar.sh" ]

inputs:
  dir_name:
    label: dir name
    doc: |
      The directory name all files will be placed in
    type: string
  file_list:
    label: file list
    doc: |
      List of files to be placed in the directory
    type: File[]


outputs:
  output_compressed_tar_file:
    label: output compressed tar file
    doc: |
      The compressed output tar file
    type: File
    outputBinding:
      glob: "$(inputs.dir_name).tar.gz"


successCodes:
  - 0

