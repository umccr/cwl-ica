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
  InlineJavascriptRequirement:
    expressionLib:
      - var pick_value_first_non_null = function(input_array){
          /*
          Iterate through input_array, return first non null input
          Replacement for pickValue of CWL 1.2
          */
          var return_val = null;
          var iterator = 0;
          while (return_val === null) {
            return_val = input_array[iterator];
            iterator += 1
          }
          return return_val;
        }
      - var get_first_string_or_second_string_with_suffix = function(input_obj, suffix){
          /*
          Determine if first input has been determined.
          Fall back to second with suffix otherwise
          */
          return pick_value_first_non_null([input_obj[0], input_obj[1] + suffix]);
        }
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
  # MultiQC mandatory options
  runfolder_name:
    label: runfolder name
    doc: |
      Required - used in naming run specific folder, reports and headings
    type: string
  # MultiQC optional args
  outdir_multiqc:
    label: outdir multiqc
    doc: |
      Optional - Output directory for the multiqc command
      If not set defaults to runfolder-name + "_multiqc/"
    type: string?


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
      - samplesheets
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
      - batch_names
    run: ../../../expressions/get-samplesheet-midfix-regex/1.0.0/get-samplesheet-midfix-regex__1.0.0.cwl
  # Scatter bclConvert over each samplesheet, produce an array of output directories
  bcl_convert_step:
    label: Run BCL Convert workflow
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
      - bcl_convert_directory_output
      - fastq_list_rows
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
      - array1d
    run: ../../../expressions/flatten-array-fastq-list/1.0.0/flatten-array-fastq-list__1.0.0.cwl
  # Create rn specific QC report (interop)
  # Create a dummy file s.t the qc step is auto-streamed
  create_dummy_file_step:
    label: Create dummy file
    doc: |
      Intermediate step for letting multiqc-interop be placed in stream mode
    in: {}
    out:
      - dummy_file_output
    run: ../../../tools/create-dummy-file/1.0.0/create-dummy-file__1.0.0.cwl
  qc_step:
    label: Multiqc Step
    doc: |
      Run the multiqc by first also generating the interop files for use
    in:
      input_directory:
        source: bcl_input_directory
      output_directory:
        source: [outdir_multiqc, runfolder_name]
        linkMerge: merge_flattened
        valueFrom: $(get_first_string_or_second_string_with_suffix(self, "_multiqc"))
      output_filename:
        source: runfolder_name
        valueFrom: "$(self)_multiqc.html"
      title:
        source: runfolder_name
        valueFrom: "UMCCR MultiQC report for $(self)"
      dummy_file:
        source: create_dummy_file_step/dummy_file_output
    out:
      - interop_multi_qc_out
    run: ../../../tools/multiqc-interop/1.2.1/multiqc-interop__1.2.1.cwl


outputs:
  split_sheets:
    label: samplesheets
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
  interop_multi_qc_out:
    label: interop multiqc
    doc: |
      multiqc directory output that contains interop data
    type: Directory
    outputSource: qc_step/interop_multi_qc_out
