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
id: bclconvert-interop-qc--1.9.0--1.33

doc: |
  Documentation for bclconvert-interop-qc v1.9.0--1.33
  This workflow has been designed for BCLConvert 4.4 outputs from the Nextflow autolaunch pipeline.
  The InterOp directory is expected to contain the IndexMetricsOut.bin file, 
  otherwise the index summary will not be generated.
  It is assumed that the Reports directory will contain the RunInfo.xml file. 
  We also support the input of additional parquet files for MultiQC so that we can append to the existing BCLConvert InterOp data.

requirements:
  InlineJavascriptRequirement: { }
  ScatterFeatureRequirement: { }
  MultipleInputFeatureRequirement: { }
  StepInputExpressionRequirement: { }

inputs:
  # InterOp QC requires three inputs
  # The instrument run ID, the BCLConvert reports directory and the InterOp directory
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
  # Now for MultiQC we can also add in the additional parquet files
  # And the sample names tsv file
  additional_parquet_files:
    label: Additional Parquet Files
    doc: |
      Additional parquet files to include in the MultiQC run
    type: File[]?
  sample_filters_tsv:
    label: Sample Filters TSV
    doc: |
      TSV file containing show/hide patterns for the report
    type: File?

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
      instrument_run_id:
        source: instrument_run_id
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
    run: ../../../tools/illumina-interop/1.9.0/illumina-interop__1.9.0.cwl

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
             return JSON.stringify(
               {
                 "top_modules": [
                   "bclconvert"
                 ],
                 "bclconvert": { 
                   "genome_size": "hg38_genome"
                 }
               }
             );
           }
      additional_parquet_files:
        - additional_parquet_files
      sample_filters_tsv:
        - sample_filters_tsv
    out:
      - id: output_directory
      - id: output_file
    run: ../../../tools/multiqc/1.33.0/multiqc__1.33.0.cwl

outputs:
  # Collect everything
  interop_output_dir:
    label: interop out dir
    doc: |
      Directory containing the interop summary csvs
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



