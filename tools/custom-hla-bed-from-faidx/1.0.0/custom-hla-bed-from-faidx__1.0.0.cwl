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
id: custom-hla-bed-from-faidx--1.0.0
label: custom-hla-bed-from-faidx v(1.0.0)
doc: |
  Extract the HLA regions from the file.
  Takes in a fasta index file and returns a bed file


hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: small
        coresMin: 2
        ramMin: 2000
    DockerRequirement:
        dockerPull: ghcr.io/umccr/alpine-pandas:1.4.3

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: get_hla_contigs_as_bed.py
        entry: |
          #!/usr/bin/env python
          """
          Use pandas to take a faidx header and convert into a bed file with hla regions
          with HLA-regions from chr6 and those from HLA contigs
          """

          # Import modules
          import pandas as pd
          import re
          import os
          import sys

          # Read bam file
          regions_bed = pd.read_csv(sys.argv[1],
                                    sep="\t",
                                    header=None,
                                    names=["Name", "Length", "OffSet", "LineBases", "LineWidth"],
                                    usecols=['Name', 'Length'])

          # Create start pos
          regions_bed["Start"] = 1

          # Rename columns and reindex
          regions_bed.rename(columns={"Name": "chromosome",
                                      "Start": "start",
                                      "Length": "end"},
                             inplace=True)

          regions_bed = regions_bed.reindex(columns=["chromosome", "start", "end"])

          # Filter out rows that dont start with "HLA-"
          regions_bed = regions_bed.query('chromosome.str.startswith("HLA-")')

          # Write output as bed format
          with open("hla-regions.bed", 'w') as output_h:
            regions_bed.to_csv(output_h, sep="\t", header=False, index=False)

baseCommand: ["python", "get_hla_contigs_as_bed.py"]

inputs:
  faidx_file:
    label: faidx file
    doc: |
      Fasta index file
    type: File
    inputBinding:
      position: 1

outputs:
  hla_regions_bed:
    label: hla regions bed
    doc: |
      Output hla regions bed file
    type: File
    # Outputs contigs objects
    outputBinding:
      glob: "hla-regions.bed"

successCodes:
  - 0
