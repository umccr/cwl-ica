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
id: tabix--0.2.6
label: tabix v(0.2.6)
doc: |
    Documentation for tabix v0.2.6

hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard/economy
            type: standard/standardHiCpu/standardHiMem/standardHiIo/fpga
            size: small/medium/large/xlarge/xxlarge
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: ubuntu:latest

baseCommand: []

inputs: []

outputs: []

successCodes:
  - 0
