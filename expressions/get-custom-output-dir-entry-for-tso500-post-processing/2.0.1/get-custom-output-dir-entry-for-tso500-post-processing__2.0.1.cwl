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
id: get-custom-output-dir-entry-for-tso500-post-processing--2.0.1
label: get-custom-output-dir-entry-for-tso500-post-processing v(2.0.1)
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

inputs:
  # The name of the same for find the file names
  sample_id:
    label: sample id
    doc: |
      The sample id, important for extracting the bam files
    type: string
  # Type 1 inputs
  align_collapse_fusion_caller_dir:
    label: align collapse fusion caller directory
    doc: |
      The align collapse fusion caller directory
      We collect the following outputs from this directory -
      * The evidence bam file
      * The raw bam file
      * The clean-stitched bam file
    type: Directory
  combined_variant_output_dir:
    label: combined variant output dir
    doc: |
      From this directory we collect the following outputs:
      * CombinedVariantOutput.tsv
    type: Directory
  merged_annotation_dir:
    label: merged annotation dir
    doc: |
      The merged annotation dir
      From this directory we collect the following outputs:
      * The MergedSmallVariantsAnnotated compressed json file
    type: Directory
  tmb_dir:
    label: tmb dir
    doc: |
      The TMB directory
      From this directory we collect the following outputs:
      * The TMB Trace tsv
    type: Directory
  variant_caller_dir:
    label: Variant caller directory
    doc: |
      The variant caller directory
      We collect the following outputs from this directory -
      * The clean-stitched bam file
    type: Directory
  multiqc_dir:
    label: multiqc dir
    doc: |
      The multiqc output directory
      We copy the entire directory into this directory as a subdirectory
    type: Directory
  # Type 2 inputs
  coverage_qc_file:
    label: coverage qc file
    doc: |
      The output from the make coverage qc step
    type: File
  dragen_metrics_compressed_json_file:
    label: dragen metrics compressed json file
    doc: |
      Compressed dragen metrics file
    type: File
  cnv_caller_bin_counts_compressed_json_file:
    label: cnv caller counts compressed json file
    doc: |
      Compressed bin counts file
    type: File
  fusion_csv:
    label: fusion csv
    doc: |
      The fusion csv file
    type: File
  # Type 3 inputs
  vcf_tarball:
    label: vcf tarball
    doc: |
      The tarball of vcf files
    type: File
  compressed_metrics_tarball:
    label: compressed metrics tarball
    doc: |
      The tarball of compressed metrics files (and other csv files)
      * tmb_trace_tsv
      * fragment_length_hist_csv
      * fusion csv
      * output coverage qc file (compressed version)
      * output target region qc file (compressed version)
    type: File
  compressed_reporting_tarball:
    label: compressed reporting tarball
    doc: |
      The tarball of compressed reporting files
      * msi_json
      * tmb_json
      * Sample analysis results json
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
            "tso500_output_dir_entry_list": [
              get_custom_output_dir_entry_from_directory_and_file_str_list(inputs.multiqc_dir, 
                                                                           null, 
                                                                           inputs.multiqc_dir.basename, 
                                                                           "sub_dir"),
              get_custom_output_dir_entry_from_directory_and_file_str_list(inputs.align_collapse_fusion_caller_dir,
                                                                           [
                                                                             inputs.sample_id + ".bam",
                                                                             inputs.sample_id + ".bam.bai",
                                                                             inputs.sample_id + ".bam.md5sum",
                                                                             "evidence." + inputs.sample_id + ".bam",
                                                                             "evidence." + inputs.sample_id + ".bam.bai"
                                                                           ],
                                                                           null,
                                                                           "top_dir"),
              get_custom_output_dir_entry_from_directory_and_file_str_list(inputs.combined_variant_output_dir,
                                                                           [
                                                                             inputs.sample_id + "_CombinedVariantOutput.tsv"
                                                                           ],
                                                                           null,
                                                                           "top_dir"),
              get_custom_output_dir_entry_from_directory_and_file_str_list(inputs.merged_annotation_dir,
                                                                           [
                                                                             inputs.sample_id + "_MergedSmallVariantsAnnotated.json.gz",
                                                                             inputs.sample_id + "_MergedSmallVariantsAnnotated.json.gz.jsi"
                                                                           ],
                                                                           null,
                                                                           "top_dir"),
              get_custom_output_dir_entry_from_directory_and_file_str_list(inputs.tmb_dir,
                                                                           [
                                                                             inputs.sample_id + "_TMB_Trace.tsv"
                                                                           ],
                                                                           null,
                                                                           "top_dir"),
              get_custom_output_dir_entry_from_directory_and_file_str_list(inputs.variant_caller_dir,
                                                                           [
                                                                             inputs.sample_id + ".cleaned.stitched.bam",
                                                                             inputs.sample_id + ".cleaned.stitched.bam.bai"
                                                                           ],
                                                                           null,
                                                                           "top_dir"),
              get_custom_output_dir_entry_from_file_list([
                                                           inputs.coverage_qc_file,
                                                           inputs.dragen_metrics_compressed_json_file,
                                                           inputs.cnv_caller_bin_counts_compressed_json_file,
                                                           inputs.fusion_csv
                                                         ],
                                                         null,
                                                         "top_dir"),
              get_custom_output_dir_entry_from_tarball(inputs.vcf_tarball, null, null, "top_dir"),
              get_custom_output_dir_entry_from_tarball(inputs.compressed_metrics_tarball, null, null, "top_dir"),
              get_custom_output_dir_entry_from_tarball(inputs.compressed_reporting_tarball, null, null, "top_dir")
           ]
    };
  }
