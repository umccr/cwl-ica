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
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: custom-stats-qc--1.0.0
label: custom-stats-qc v(1.0.0)
doc: |
    Documentation for custom-stats-qc v1.0.0

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: small
        coresMin: 1
        ramMin: 4000
    DockerRequirement:
        dockerPull: bash:latest

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: "run-custom-qc.sh"
        entry: |
          #!/usr/bin/env bash

          # Set up for failure
          set -euo pipefail

          # Extract average base quality
          avg_base_qual=\$(grep -h "SN	average quality:" "$(inputs.output_samtools_stats.path)" | cut -f 3)
          echo "average_base_quality: \$avg_base_qual" >> "$(inputs.output_filename).txt"

          # Extract yield_mapped_bp
          yield_mapped_bp=\$(grep -h "SN	bases mapped (cigar)" "$(inputs.output_samtools_stats.path)" | cut -f 3)
          echo "yield_mapped_bp:  \$yield_mapped_bp" >> "$(inputs.output_filename).txt"

          # Extract pct_autosomes_20x
          pct_autosomes_20x=\$(grep -h "SN	percentage of target genome with coverage > 20" "$(inputs.output_samtools_stats.path)" | cut -f 3)
          echo "pct_autosomes_20x:    \$pct_autosomes_20x" >> "$(inputs.output_filename).txt"

          # Extract pct_discordant_read_pairs
          pct_discordant_reads=\$(grep -h "SN	percentage of properly paired reads (%):" "$(inputs.output_samtools_stats.path)" | cut -f3)
          pdr=\$(awk -vn1="$pct_discordant_reads" 'BEGIN { print (100 - n1) }')
          echo "pct_discordant_reads: \$pdr" >> "$(inputs.output_filename).txt"

          # Extract mean_insert_size
          mean_insert_size=\$(grep -h "SN	insert size average:" "$(inputs.output_samtools_stats.path)" | cut -f3)
          echo "mean_insert_size: \$mean_insert_size" >> "$(inputs.output_filename).txt"

          # Extract Insert_size_SD
          insert_size_sd=\$(grep -h "SN	insert size standard deviation:" "$(inputs.output_samtools_stats.path)" | cut -f3)
          echo "insert_size_SD:   \$insert_size_sd" >> "$(inputs.output_filename).txt"

          # Extract pct_mapped_reads where pct_mapped_reads = [(Mapped Reads - Reads MQ0) / Total Reads]
          # RM = Mapped Reads
          # R0 = Reads MQ0
          # RT = Total Reads
          RM=\$(grep -h "SN	reads mapped:" "$(inputs.output_samtools_stats.path)" | cut -f3)
          R0=\$(grep -h "SN	reads MQ0:" "$(inputs.output_samtools_stats.path)" | cut -f3)
          RT=\$(grep -h "SN	raw total sequences:" "$(inputs.output_samtools_stats.path)" | cut -f3)
          pct_mapped_reads=\$(( 100 * ( $RM - $R0) / $RT ))
          echo "pct_mapped_reads: \$pct_mapped_reads" &>> "$(inputs.output_filename).txt"

          #jq -s -R '[[ split("\n")[] | select(length > 0) | split(": +";"") | {(.[0]): .[1]}] | add]' "$(inputs.output_filename).txt" >> "$(inputs.output_filename).txt"


baseCommand: [ "bash", "run-custom-qc.sh" ]

inputs:
  output_samtools_stats:
    label: output samtools stats
    doc: |
      Output txt file from samtools stats
    type: File
  output_filename:
    label: output filename
    doc: |
      output file
    type: string

outputs:
  output_file:
    label: output file
    doc: |
      Output file containing custom metrics
    type: File
    outputBinding:
      glob: "$(inputs.output_filename).txt"

successCodes:
  - 0
