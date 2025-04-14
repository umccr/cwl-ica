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
id: custom-convert-multiqc-json-data-to-qlims-import-csv--1.0.0
label: custom-convert-multiqc-json-data-to-qlims-import-csv v(1.0.0)
doc: |
    Documentation for custom-convert-multiqc-json-data-to-qlims-
    import-csv v1.0.0

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
        dockerPull: ghcr.io/umccr/alpine-jq:1.6

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: "convert-multiqc-json-data-to-qlims-import-csv.sh"
        entry: |
          jq --raw-output \\
            --argjson human_genome_size "$(inputs.human_genome_size)" \\
            '
              .report_saved_raw_data.multiqc_bclconvert_bysample | to_entries |
              map(
                .key as $sample_name |
                .value.lanes | to_entries |
                map(
                  .key as $lane |
                  {
                    "Sample Name": $sample_name,
                    "Coverage": ((.value.yield_q30 / $human_genome_size) * 100 | round / 100),
                    "Lane": ($lane[1:] | tonumber),
                    "Clusters": .value.clusters,
                    "One mismatch index": ((.value.percent_one_mismatch_index_reads) * 100 | round / 100),
                    "Yield": .value.yield_
                  }
                )
              ) |
              flatten |
              # To csv (With ordered keys)
              # https://unix.stackexchange.com/questions/754935/convert-json-to-csv-with-headers-in-jq
              [first|keys_unsorted] + map([.[]]) | .[] | @csv |
              # Remove quotes
              # https://stackoverflow.com/questions/60350315/why-does-the-jq-raw-output-argument-fail-to-remove-quotes-from-csv-output
              gsub("\\""; "")
          ' < "$(inputs.multiqc_data_json.path)"

baseCommand: [ "bash", "convert-multiqc-json-data-to-qlims-import-csv.sh" ]

stdout: "qlims.csv"

inputs:
  human_genome_size:
    label: "Human genome size"
    type: long
    default: 3049315783
  multiqc_data_json:
    label: "MultiQC JSON data"
    type: File

outputs:
  qlims_csv:
    type: File
    outputBinding:
      glob: "qlims.csv"


successCodes:
  - 0
