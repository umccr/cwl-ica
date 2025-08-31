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
id: dragen-nirvana-downloader--4.4.4
label: dragen-nirvana-downloader v(4.4.4)
doc: |
  Documentation for dragen-nirvana-downloader v4.4.4

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: fpga
    ilmn-tes:resources/size: medium
    coresMin: 16
    ramMin: 240000
  DockerRequirement:
    # Dragen 4.4.4
    dockerPull: "079623148045.dkr.ecr.us-east-1.amazonaws.com/cp-prod/b35eb8ce-3035-4796-896b-1b33b6a02c44:latest"

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.4.0/dragen-tools__4.4.0.cwljs
  InitialWorkDirRequirement:
    listing:
      - entryname: "run_nirvana_download.sh"
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Reset dragen
          /opt/edico/bin/dragen_reset

          # Create directories
          mkdir \\
            ".dotnet" \\
            "nirvana_assembly_$(inputs.genome_version)"

          # Run the nirvana script
          echo "Downloading $(inputs.annotations_type)" 1>&2
          DOTNET_BUNDLE_EXTRACT_BASE_DIR="$(runtime.outdir)/.dotnet" \\
          "/opt/edico/share/nirvana/DataManager" "download" \\
            --ref "$(inputs.genome_version)" \\
            --versions-config "/opt/edico/resources/annotation/$(inputs.annotations_type)_annotations_$(inputs.genome_version).json" \\
            --dir "nirvana_assembly_$(inputs.genome_version)" \\
            --credentials-file "/opt/edico/config/data-downloader.json"
          
          # If the annotation type is not "all" we need to rerun with "all" as well
          if [[ "$(inputs.annotations_type)" != "all" ]]; then
            echo "Also downloading "all" annotations as well" 1>&2
            DOTNET_BUNDLE_EXTRACT_BASE_DIR="$(runtime.outdir)/.dotnet" \\
            "/opt/edico/share/nirvana/DataManager" "download" \\
              --ref "$(inputs.genome_version)" \\
              --versions-config "/opt/edico/resources/annotation/all_annotations_$(inputs.genome_version).json" \\
              --dir "nirvana_assembly_$(inputs.genome_version)" \\
              --credentials-file "/opt/edico/config/data-downloader.json"
          fi
          
          # Tar it up!
          echo "Tarring it up $(inputs.annotations_type)" 1>&2
          tar \\
            --create \\
            --use-compress-program pigz \\
            --file "nirvana_assembly_$(inputs.genome_version).tar.gz" \\
            "nirvana_assembly_$(inputs.genome_version)"


baseCommand: [ "bash", "run_nirvana_download.sh" ]

inputs:
  genome_version:
    label: genome version
    doc: |
      Genome version, one of GRCh37, GRCh38
    type:
      - "null"
      - type: enum
        symbols: [ "GRCh37", "GRCh38" ]
    default: "GRCh38"
  annotations_type:
    label: annotations type
    doc: |
      Annotations type, one of all, germline_tagging, tmb
      If not "all" we will download "all" as well
    type:
      - "null"
      - type: enum
        symbols: [ "all", "germline_tagging", "tmb" ]
    default: "all"

outputs:
  nirvana_assembly_tarball:
    label: nirvana assembly tarball
    doc: |
      The downloaded nirvana assembly tar.gz file
    type: File
    outputBinding:
      glob: "nirvana_assembly_$(inputs.genome_version).tar.gz"


successCodes:
  - 0
