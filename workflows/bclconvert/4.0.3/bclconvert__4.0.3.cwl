cwlVersion: v1.1
class: Workflow

# Extensions
$namespaces:
  s: https://schema.org/
  ilmn-tes: https://platform.illumina.com/rdf/ica/resources/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: bclconvert--4.0.3
label: bclconvert v(4.0.3)
doc: |
  Documentation for bclconvert v4.0.3

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/bclconvert-run-configuration-expressions/2.0.0--4.0.3/bclconvert-run-configuration-expressions__2.0.0--4.0.3.cwljs
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  bclconvert_run_input_directory:
    label: bclconvert run input directory
    doc: |
      The input directory for BCLConvert
    type: Directory
  bclconvert_run_configuration:
    label: bclconvert run configuration
    doc: |
      The BCLConvert run configuration jsons
    type: ../../../schemas/bclconvert-run-configuration/2.0.0--4.0.3/bclconvert-run-configuration__2.0.0--4.0.3.yaml#bclconvert-run-configuration

steps:
  # Get requirements steps
  # Run bclconvert using the run configuration logic
  bcl_convert_run_step:
    # requirements:
    #   InlineJavascriptRequirement:
    #     expressionLib:
    #       - $include: ../../../typescript-expressions/get-fastq-list-rows-from-fastq-list-csv/1.0.0/get-fastq-list-rows-from-fastq-list-csv__1.0.0.cwljs
    #       - $include: ../../../typescript-expressions/samplesheet-builder/2.0.0--4.0.3/samplesheet-builder__2.0.0--4.0.3.cwljs
    #       - $include: ../../../typescript-expressions/bclconvert-run-configuration-expressions/2.0.0--4.0.3/bclconvert-run-configuration-expressions__2.0.0--4.0.3.cwljs
    #   ResourceRequirement:
    #     https://platform.illumina.com/rdf/ica/resources:tier: $(get_resource_hints_for_bclconvert_run(inputs, "ilmn-tes-resources-type"))
    #     https://platform.illumina.com/rdf/ica/resources:size: $(get_resource_hints_for_bclconvert_run(inputs, "ilmn-tes-resources-tier"))
    #     https://platform.illumina.com/rdf/ica/resources:type: $(get_resource_hints_for_bclconvert_run(inputs, "ilmn-tes-resources-size"))
    #     coresMin: $(get_resource_hints_for_bclconvert_run(inputs, "coresMin"))
    #     ramMin: $(get_resource_hints_for_bclconvert_run(inputs, "ramMin"))
    #   DockerRequirement:
    #     dockerPull: $(get_resource_hints_for_bclconvert_run(inputs, "dockerPull"))
    label: bcl convert samplesheet run step
    doc: |
      Run BCLConvert - but set run requirements based on whether the bcl_validate_sample_sheet_only parameter is set to true or not
    in:
      # Mandatory options
      bcl_input_directory:
        source: bclconvert_run_input_directory
      samplesheet:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "samplesheet");
          }
      output_directory:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "output_directory");
          }
      # Rest of the options
      bcl_conversion_threads:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "bcl_conversion_threads");
          }
      bcl_num_compression_threads:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "bcl_num_compression_threads");
          }
      bcl_num_decompression_threads:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "bcl_num_decompression_threads");
          }
      bcl_num_parallel_tiles:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "bcl_num_parallel_tiles");
          }
      bcl_only_lane:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "bcl_only_lane");
          }
      bcl_only_matched_reads:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "bcl_only_matched_reads");
          }
      bcl_sampleproject_subdirectories:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "bcl_sampleproject_subdirectories");
          }
      bcl_validate_sample_sheet_only:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "bcl_validate_sample_sheet_only");
          }
      exclude_tiles:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "exclude_tiles");
          }
      fastq_gzip_compression_level:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "fastq_gzip_compression_level");
          }
      first_tile_only:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "first_tile_only");
          }
      no_lane_splitting:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "no_lane_splitting");
          }
      num_unknown_barcodes_reported:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "num_unknown_barcodes_reported");
          }
      output_legacy_stats:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "output_legacy_stats");
          }
      run_info:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "run_info");
          }
      sample_name_column_enabled:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "sample_name_column_enabled");
          }
      shared_thread_odirect_output:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "shared_thread_odirect_output");
          }
      strict_mode:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "strict_mode");
          }
      tiles:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "tiles");
          }
      ora_reference:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "ora_reference");
          }
      fastq_compression_format:
        source: bclconvert_run_configuration
        valueFrom: |
          ${
            return get_attribute_from_bclconvert_run_configuration(self, "fastq_compression_format");
          }
    out:
      - id: bcl_convert_directory_output
      - id: fastq_list_rows
      - id: samplesheet_out
      - id: run_info_out
    run: ../../../tools/bcl-convert/4.0.3/bcl-convert__4.0.3.cwl


outputs:
  bcl_convert_directory_output:
    label: bcl convert directory output
    doc: |
      Directories to output fastq files
    outputSource: bcl_convert_run_step/bcl_convert_directory_output
    type: Directory
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Directories to fastq list rows
      Optional output since this workflow may be used as a validation workflow
    outputSource: bcl_convert_run_step/fastq_list_rows
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
  samplesheet_out:
    label: samplesheet out
    doc: |
      The samplesheet file used by the workflow
    outputSource: bcl_convert_run_step/samplesheet_out
    type: File
  run_info_out:
    label: run info out
    doc: |
      The run info file used by the workflow
    outputSource: bcl_convert_run_step/run_info_out
    type: File