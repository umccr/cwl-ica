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
id: custom-subset-bam--1.12.0
label: custom-subset-bam v(1.12.0)
doc: |
    Use samtools v1.12.0 and shuf to take a random subset of a bam file

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
        dockerPull: public.ecr.aws/biocontainers/samtools:1.12--h9aed4be_1

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: "run-subset-bam.sh"
        entry: |
          #!/usr/bin/env bash

          # We use the following logic to create the optitype pipeline
          # 1. Save the header as a separate file
          # 2. Extract all non header lines
          # 3. Use 'shuf' to then extract a random subset of the non header lines
          # 4. Convert shuffled extracted random subset back to bam
          # 5. Re-header the new shuffled bam
          # 6. Re-sort the new bam file
          # 7. Index the new bam file

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Get header
          samtools view \
            -H \
            -o "$(inputs.sorted_bam.nameroot).header.sam" \
            "$(inputs.sorted_bam).path"

          # To sam file - no header in output
          samtools view \
            -o "$(inputs.sorted_bam.nameroot).headless.sam" \
            "$(inputs.sorted_bam).path"

          # Use shuf to randomly select a number of alignments
          shuf \
            -n "$(n_lines)" \
            -o "$(inputs.sorted_bam.nameroot).headless.shuffled-$(inputs.n_lines).sam" \
            "$(inputs.sorted_bam.nameroot).headless.sam"

          # Convert shuffled back to bam
          samtools view -b \
            -o "$(inputs.sorted_bam.nameroot).headless.shuffled-$(inputs.n_lines).bam" \
            "$(inputs.sorted_bam.nameroot).headless.shuffled-$(inputs.n_lines).sam"

          # Re-add header from sam header
          samtools reheader \
            "$(inputs.sorted_bam.nameroot).header.sam" \
            "$(inputs.sorted_bam.nameroot).headless.shuffled-$(inputs.n_lines).bam" \
          > "$(inputs.sorted_bam.nameroot).shuffled-$(inputs.n_lines).bam"

          # Sort new bam file
          samtools sort \
            -o "$(inputs.sorted_bam.nameroot).$(inputs.n_lines).bam" \
            "$(inputs.sorted_bam.nameroot).shuffled-$(inputs.n_lines).bam"

          # Index new bam file
          samtools index "$(inputs.sorted_bam.nameroot).$(inputs.n_lines).bam"

baseCommand: [ "bash", "run-subset-bam.sh" ]

inputs:
  bam_sorted:
    label: bam sorted
    doc: |
      Sorted bam file to be truncated
    type: File
    secondaryFiles:
      - pattern: ".bai"
        required: true
  n_lines:
    label: n lines
    doc: |
      Number of lines to subset
    type: int

outputs:
  bam_indexed:
    label: bam subset
    doc: |
      Subsetted bam file (sorted by chromosome)
    type: File
    secondaryFiles:
      - ".bai"
    outputBinding:
      glob: "$(inputs.sorted_bam.nameroot).$(inputs.n_lines).bam"

successCodes:
  - 0