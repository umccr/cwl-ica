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
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: bcl-conversion--3.7.5
label: bcl-conversion v(3.7.5)
doc: |
    Runs bcl-convert v3.7.5 with multiqc output of the bcl input directory

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/settings-by-samples/1.0.0/settings-by-samples__1.0.0.yaml
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  # BCL Required inputs
  bcl_input_directory:
    label: bcl input directory
    doc: |
      Path to the bcl files
    type: Directory
  samplesheet:
    label: sample sheet
    doc: |
      The path to the full samplesheet
    type: File
  # BCL Optional inputs
  settings_by_samples:
    label: settings by samples
    doc: |
      List of settings by samples
    type: ../../../schemas/settings-by-samples/1.0.0/settings-by-samples__1.0.0.yaml#settings-by-samples[]?
  samplesheet_outdir:
    label: samplesheet outdir
    doc: |
      Output directory of the samplesheets split by settings
    type: string?
  ignore_missing_samples:
    label: ignore missing samples
    doc: |
      Remove the samples not present in the override cycles record
    type: boolean?
    default: true
  samplesheet_output_format:
    label: set samplesheet output format
    doc: |
      Convert headers to v2 samplesheet format
    type:
      - "null"
      - type: enum
        symbols:
          - v1
          - v2
  bcl_only_lane_bcl_conversion:
    label: bcl only lane
    doc: |
      Convert only the specified lane number. The value must
      be less than or equal to the number of lanes specified in the
      RunInfo.xml. Must be a single integer value.
    type: int?
  first_tile_only_bcl_conversion:
    label: first tile only
    doc: |
      true — Only process the first tile of the first swath of the
        top surface of each lane specified in the sample sheet.
      false — Process all tiles in each lane, as specified in the sample
        sheet.
    type: boolean?
  strict_mode_bcl_conversion:
    label: strict mode bcl conversion
    doc: |
      true — Abort the program if any filter, locs, bcl, or bci lane
      files are missing or corrupt.
      false — Continue processing if any filter, locs, bcl, or bci lane files
      are missing. Return a warning message for each missing or corrupt
      file.
    type: boolean?
  bcl_sampleproject_subdirectories_bcl_conversion:
    label: bcl sampleproject subdirectories
    doc: |
      true — Allows creation of Sample_Project subdirectories
      as specified in the sample sheet. This option must be set to true for
      the Sample_Project column in the data section to be used.
    type: boolean?
  delete_undetermined_indices_bcl_conversion:
    label: delete undetermined indices
    doc: |
      Delete undetermined indices on completion of the run
    type: boolean?
    default: true
  # Run / BCLConvert - MultiQC mandatory options
  runfolder_name:
    label: runfolder name
    doc: |
      Required - used in naming run specific folder, reports and headings
    type: string


