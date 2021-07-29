cwlVersion: v1.1
class: ExpressionTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: http://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: get-tso500-outputs-per-sample--1.0.0
label: get-tso500-outputs-per-sample v(1.0.0)
doc: |
    Documentation for get-tso500-outputs-per-sample v1.0.0

# Requirements
requirements:
  LoadListingRequirement:
    loadListing: deep_listing
  InlineJavascriptRequirement:
    expressionLib:
      # Regex helper functions
      - var replace_upper_case = function(x, y){
          return "_" + y.toLowerCase();
        }
      - var intermediate_dir_name_to_underscore = function(analysis_dir_basename){
          /*
          Converts AlignCollapseFusionCaller to align_collapse_fusion_caller
          */
          return analysis_dir_basename.replace(/(?:^|\.?)([A-Z])/g, replace_upper_case).replace(/^_/, "");
        }
      # Get outputs for each task
      - var get_analysis_outputs = function(analysis_output_dir, sample_output){
          /*
          Iterate through the analysis directory
          extend sample output dict with dirs
          */
          for (var analysis_dir_iter=0; analysis_dir_iter < analysis_output_dir.listing.length; analysis_dir_iter++){
            /*
            Skip any items in the listing that arent directories in the output folder
            */
            if ( analysis_output_dir.listing[analysis_dir_iter].class !== "Directory" ){
              continue;
            }

            /*
            Now iterate through items in the intermediate directory
            Trying to find a directory with name that matches the sample_id
            */
            for (var intermediate_dir_iter=0; intermediate_dir_iter < analysis_output_dir.listing[analysis_dir_iter].listing.length; intermediate_dir_iter++){
              /*
              Skip any items in the intermediate dir that arent also directories
              */
              if ( analysis_output_dir.listing[analysis_dir_iter].listing[intermediate_dir_iter].class !== "Directory" ){
                continue;
              }

              /*
              Skip any items in the task dir that dont match the sample id
              */
              if ( analysis_output_dir.listing[analysis_dir_iter].listing[intermediate_dir_iter].basename !== sample_output["sample_id"] ){
                continue;
              }

              /*
              Update naming on the output dir, AlignCollapseFusionCaller becomes align_collapse_fusion_caller
              */
              var output_name = intermediate_dir_name_to_underscore(analysis_output_dir.listing[analysis_dir_iter].basename) + "_dir";

              /*
              Add folder output to sample output object
              */
              sample_output[output_name] = analysis_output_dir.listing[analysis_dir_iter].listing[intermediate_dir_iter];
              }
            }
          return sample_output;
        }
      - var get_reporting_outputs = function(reporting_output_dir, sample_output){
          /*
          Iterate through the reporting directory
          extend sample output dict with dirs
          Almost identical to the get_analysis_output function but also caputes the sample analysis results json
          */
          for (var reporting_dir_iter=0; reporting_dir_iter < reporting_output_dir.listing.length; reporting_dir_iter++){
            /*
            Skip any items in the listing that arent directories in the output folder
            */
            if ( reporting_output_dir.listing[reporting_dir_iter].class !== "Directory" ){
              continue;
            }

            /*
            Now iterate through items in the intermediate directory
            Trying to find a directory with name that matches the sample_id
            */
            for (var intermediate_dir_iter=0; intermediate_dir_iter < reporting_output_dir.listing[reporting_dir_iter].listing.length; intermediate_dir_iter++){
              /*
              Heres where things differenciate between the analysis and reporting, we want to collect SampleAnalysisResults
              */
              if ( reporting_output_dir.listing[reporting_dir_iter].basename === "SampleAnalysisResults" ){
                if ( reporting_output_dir.listing[reporting_dir_iter].listing[intermediate_dir_iter].class === "File" ){
                  /*
                  Find the file __sample_name__ + _SampleAnalysisResults.json
                  */
                  if ( reporting_output_dir.listing[reporting_dir_iter].listing[intermediate_dir_iter].basename === sample_output["sample_id"] + "_SampleAnalysisResults.json" ){
                    /*
                    Add the file
                    */
                    sample_output["sample_analysis_results_json"] = reporting_output_dir.listing[reporting_dir_iter].listing[intermediate_dir_iter];
                  }
                }
              }
              /*
              Continue collecting suboutput directories as per usual
              */

              /*
              Skip any items in the intermediate dir that arent also directories
              */
              if ( reporting_output_dir.listing[reporting_dir_iter].listing[intermediate_dir_iter].class !== "Directory" ){
                continue;
              }

              /*
              Skip any items in the task dir that dont match the sample id
              */
              if ( reporting_output_dir.listing[reporting_dir_iter].listing[intermediate_dir_iter].basename !== sample_output["sample_id"] ){
                continue;
              }

              /*
              Update naming on the output dir, AlignCollapseFusionCaller becomes align_collapse_fusion_caller
              */
              var output_name = intermediate_dir_name_to_underscore(reporting_output_dir.listing[reporting_dir_iter].basename) + "_dir";

              /*
              Add folder output to sample output object
              */
              sample_output[output_name] = reporting_output_dir.listing[reporting_dir_iter].listing[intermediate_dir_iter];
              }
            }
          return sample_output;
        }
      - var get_results_outputs = function(results_dir, sample_output){
          /*
          Iterate through the results directory
          Find directory with basename matching the sample name
          */
          for (var results_dir_iter=0; results_dir_iter < results_dir.listing.length; results_dir_iter++){
            /*
            Skip any items in the listing that arent directories in the output folder
            */
            if ( results_dir.listing[results_dir_iter].class !== "Directory" ){
              continue;
            }

            /*
            Skip any directory that doesn't match the sample id
            */
            if ( results_dir.listing[results_dir_iter].basename !== sample_output["sample_id"] ){
              continue;
            }

            /*
            Append to output
            */
            sample_output["results_dir"] = results_dir.listing[results_dir_iter];
          }
          /*
          Return outputs
          */
          return sample_output;
        }
      # Main function
      - var get_outputs_per_sample = function(tso500_samples, analysis_output_dir, reporting_output_dir, results_output_dir){
          /*
          Get outputs per sample,
          iterate through each of the directories for each sample name
          and pull out the appropriate attributes
          */

          /*
          Initialise list
          */
          var outputs_per_sample = [];

          /*
          Iterate through samples by their names
          */
          for (var sample_input_iter=0; sample_input_iter < tso500_samples.length; sample_input_iter++){
            /*
            Initialise the sample output
            */
            var sample_output = {
              "sample_id":tso500_samples[sample_input_iter].sample_id,
              "sample_name":tso500_samples[sample_input_iter].sample_name
            };

            /*
            Get outputs from the analysis dir
            */
            sample_output = get_analysis_outputs(analysis_output_dir, sample_output);

            /*
            Get outputs from the reporting dir
            */
            sample_output = get_reporting_outputs(reporting_output_dir, sample_output);

            /*
            Get outputs from the results dir
            */
            sample_output = get_results_outputs(results_output_dir, sample_output);

            /*
            Append to outputs
            */
            outputs_per_sample.push(sample_output);
          }

          /*
          Return outputs
          */
          return outputs_per_sample;
        }
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/tso500-outputs-by-sample/1.0.0/tso500-outputs-by-sample__1.0.0.yaml
      - $import: ../../../schemas/tso500-sample/1.0.0/tso500-sample__1.0.0.yaml

inputs:
  tso500_samples:
    label: tso500 samples
    doc: |
      The tso500 sample objects
    type: ../../../schemas/tso500-sample/1.0.0/tso500-sample__1.0.0.yaml#tso500-sample[]
  analysis_output_dir:
    label: analysis output dir
    doc: |
      Analysis output directory
    type: Directory
  reporting_output_dir:
    label: reporting output dir
    doc: |
      reporting output directory
    type: Directory
  results_output_dir:
    label: results output dir
    doc: results output dir
    type: Directory

outputs:
  outputs_by_sample:
    label: outputs by sample
    doc: |
      tso500 outputs by sample
    type: ../../../schemas/tso500-outputs-by-sample/1.0.0/tso500-outputs-by-sample__1.0.0.yaml#tso500-outputs-by-sample[]

expression: >-
  ${
    return {"outputs_by_sample": get_outputs_per_sample(inputs.tso500_samples, inputs.analysis_output_dir, inputs.reporting_output_dir, inputs.results_output_dir)};
  }

