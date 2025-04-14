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
id: bclconvert-interop-qc--1.3.1--1.25.2
label: bclconvert-interop-qc v(1.3.1--1.25.2)
doc: |
  Documentation for bclconvert-interop-qc v1.3.1--1.25.2
  This workflow has been designed for BCLConvert 4.2.7 outputs from the Nextflow autolaunch pipeline.
  The InterOp directory is expected to contain the IndexMetricsOut.bin file, otherwise the
  index summary will not be generated.
  It is assumed that the Reports directory will contain the RunInfo.xml file

requirements:
  InlineJavascriptRequirement: { }
  ScatterFeatureRequirement: { }
  MultipleInputFeatureRequirement: { }
  StepInputExpressionRequirement: { }

inputs:
  # Requires two directories
  instrument_run_id:
    label: Instrument Run ID
    doc: |
      The instrument run ID
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


steps:
  # Step 0, collect the run info xml file from the Reports directory
  get_run_info_xml_file_from_reports_dir:
    label: Get RunInfo.xml file from Reports Dir
    doc: |
      Get the RunInfo.xml file from the Reports Directory
    in:
      input_dir:
        source: bclconvert_report_directory
      file_basename:
        valueFrom: "RunInfo.xml"
    out:
      - id: output_file
    run: ../../../expressions/get-file-from-directory/1.0.1/get-file-from-directory__1.0.1.cwl

  # 1 of 2 steps - generate the interop qc
  generate_interop_qc_step:
    label: Generate InterOp QC
    doc: |
      Generate the interop files by mounting the interop directory underneath a directory named by the run id specified.
      along with the run info xml file.
    in:
      input_run_dir:
        source:
          - instrument_run_id
          - interop_directory
          - get_run_info_xml_file_from_reports_dir/output_file
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
        source: instrument_run_id
        valueFrom: "$(self)_multiqc_report.html"
      title:
        source: instrument_run_id
        valueFrom: "$(self) BCLConvert MultiQC Report"
      cl_config:
        valueFrom: |
          ${
             return JSON.stringify({"bclconvert": { "genome_size": "hg38_genome" }});
           }
    out:
      - id: output_directory
      - id: output_file
    run: ../../../tools/multiqc/1.25.2/multiqc__1.25.2.cwl

  # Generate the qlims csv file
  generate_qc_csv_step:
    label: Generate QLIMS CSV
    doc: |
      Generate the QLIMS CSV file from the interop directory
    in:
      multiqc_data_json:
        source:
          - run_multiqc_step/output_directory
          - instrument_run_id
        valueFrom: |
          ${
            return {
              "class": "File",
              "basename": "multiqc_data.json",
              "location": self[0].location + "/" + self[1] + "_multiqc_report_data/multiqc_data.json"
            };
          }
    out:
      - id: qlims_csv
    run: ../../../tools/custom-convert-multiqc-json-data-to-qlims-import-csv/1.0.0/custom-convert-multiqc-json-data-to-qlims-import-csv__1.0.0.cwl

  rename_qc_csv_step:
    label: Rename QLIMS CSV
    doc: |
      Rename the QLIMS CSV file to include the instrument run ID
    in:
      basename:
        source: instrument_run_id
        valueFrom: "$(self)_multiqc_bclconvert_summary_qlims.csv"
      location:
        source: generate_qc_csv_step/qlims_csv
        valueFrom: "$(self.location)"
    out:
      - id: output_file
    run: ../../../expressions/create-file/1.0.0/create-file__1.0.0.cwl

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
  multiqc_qlims_csv_report:
    label: multiqc qlims csv report
    doc: |
      The CSV required by qlims for ingestion generated from the multiqc step
    type: File
    outputSource: rename_qc_csv_step/output_file



