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
id: custom-tar-vcf-file-list--1.0.0
label: custom-tar-vcf-file-list v(1.0.0)
doc: |
    Tar a list of files

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
        dockerPull: frolvlad/alpine-bash:latest


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

          # Symlink all vcf files into the input directory
          input_vcf_file_path_array=( $(inputs.vcf_file_list.map(function(a) {return '"' + a.path + '"';}).join(' ')) )
          
          # Symlink all vcf index files into the input directory
          input_vcf_index_file_path_array=( $(inputs.vcf_file_list.map(function(a) {return '"' + a.secondaryFiles[0].path + '"';}).join(' ')) )

          input_vcf_index_file_path_array=( $(inputs.vcf_file_list.map(function(a) {return '"' + a.path + '.tbi' + '"';}).join(' ')) )

          # Iterate through input vcf files and symlink into directory
          for input_vcf_file_path in "\${input_vcf_file_path_array[@]}"; do
            ln -s "\${input_vcf_file_path}" "$(inputs.dir_name)/"
          done

          # Iterate through input vcf index files and symlink into directory
          for input_vcf_file_path_index in "\${input_vcf_index_file_path_array[@]}"; do
            ln -s "\${input_vcf_file_path_index}" "$(inputs.dir_name)/"
          done

          # Now build the tar ball
          tar -h -czf "$(inputs.dir_name).tar.gz" "$(inputs.dir_name)"

          # Now unlink everything - otherwise ICA tries to upload them onto gds (and fails)
          for input_vcf_file_path in "\${input_vcf_file_path_array[@]}"; do
            unlink "$(inputs.dir_name)/\$(basename \${input_vcf_file_path})"
          done

          # Iterate through input vcf index files and symlink into directory
          for input_vcf_file_path_index in "\${input_vcf_index_file_path_array[@]}"; do
            unlink "$(inputs.dir_name)/\$(basename \${input_vcf_file_path_index})"
          done

          # Then delete the input directory for safe measure
          rm -r "$(inputs.dir_name)/"

baseCommand: [ "bash", "run_tar.sh" ]

inputs:
  dir_name:
    label: dir name
    doc: |
      The directory name all files will be placed in
    type: string
  vcf_file_list:
    label: file list
    doc: |
      List of files to be placed in the directory
    type: File[]
    secondaryFiles:
      - pattern: ".tbi"
        required: true

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

