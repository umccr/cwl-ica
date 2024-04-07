cwlVersion: v1.1
class: Workflow

# Extensions
$namespaces:
  s: https://schema.org/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: bclconvert-interop-qc--1.3.1--1.19
label: bclconvert-interop-qc v(1.3.1--1.19)
doc: |
  Documentation for bclconvert-interop-qc v1.3.1--1.19
  This workflow has been designed for BCLConvert 4.2.4 outputs. 
  The InterOp directory is expected to contain the IndexMetricsOut.bin file, otherwise the
  index summary will not be generated.  

requirements:
  InlineJavascriptRequirement: { }
  ScatterFeatureRequirement: { }
  MultipleInputFeatureRequirement: { }
  StepInputExpressionRequirement: { }

inputs:
  # Requires two directories and the file
  run_id:
    label: Run ID
    doc: |
      The run ID
    type: string

  bclconvert_report_directory:
    label: BCLConvert Report Directory
    doc: |
      The output directory from a BCLConvert run named 'Reports'
    type: Directory

  interop_directory:
    label: Interop Directory
    doc: |
      The interop directory
    type: Directory

  run_info_xml_file:
    label: Run Info XML File
    doc: |
      The RunInfo.xml file from the run folder
    type: File

steps:
  # 1 of 2 steps - generate the interop qc
  generate_interop_qc_step:
    label: Generate InterOp QC
    doc: |
      Generate the interop files by mounting the interop directory underneath a directory named by the run id specified.
      along with the run info xml file.
    in:
      input_run_dir:
        source:
          - run_id
          - interop_directory
          - run_info_xml_file
        valueFrom: |
          ${
            return {
              "class": "Directory",
              "basename": self[0],
              "listing": [
                /* The interop directory */
                self[1],
                /* The RunInfo XML file */
                self[2]
              ]
            };
          }
    out:
      - id: interop_out_dir
    run: ../../../tools/illumina-interop/1.3.1/illumina-interop__1.3.1.cwl
  # 2 of 2 steps - run multiqc
  run_multiqc_step:
    label: Run Multiqc
    doc: |
      Run MultiQC on the input reports directory along with the generated index summary files
    in:
      input_directories:
        - generate_interop_qc_step/interop_out_dir
        - bclconvert_report_directory
      output_directory_name:
        valueFrom: "multiqc"
      output_filename:
        source: run_id
        valueFrom: "$(self)_multiqc_report.html"
      title:
        source: run_id
        valueFrom: "$(self) BCLConvert MultiQC Report"
    out:
      - id: output_directory
      - id: output_file
    run: ../../../tools/multiqc/1.19.0/multiqc__1.19.0.cwl

outputs:
  # Collect everything
  interop_output_dir:
    label: interop out dir
    doc: |
      Directory containing the inteop summary csvs
    type: Directory
    outputSource: generate_interop_qc_step/interop_out_dir
  multiqc_output_dir:
    label: multiqc output dir
    doc: |
      Directory containing the multiqc data
    type: Directory
    outputSource: run_multiqc_step/output_directory
  multiqc_html_report:
    label: multiqc html report
    doc: |
      The HTML report generated by the multiqc step
    type: File
    outputSource: run_multiqc_step/output_file