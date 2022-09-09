cwlVersion: v1.1
class: ExpressionTool

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
id: get-custom-output-dir-entry-for-tso500-with-post-processing--2.0.1
label: get-custom-output-dir-entry-for-tso500-with-post-processing v(2.0.1)
doc: |
    Create a custom-output-dir-entry 2.0.1 schema for the files and directories in the tso500 post-processing pipeline.

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/custom-output-dir-entry/2.0.1/custom-output-dir-entry__2.0.1.yaml
  InlineJavascriptRequirement:
    expressionLib:
      # Type 1 of the custom-output-dir-entry input schema - used for align_collapse_fusion_caller_dir, merged_annotation_dir and stitched_realigned inputs
      - var get_custom_output_dir_entry_from_directory_and_file_str_list = function(dir_obj, files_list_str, collection_name, copy_method){
          /*
          Create the schema object with the directory, files_list_str and the collection name and copy method
          */
          return {
            "collection_name":collection_name,
            "copy_method":copy_method,
            "dir":dir_obj,
            "files_list_str":files_list_str
          };
        }
      # Type 2 of the custom-output-dir-entry input schema - used for coverage_qc_file input and dragen_metrics_compressed_json_file input
      - var get_custom_output_dir_entry_from_file_list = function(file_list, collection_name, copy_method){
          /*
          Create the schema object with the file list, collection name and copy method
          */
          return {
            "collection_name":collection_name,
            "copy_method":copy_method,
            "file_list":file_list
          };
        }
      # Type 3 of the custom-output-dir-entry input schema - used for vcf_tarball, compressed_metrics_tarball and compressed_reporting_tarball inputs
      - var get_custom_output_dir_entry_from_tarball = function(tarball_obj, files_list_str, collection_name, copy_method){
          /*
          Create the schema object with the tarball, list of files, and the collection name and copy method
          */
          return {
            "collection_name":collection_name,
            "copy_method":copy_method,
            "files_list_str":files_list_str,
            "tarball":tarball_obj
          };
        }
      # Actual script to collect files
      - var get_custom_output_dir_entry_list = function(inputs){
          /*
          Get the entry list by first initialising with the results directory,
          Then collect the sample post processing pipeline subdirectories
          */
          var tso500_entry_list = [
                get_custom_output_dir_entry_from_directory_and_file_str_list(inputs.results_dir,
                                                                             [
                                                                               "MetricsOutput.tsv",
                                                                               "dsdm.json"
                                                                             ],
                                                                             null,
                                                                             "top_dir"),
                get_custom_output_dir_entry_from_file_list([inputs.samplesheet_csv],
                                                           null,
                                                           "top_dir")
          ];

          /*
          Iterate through sample output directories
          */
          for (var sample_dir_iter=0; sample_dir_iter < inputs.per_sample_post_processing_output_dirs.length; sample_dir_iter++){
            /*
            Easier to initialise the sample subdirectory object
            */
            var sample_dir = inputs.per_sample_post_processing_output_dirs[sample_dir_iter];

            /*
            Append the list of directories
            */
            tso500_entry_list.push(get_custom_output_dir_entry_from_directory_and_file_str_list(sample_dir, null, sample_dir.basename, "sub_dir"));
          }

          /*
          Return the dir entry list
          */
          return tso500_entry_list;
        }

inputs:
  # The results directory and the array of directories for each of the samples
  per_sample_post_processing_output_dirs:
    label: per sample post processing output dirs
    doc: |
      The per sample post processing output directories
    type: Directory[]
  results_dir:
    label: results dir
    doc: |
      The results directory from the tso500 workflow
    type: Directory
  samplesheet_csv:
    label: samplesheet
    doc: |
      The intermediate samplesheet
    type: File


outputs:
  tso500_output_dir_entry_list:
    label: tso500 output dir entry list
    doc: |
      The list of custom output dir entry schemas to use as input to custom-dir-entry list
    type: ../../../schemas/custom-output-dir-entry/2.0.1/custom-output-dir-entry__2.0.1.yaml#custom-output-dir-entry[]

expression: >-
  ${
    return {
            "tso500_output_dir_entry_list": get_custom_output_dir_entry_list(inputs)
           };
   }
