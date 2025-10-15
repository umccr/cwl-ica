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
id: multiqc--1.25.0
label: multiqc v(1.25.0)
doc: |
  Documentation for multiqc v1.25.0
  Use patch that includes https://github.com/ewels/MultiQC/pull/1969

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
# We place the ResourceRequirement and DockerRequirements in the hints section as this allows
# them to be overridden if necessary
hints:
  ResourceRequirement:
    ilmn-tes:resources:tier: standard
    ilmn-tes:resources:type: standard
    ilmn-tes:resources:size: small
    coresMin: 2
    ramMin: 8000
  DockerRequirement:
    dockerPull: ghcr.io/multiqc/multiqc:v1.31


# We require javascript to handle
# The additional_parquet_files input
requirements:
  InlineJavascriptRequirement: {}


# Single command line tool
baseCommand: ["multiqc"]


# Inputs
inputs:
  # Required inputs
  input_directories:
    label: input directories
    doc: |
      The list of directories to place in the analysis
    type: Directory[]
    inputBinding:
      position: 100  # Last items on the command line
  output_directory_name:
    label: output directory
    doc: |
      The output directory
    type: string
    inputBinding:
      prefix: "--outdir"
      valueFrom: "$(runtime.outdir)/$(self)"
  output_filename:
    label: output filename
    doc: |
      Report filename in html format.
      Defaults to 'multiqc-report.html"
    type: string
    inputBinding:
      prefix: "--filename"
  title:
    label: title
    doc: |
      Report title.
      Printed as page header, used for filename if not otherwise specified.
    type: string
    inputBinding:
      prefix: "--title"
  comment:
    label: comment
    doc: |
      Custom comment, will be printed at the top of the report.
    type: string?
    inputBinding:
      prefix: "--comment"
  config:
    label: config
    doc: |
      Configuration file for bclconvert
    type: File?
    inputBinding:
      prefix: "--config"
  cl_config:
    label: cl config
    doc: |
      Override config from the cli
    type: string?
    inputBinding:
      prefix: "--cl-config"
  additional_parquet_files:
    label: additional parquet files
    doc: |
      Additional parquet files to include in the output, e.g. sample sheet parquet file
    type: File[]?
    inputBinding:
      # The very, very last position on the command line
      position: 101
      # We just want to put the directory of each file here
      # As a positional argument
      valueFrom: |
        ${
          /* 
            Self is an array of files, iterate through each item and 
            return the parent directory of the path attribute
          */
          return self.map(function(fileObj) {
            return fileObj.path.replace(/\/[^\/]+$/, "");
          });
        }

  sample_names_tsv:
    label: sample names tsv
    doc: |
      TSV file with two columns: sample name and display name.
      Used to rename samples in the report.
    type: File?
    inputBinding:
      prefix: "--sample-names"


outputs:
  output_directory:
    label: output directory
    doc: |
      Directory that contains all multiqc analysis data
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory_name)"
  output_file:
    label: output file
    doc: |
      Output html file
    type: File
    outputBinding:
      glob: "$(inputs.output_directory_name)/$(inputs.output_filename)"


successCodes:
  - 0
