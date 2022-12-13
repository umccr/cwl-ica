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
id: custom-create-umccr-dragen-refdata-tarball-from-illumina-tar--1.0.0
label: custom-create-umccr-dragen-refdata-tarball-from-illumina-tar v(1.0.0)
doc: |
    The Illumina Reference tarballs for the reference genome are currently tarbombs
    (multiple files and directories exist in the top directory), rather than a single directory that matches the nameroot of the directory.
    We also need to make sure that the reference name in the directory exists for Variant Interpreter to know which reference was used.

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: small
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: public.ecr.aws/docker/library/alpine:latest

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: "tar-reference-genome.sh"
        entry: |
          #!/usr/bin/env sh

          set -euo pipefail

          # Create the output directory
          echo "Creating the output directory" 1>&2
          mkdir "$(inputs.output_directory)"

          # Extract reference tar ball
          echo "Extracting the output directory" 1>&2
          tar -C "$(inputs.output_directory)" -xf "$(inputs.reference_tar.path)"

          # Rebuild reference tar ball
          echo "Rebuilding the reference tar ball" 1>&2
          tar -czf "$(inputs.output_directory).tar.gz" "$(inputs.output_directory)/"


baseCommand: [ "sh" ]

arguments:
  - position: -1
    valueFrom: "tar-reference-genome.sh"

inputs:
  reference_tar:
    label: reference tar
    doc: |
      The reference tar ball
    type: File
  output_directory:
    label: output directory
    doc: |
      The name of the output directory
    type: string

outputs:
  output_compressed_reference_tar:
    label: output compressed reference tar
    doc: |
      The output compressed reference tar (that's not a tarbomb).
    type: File
    outputBinding:
      glob: "$(inputs.output_directory).tar.gz"

successCodes:
  - 0
