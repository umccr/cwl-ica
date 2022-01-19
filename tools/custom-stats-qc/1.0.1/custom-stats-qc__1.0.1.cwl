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
id: custom-stats-qc--1.0.1
label: custom-stats-qc v(1.0.1)
doc: |
    Documentation for custom-stats-qc v1.0.1

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
        dockerPull: quay.io/umccr/alpine-jq:1.6-amd64

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: "run-custom-qc.sh"
        entry: |
          #!/usr/bin/env bash
            
          # Set up for failure
          set -xeuo pipefail

          get_json_str_from_stats_file(){
            local pattern="$1"
            local stats_file="$2"
            local key="$3"
            local description="$4"
            local value
            # Get value from file and then parse through jq
            value="\$(grep "\${pattern}" "\${stats_file}" | cut -f2)"
            # Return json string
            # https://unix.stackexchange.com/questions/676634/creating-a-nested-json-file-from-variables-using-jq
            jq -n \\
                --arg des "$description" \\
                --arg src "samtools:1.13--h8c37831_0" \\
                --arg val "$value" \\
                --arg key_name "$key" \\
                --argjson detail "{\\"MIN_BQ\\": 0, \\"MIN_MQ\\": 0, \\"DUP\\": \\"false\\", \\"SEC\\": \\"false\\", \\"SUP\\": \\"false\\", \\"CLP\\": \\"false\\", \\"OLP\\": \\"false\\"}" \\
                '{($key_name): {description: $des, source: $src, implementation_details: $detail, value: $val}}'
          }
          # Extract Summary Number section from stats file
          samtools_stats_file="summary_numbers.txt" 
          grep ^SN "$(inputs.output_samtools_stats.path)" | cut -f 2- > "\${samtools_stats_file}"

          # Sample metadata
          JSON_STRING=\$( jq -n \\
                            --arg des "sample id" \\
                            --arg src "$(inputs.sample_source)" \\
                            --arg val "$(inputs.sample_id)" \\
                            '{input: {description: $des, source: $src, value: $val}}' )

          # embedded new line in a variable in bash https://stackoverflow.com/questions/9139401/trying-to-embed-newline-in-a-variable-in-bash
          # Extract average base quality
          JSON_STRING="\${JSON_STRING}"$'\\n'"\$(get_json_str_from_stats_file "average quality" "\${samtools_stats_file}" "average_base_quality" "average base quality")"

          # Extract yield_mapped_bp
          JSON_STRING="\${JSON_STRING}"$'\\n'"\$(get_json_str_from_stats_file "bases mapped (cigar)" "\${samtools_stats_file}" "yield_mapped_bp" "yield mapped bp")"

          # Extract pct_autosomes_20x
          JSON_STRING="\${JSON_STRING}"$'\\n'"\$(get_json_str_from_stats_file "percentage of target genome with coverage > 20" "\${samtools_stats_file}" "pct_autosomes_20x" "pct autosomes 20x")"

          # Extract mean_insert_size
          JSON_STRING="\${JSON_STRING}"$'\\n'"\$(get_json_str_from_stats_file "insert size average:" "\${samtools_stats_file}" "mean_insert_size" "mean insert size")"

          # Extract insert_size_SD
          JSON_STRING="\${JSON_STRING}"$'\\n'"\$(get_json_str_from_stats_file "insert size standard deviation:" "\${samtools_stats_file}" "insert_size_sd" "insert size sd")"

          # Extract pct_discordant_read_pairs
          pct_properly_paired_reads=\$(grep -h "percentage of properly paired reads (%):" "\${samtools_stats_file}" | cut -f2)
          pdr=\$(awk -vn1="$pct_properly_paired_reads" 'BEGIN { print (100 - n1) }')
          JSON_STRING="\${JSON_STRING}"$'\\n'"\$( jq -n \\
                          --arg des "pct discordant paired reads" \\
                          --arg src "samtools:1.13--h8c37831_0" \\
                          --arg val "$pdr" \\
                          --argjson detail "[{\\"MIN_BQ\\": 0, \\"MIN_MQ\\": 0, \\"DUP\\": \\"false\\", \\"SEC\\": \\"false\\", \\"SUP\\": \\"false\\", \\"CLP\\": \\"false\\", \\"OLP\\": \\"false\\"}]" \\
                          '{pct_discordant_reads: {description: $des, source: $src, implementation_details: $detail, value: $val}}' )"

          # Extract pct_mapped_reads where pct_mapped_reads = [(Mapped Reads - Reads MQ0) / Total Reads]
          # RM = Mapped Reads
          # R0 = Reads MQ0
          # RT = Total Reads
          RM=\$(grep -h "reads mapped:" "\${samtools_stats_file}" | cut -f2)
          R0=\$(grep -h "reads MQ0:" "\${samtools_stats_file}" | cut -f2)
          RT=\$(grep -h "raw total sequences:" "\${samtools_stats_file}" | cut -f2)
          pct_mapped_reads=\$(( 100 * ( $RM - $R0) / $RT ))
          JSON_STRING="\${JSON_STRING}"$'\\n'"\$( jq -n \\
                          --arg des "pct mapped reads" \\
                          --arg src "samtools:1.13--h8c37831_0" \\
                          --arg val "$pct_mapped_reads" \\
                          --argjson detail "[{\\"MIN_BQ\\": 0, \\"MIN_MQ\\": 0, \\"DUP\\": \\"false\\", \\"SEC\\": \\"false\\", \\"SUP\\": \\"false\\", \\"CLP\\": \\"false\\", \\"OLP\\": \\"false\\"}]" \\
                          '{pct_mapped_reads: {description: $des, source: $src, implementation_details: $detail, value: $val}}' )"

          # Write output to file
          echo "\${JSON_STRING}" | jq -n '. |= [inputs]' > "$(inputs.output_json_filename).json"

baseCommand: [ "bash", "run-custom-qc.sh" ]

inputs:
  sample_id:
    label: sample id
    doc: |
      Sample identity
    type: string
  sample_source:
    label: sample source
    doc: |
      Sample original source
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
      glob: "$(inputs.output_json_filename).json"

successCodes:
  - 0
