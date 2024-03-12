cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: https://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# TODO - rename this to index-vcf-file and place as custom tool
# TODO - OR abstract this tool and support gff, gtf or sam files as well.

# Metadata
s:author:
    class: s:Person
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: tabix--0.2.6
label: tabix v(0.2.6)
doc: |
    Add an index to a vcf file, more info can be found [here](http://www.htslib.org/doc/tabix.html)

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: medium
        coresMin: 1
        ramMin: 4000
    DockerRequirement:
        dockerPull: public.ecr.aws/biocontainers/tabix:1.11--hdfd78af_0

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: create_index.sh
        entry: |
          #!/usr/bin/env bash

          # Set pipe failure
          set -euo pipefail

          # Copy file over
          cp "$(inputs.vcf_file.path)" "$(inputs.vcf_file.basename)"

          # Run tabix
          tabix "\${@}"


baseCommand: ["bash", "create_index.sh"]

arguments:
  - position: -1
    prefix: "-p"
    valueFrom: "vcf"

inputs:
  vcf_file:
    label: vcf file
    doc: |
      The input vcf file to be indexed
    type: File
    inputBinding:
      valueFrom: |
        ${
          return self.basename
        }

outputs:
  vcf_file_indexed:
    label: vcf file indexed
    doc: |
      The indexed vcf file
    type: File
    outputBinding:
      glob: "$(inputs.vcf_file.basename)"
    secondaryFiles:
      - pattern: ".tbi"
        required: false

successCodes:
  - 0