steps:
  # Split samplesheet by override cycles
  samplesheet_split_by_settings_step:
    label: Split samplesheet by settings step
    doc: |
      Samplesheet is split by the different input types.
      These are generally a difference in override cycles parameters or adapter trimming settings
      This then scatters multiple bclconvert workflows split by sample id
    in:
      samplesheet_csv:
        source: samplesheet
      out_dir:
        source: samplesheet_outdir
      settings_by_samples:
        source: settings_by_samples
      ignore_missing_samples:
        source: ignore_missing_samples
      samplesheet_format:
        source: samplesheet_output_format
    out:
      - id: samplesheets
      - id: samplesheet_outdir
    run: ../../../tools/custom-samplesheet-split-by-settings/1.0.0/custom-samplesheet-split-by-settings__1.0.0.cwl
  # Get midfixes
  get_batch_dirs:
    label: get batch directories
    doc: |
      Get the directory names of each of the directories we wish to scatter over
    in:
      samplesheets:
        source: samplesheet_split_by_settings_step/samplesheets
    out:
      - id: batch_names
    run: ../../../expressions/get-samplesheet-midfix-regex/1.0.0/get-samplesheet-midfix-regex__1.0.0.cwl
  # Scatter bclConvert over each samplesheet, produce an array of output directories
  bcl_convert_step:
    label: bcl convert
    doc: |
      BCLConvert is then scattered across each of the samplesheets.
    scatter: [samplesheet, output_directory]
    scatterMethod: dotproduct
    in:
      bcl_input_directory:
        source: bcl_input_directory
      output_directory:
        # This is the batch_name attribute used in the settings_by_samples
        source: get_batch_dirs/batch_names
      samplesheet:
        source: samplesheet_split_by_settings_step/samplesheets
      bcl_only_lane:
        source: bcl_only_lane_bcl_conversion
      first_tile_only:
        source: first_tile_only_bcl_conversion
      strict_mode:
        source: strict_mode_bcl_conversion
      bcl_sampleproject_subdirectories:
        source: bcl_sampleproject_subdirectories_bcl_conversion
      delete_undetermined_indices:
        source: delete_undetermined_indices_bcl_conversion
    out:
      - id: bcl_convert_directory_output
      - id: fastq_list_rows
    run: ../../../tools/bclConvert/3.7.5/bclConvert__3.7.5.cwl
  # Flatten the array of output fastq_list_rows.
  flatten_fastq_list_rows_array:
    label: flatten fastq list rows array
    doc: |
      fastq list rows is an array and bcl convert is from a directory output.
      This scatters the arrays to a single array
    in:
      arrayTwoDim: bcl_convert_step/fastq_list_rows
    out:
      - id: array1d
    run: ../../../expressions/flatten-array-fastq-list/1.0.0/flatten-array-fastq-list__1.0.0.cwl
  # Create a dummy file s.t the qc steps are auto-streamed
  create_dummy_file_step:
    label: create dummy file
    doc: |
      Intermediate step for letting multiqc-interop be placed in stream mode
    in: {}
    out:
      - id: dummy_file_output
    run: ../../../tools/custom-touch-file/1.0.0/custom-touch-file__1.0.0.cwl
  # Create a bclconvert specific report
  bclconvert_qc_step:
    label: bclconvert qc step
    doc: |
      The bclconvert qc step - from scatter this takes in an array of dirs
    # This allows us to run the bclconvert module over the array of directories
    requirements:
      DockerRequirement:
        dockerPull: umccr/multiqc-bclconvert:1.9
    in:
      input_directories:
        source: bcl_convert_step/bcl_convert_directory_output
      output_directory_name:
        source: runfolder_name
        valueFrom: "$(self)_bclconvert_multiqc"
      output_filename:
        source: runfolder_name
        valueFrom: "$(self)_bclconvert_multiqc.html"
      title:
        source: runfolder_name
        valueFrom: "UMCCR MultiQC BCLConvert report for $(self)"
      cl_config:
        valueFrom: |
         ${
            return JSON.stringify({"bclconvert": { "genome_size": "hg38_genome" }});
          }
      dummy_file:
        source: create_dummy_file_step/dummy_file_output
    out:
      - id: output_directory
    run: ../../../tools/multiqc/1.10.1/multiqc__1.10.1.cwl
  # Create run specific QC report (interop)
  interop_qc_step:
    label: interop qc step
    doc: |
      Run the multiqc by first also generating the interop files for use
    in:
      input_directory:
        source: bcl_input_directory
      output_directory_name:
        source: runfolder_name
        valueFrom: "$(self)_interop_multiqc"
      output_filename:
        source: runfolder_name
        valueFrom: "$(self)_interop_multiqc.html"
      title:
        source: runfolder_name
        valueFrom: "UMCCR MultiQC Interop report for $(self)"
      dummy_file:
        source: create_dummy_file_step/dummy_file_output
    out:
      - id: interop_multi_qc_out
    run: ../../../tools/multiqc-interop/1.2.1/multiqc-interop__1.2.1.cwl


outputs:
  split_sheets_dir:
    label: split sheets dir
    doc: |
      The directory containing the samplesheets used for each bcl convert
    type: Directory
    outputSource: samplesheet_split_by_settings_step/samplesheet_outdir
  split_sheets:
    label: split samplesheets
    doc: |
      List of samplesheets split by override cycles
    type: File[]
    outputSource: samplesheet_split_by_settings_step/samplesheets
  fastq_directories:
    label: Output fastq directores
    doc: |
      The outputs from the bclconvert-step
    type: Directory[]
    outputSource: bcl_convert_step/bcl_convert_directory_output
  fastq_list_rows:
    label: rows of fastq list csv file
    doc: |
      Contains the fastq list row schema for each of the output fastq files
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]
    outputSource: flatten_fastq_list_rows_array/array1d
  interop_multiqc_out:
    label: interop multiqc
    doc: |
      multiqc directory output that contains interop data
    type: Directory
    outputSource: interop_qc_step/interop_multi_qc_out
  bclconvert_multiqc_out:
    label: bclconvert multiqc
    doc: |
      multiqc directory output that contains bclconvert multiqc data
    type: Directory
    outputSource: bclconvert_qc_step/output_directory

