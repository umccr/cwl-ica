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
id: rename-rgsm-in-alignment-header--1.0.0
label: rename-rgsm-in-alignment-header v(1.0.0)
doc: |
    Documentation for rename-rgsm-in-alignment-header v1.0.0

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

requirements:
  SchemaDefRequirement: 
    types:
      - $import: ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml
      - $import: ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml

baseCommand: [ "samtools", "reheader" ]

arguments:
  - "--no-PG"

inputs:
  rgsm:
    label: rgsm
    doc: The RGSM tag to be added to the header of the alignment file
    type: string
    inputBinding:
      prefix: "--command"
      valueFrom: "perl -pe 's%(@RG.*SM:)[\\w-_\\.]+\\s(.*)%\\1${self}\\2%'"
  alignment_file:
    label: alignment file
    doc: |
        The alignment file to be modified. This can be either a CRAM or BAM file.
    type:
      - ../../../schemas/bam-input/1.0.0/bam-input__1.0.0.yaml#bam-input
      - ../../../schemas/cram-input/1.0.0/cram-input__1.0.0.yaml#cram-input
    inputBinding:
      position: 2

stdout: |
  ${
    // Output file name is the same as the input file name
    if (inputs.alignment_file.cram_input) {
      return inputs.sequence_data.cram_input.basename;
    } else if (inputs.alignment_file.bam_input) {
      return inputs.alignment_file.bam_input.basename;
    } else {
      throw new Error("No input file provided");
    }
  }

outputs:
  alignment_file_out_renamed:
    type: File
    outputBinding:
      glob: stdout
      loadContents: false

successCodes:
  - 0
