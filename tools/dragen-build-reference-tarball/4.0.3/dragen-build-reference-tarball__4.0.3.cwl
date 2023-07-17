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
id: dragen-build-reference-tarball--4.0.3
label: dragen-build-reference-tarball v(4.0.3)
doc: |
    Documentation for dragen-build-reference-tarball v4.0.3

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
        dockerPull: ubuntu:latest

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: build_reference_from_bin.sh
        entry: |
          #!/usr/bin/env bash
          
          # Set to fail
          set -euo pipefail
          
          # Build reference directory from bin         
          bash "$(inputs.reference_bin.path)" \\
            --quiet \\
            --accept \\
            --target "$(inputs.output_stem)"
          
          # Tar up output stem
          # Add in --remove-files to prevent output directory being uploaded as well
          tar \\
            --create \\
            --remove-files \\
            --file "$(inputs.output_stem).tar.gz" \\
            --gzip \\
            "$(inputs.output_stem)"

baseCommand: [ "bash", "build_reference_from_bin.sh" ]

inputs:
  reference_bin:
    label: reference bin
    doc: |
      The bash / tarball script that contains the reference
    type: File
  output_stem:
    label: output stem
    doc: |
      The name of the output directory and stem of the compressed tar ball thats generated
    type: string

outputs:
  output_reference_tarball:
    label: output reference tarball
    doc: |
      The output reference tarball thats created by running the reference bin script
    type: File
    outputBinding:
      glob: "$(inputs.output_stem).tar.gz"

successCodes:
  - 0
