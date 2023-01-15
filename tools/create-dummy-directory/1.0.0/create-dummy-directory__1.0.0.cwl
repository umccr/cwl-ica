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
id: create-dummy-directory--1.0.0
label: create-dummy-directory v(1.0.0)
doc: |
    Documentation for create-dummy-directory v1.0.0

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
  InitialWorkDirRequirement:
    listing:
      - entryname: "run_script.sh"
        entry: |
          #!/usr/bin/env sh
          
          # Create directory
          mkdir output_directory
          
          # Add in empty file so directory is uploaded
          touch output_directory/empty.txt

baseCommand: ["sh", "run_script.sh"]

inputs: []

outputs:
  output_directory:
    label: output directory
    doc: |
      Output directory
    type: Directory
    outputBinding:
      glob: "output_directory"

successCodes:
  - 0
