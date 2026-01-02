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
id: get-dragen-default-configuration-json--4.4.4
label: get-dragen-default-configuration-json v(4.4.4)
doc: |
  Documentation for get-dragen-default-configuration-json
  v4.4.0

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: fpga2
    ilmn-tes:resources/size: medium
    coresMin: 24
    ramMin: 256000
  DockerRequirement:
    # Dragen 4.4.4
    dockerPull: "079623148045.dkr.ecr.us-east-1.amazonaws.com/cp-prod/b35eb8ce-3035-4796-896b-1b33b6a02c44:latest"

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.4.0/dragen-tools__4.4.0.cwljs

baseCommand: [ "cat", "/opt/edico/config/dragen-user-defaults.cfg" ]

stdout: "stdout.txt"

inputs: []

outputs:
  dragen_default_configuration_options:
    label: dragen default configuration options
    doc: |
      The default configuration options for the DRAGEN pipeline.
      This is a JSON object that contains the default values for all
      the configuration options that can be set in the DRAGEN pipeline.
      We use this to set the default values for the configuration, and then overwrite it with
      other options we provide in the workflow and then write back to toml when running the dragen tool!
    type: string
    outputBinding:
      glob: stdout.txt
      loadContents: true
      outputEval: |
        ${
          /* Take the output from the stdout file and convert it to JSON, and then to string */
          return JSON.stringify(toml_to_json(self[0].contents));
        }

successCodes:
  - 0
