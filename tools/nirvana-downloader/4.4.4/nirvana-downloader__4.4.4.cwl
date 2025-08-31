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
id: nirvana-downloader--4.4.4
label: nirvana-downloader v(4.4.4)
doc: |
    Documentation for nirvana-downloader v4.4.4

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard/economy
        ilmn-tes:resources/type: standard/standardHiCpu/standardHiMem/standardHiIo/fpga
        ilmn-tes:resources/size: small/medium/large/xlarge/xxlarge
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: ubuntu:latest

baseCommand: []

inputs: []

outputs: []

successCodes:
  - 0
