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
    A tool to extract custom QC metrics from samtools stats output and convert to json format.

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:tier: standard
        ilmn-tes:resources:type: standard
        ilmn-tes:resources:size: small
        coresMin: 1
        ramMin: 4000
    DockerRequirement:
        dockerPull: ghcr.io/umccr/alpine-jq:1.6

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: "run-custom-qc.sh"
        entry: |
          #!/usr/bin/env sh

          # Set up for failure
          set -xeuo pipefail

          # Sample metadata
          JSON_STRING=\$( jq -n \\
                            --arg sm "$(inputs.sample_id)" \\
                            '{sampleID: $sm}' )
          echo "$(inputs.output_json_filename).json"
          echo \$JSON_STRING >> "$(inputs.output_json_filename).json"

          # Extract average base quality
          avg_base_qual=\$(grep -h "SN	average quality" "$(inputs.output_samtools_stats.path)" | cut -f 3)
          JSON_STRING=\$( jq -n \\
                            --arg des "average base quality" \\
                            --arg src "SN	average quality" \\
                            --arg val "$avg_base_qual" \\
                            '{average_base_quality: {description: $des, source: $src, value: $val}}' )
          echo \$JSON_STRING >> "$(inputs.output_json_filename).json"

          # Extract yield_mapped_bp
          yield_mapped_bp=\$(grep -h "SN	bases mapped (cigar)" "$(inputs.output_samtools_stats.path)" | cut -f 3)
          JSON_STRING=\$( jq -n \\
                            --arg des "yield mapped bp" \\
                            --arg src "SN	bases mapped (cigar)" \\
                            --arg val "$yield_mapped_bp" \\
                            '{yield_mapped_bp: {description: $des, source: $src, value: $val}}' )
          echo \$JSON_STRING >> "$(inputs.output_json_filename).json"

          # Extract pct_autosomes_20x
          pct_autosomes_20x=\$(grep -h "SN	percentage of target genome with coverage > 20" "$(inputs.output_samtools_stats.path)" | cut -f 3)
          JSON_STRING=\$( jq -n \\
                            --arg des "pct autosomes 20x" \\
                            --arg src "SN	percentage of target genome with coverage > 20" \\
                            --arg val "$pct_autosomes_20x" \\
                            '{pct_autosomes_20x: {description: $des, source: $src, value: $val}}' )
          echo \$JSON_STRING >> "$(inputs.output_json_filename).json"

          # Extract pct_discordant_read_pairs
          pct_discordant_reads=\$(grep -h "SN	percentage of properly paired reads (%):" "$(inputs.output_samtools_stats.path)" | cut -f3)
          pdr=\$(awk -vn1="\$pct_discordant_reads" 'BEGIN { print (100 - n1) }')
          JSON_STRING=\$( jq -n \\
                            --arg des "pct discordant reads" \\
                            --arg src "SN	percentage of properly paired reads (%)" \\
                            --arg val "$pct_discordant_reads" \\
                            '{pct_discordant_reads: {description: $des, source: $src, value: $val}}' )
          echo \$JSON_STRING >> "$(inputs.output_json_filename).json"

          # Extract mean_insert_size
          mean_insert_size=\$(grep -h "SN	insert size average:" "$(inputs.output_samtools_stats.path)" | cut -f3)
          JSON_STRING=\$( jq -n \\
                            --arg des "mean insert size" \\
                            --arg src "SN	insert size average" \\
                            --arg val "$mean_insert_size" \\
                            '{mean_insert_size: {description: $des, source: $src, value: $val}}' )
          echo \$JSON_STRING >> "$(inputs.output_json_filename).json"

          # Extract Insert_size_SD
          insert_size_sd=\$(grep -h "SN	insert size standard deviation:" "$(inputs.output_samtools_stats.path)" | cut -f3)
          JSON_STRING=\$( jq -n \\
                            --arg des "insert size sd" \\
                            --arg src "SN	insert size standard deviation" \\
                            --arg val "$insert_size_sd" \\
                            '{insert_size_sd: {description: $des, source: $src, value: $val}}' )
          echo \$JSON_STRING >> "$(inputs.output_json_filename).json"

          # Extract pct_mapped_reads where pct_mapped_reads = [(Mapped Reads - Reads MQ0) / Total Reads]
          # RM = Mapped Reads
          # R0 = Reads MQ0
          # RT = Total Reads
          RM=\$(grep -h "SN	reads mapped:" "$(inputs.output_samtools_stats.path)" | cut -f3)
          R0=\$(grep -h "SN	reads MQ0:" "$(inputs.output_samtools_stats.path)" | cut -f3)
          RT=\$(grep -h "SN	raw total sequences:" "$(inputs.output_samtools_stats.path)" | cut -f3)
          pct_mapped_reads=\$(( 100 * ( $RM - $R0) / $RT ))
          JSON_STRING=\$( jq -n \\
                            --arg des "pct mapped reads" \\
                            --arg src "pct_mapped_reads = [(Mapped Reads - Reads MQ0) / Total Reads]" \\
                            --arg val "$pct_mapped_reads" \\
                            '{pct_mapped_reads: {description: $des, source: $src, value: $val}}' )
          echo \$JSON_STRING >> "$(inputs.output_json_filename).json"

          jq '.' "$(inputs.output_json_filename).json" >> "$(inputs.output_json_filename)_$(inputs.sample_id).json"

baseCommand: [ "sh", "run-custom-qc.sh" ]

inputs:
  sample_id:
    label: sample id
    doc: |
      Id of the input sample
    type: string
  output_samtools_stats:
    label: output samtools stats
    doc: |
      Output txt file from samtools stats
    type: File
  output_json_filename:
    label: output filename
    doc: |
      output file
    type: string

outputs:
  output_json:
    label: output file
    doc: |
      JSON output file containing custom metrics
    type: File
    outputBinding:
      glob: "$(inputs.output_json_filename)_$(inputs.sample_id).json"

successCodes:
  - 0
