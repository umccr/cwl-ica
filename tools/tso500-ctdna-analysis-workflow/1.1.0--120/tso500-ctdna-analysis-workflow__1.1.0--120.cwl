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
id: tso500-ctdna-analysis-workflow--1.1.0.120
label: tso500-ctdna-analysis-workflow v(1.1.0.120)
doc: |
    Runs the ctDNA analysis workflow v(1.1.0.120)

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: fpga
        ilmn-tes:resources/size: medium
        coresMin: 16
        ramMin: 240000
    DockerRequirement:
        dockerPull: "239164580033.dkr.ecr.us-east-1.amazonaws.com/acadia-500-liquid-workflow-aws:ruo-1.1.0.120"
        #dockerPull: ubuntu:latest

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/tso500-sample/1.0.0/tso500-sample__1.0.0.yaml
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
      - $import: ../../../schemas/tso500-outputs-by-sample/1.0.0/tso500-outputs-by-sample__1.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      # Standard
      - var abs_path = function(rel_path) {
          /*
          Return the absolute path of a relative path
          */
          return runtime.outdir + "/" + rel_path;
        }
      # Paths to inbuilt files
      - var get_cromwell_path = function() {
          return "/opt/cromwell/cromwell.jar";
        }
      - var get_analysis_wdl_path = function() {
          return "/opt/illumina/wdl/AnalysisWorkflow.wdl";
        }
      # Paths to inline directories
      - var get_scratch_mount = function() {
          return "/scratch";
        }
      - var get_resources_dir = function() {
          return get_scratch_mount() + "/" + "resources";
        }
      - var get_analysis_dir = function() {
          return get_scratch_mount() + "/" + "analysis_workflow";
        }
      - var get_output_dir = function() {
          return inputs.output_dirname;
        }
      - var get_logs_intermediates_dir = function() {
          return get_analysis_dir() + "/" + "analysis_outputs"
        }
      - var get_logs_intermediates_output_dir = function() {
          return get_output_dir() + "/" + "analysis_outputs"
        }
      - var get_fastq_dir_path = function() {
          return "fastqs";
        }
      - var get_dest_fastq_paths = function(sample_id, sample_number, input_fastq_list_rows){
          /*
          Return a list of entry/entryname dicts to be mounted for a given sample
          */

          /*
          Initialise an array of dicts
          */
          var dest_fastq_paths = [];

          /*
          Iterate through each fastq list row
          Mount each read1 file with the following nomenclature

          Note key-values are squished together otherwise yaml has a hissy-fit
          */

          for (var i = 0; i < input_fastq_list_rows.length; i++){
            /*
            Get the lane id
            */
            var lane = input_fastq_list_rows[i].lane;

            /*
            Set the basenames for each file
            */
            var read_1_base_name = sample_id + "_S" + String(sample_number) + "_L" + String(lane).padStart(3, '0') + "_R1_" + "001.fastq.gz";
            var read_2_base_name = sample_id + "_S" + String(sample_number) + "_L" + String(lane).padStart(3, '0') + "_R2_" + "001.fastq.gz";

            /*
            Set the mount points for each file
            */
            var read_1_dest_path = get_fastq_dir_path() + "/" + sample_id + "/" + read_1_base_name;
            var read_2_dest_path = get_fastq_dir_path() + "/" + sample_id + "/" + read_2_base_name;

            /*
            Extend list with read 1 and read 2 fastq file objects at the set mountpoints
            */
            dest_fastq_paths = dest_fastq_paths.concat([
              read_1_dest_path, 
              read_2_dest_path
            ]);
          }

          /*
          Return the list of links for this sample
          */
          return dest_fastq_paths;
        }
      # Paths to inline files
      - var get_input_json_path = function() {
          return "input.json";
        }
      - var get_run_cromwell_script_path = function() {
          return "run_cromwell.sh";
        }
      # Paths to outputs
      - var get_dsdm_json_path = function() {
          return get_logs_intermediates_output_dir() + "/" + "Contamination" + "/" + "dsdm.json"
        }
      - var get_dragen_license_key_folder = function() {
          /*
          Returns the analysis folder
          */
          return "license";
        }
      - var get_dragen_license_instance_folder = function() {
          /*
          Returns the dragen license folder
          */
          return "/opt/instance-identity";
        }
      - var get_dragen_license_path = function() {
          /*
          Returns the file to the dragen license
          */
          return get_dragen_license_key_folder() + "/" + "dragen_license.txt";
        }
      # Miscell
      - var get_sample_ids = function() {
          /*
          Iterate through each item in the tso500_samples input and return the sample_id attribute
          */

          /*
          Initialise sample ids list
          */
          var sample_ids = []

          /*
          Iterate through inputs
          */
          for (var i=0; i < inputs.tso500_samples.length; i++){
            sample_ids.push(inputs.tso500_samples[i].sample_id);
          }

          /*
          Return joined as comma separated values
          */
          return sample_ids.join(",");
        }
      # Path contents
      - var get_input_json_content = function(){
          /*
          Create a json file based on inputs and then stringify
          */
          return JSON.stringify({
                   "AnalysisWorkflow.sampleIdentifiers":get_sample_ids(),
                   "AnalysisWorkflow.fastqFolder":abs_path(get_fastq_dir_path()),
                   "AnalysisWorkflow.dsdmFile":inputs.fastq_validation_dsdm.path,
                   "AnalysisWorkflow.analysisFolder":get_analysis_dir(),
                   "AnalysisWorkflow.logsIntermediatesFolder":get_logs_intermediates_dir(),
                   "AnalysisWorkflow.resourceFolder":get_resources_dir(),
                   "AnalysisWorkflow.dragenLicenseKeyFolder":abs_path(get_dragen_license_key_folder()),
                   "AnalysisWorkflow.dragenLicenseInstanceFolder":get_dragen_license_instance_folder()
                 });
        }
      # Linking contents
      - var string_bash_array_contents = function(string_array){
          /*
          String together elements inside a bash array
          */
          return string_array.join(" \\\n    ");
        }
      - var get_array_of_fastq_paths = function(is_dest){
          /*
          Get the array of fastq paths, if is_dest is set to true then 
          the destination path is returned instead
          */
        
          var fastq_paths = [];
        
          for (var i = 0; i < inputs.tso500_samples.length; i++){
            /*
            Extend the listing for each sample present
            First we must get matching fastq list rows as inputs
            */
            var sample_id = inputs.tso500_samples[i].sample_id;
            var sample_name = inputs.tso500_samples[i].sample_name;
            var sample_number = i + 1;
            
            /*
            Iterate over the input fastq list rows and match rgsm values to the sample_name of the tso500 sample
            */
            var input_fastq_list_rows = [];
            for (var j = 0; j < inputs.fastq_list_rows.length; j++){
              /*
              Append fastq list rows items with matching rgsm values
              */
              if (inputs.fastq_list_rows[j].rgsm === sample_name){
                /*
                Append fastq list row
                */
                input_fastq_list_rows.push(inputs.fastq_list_rows[j]);
              }
            }
        
            if (is_dest === true) {
              /*
              Now link according to the sample id
              */
              fastq_paths = fastq_paths.concat(get_dest_fastq_paths(sample_id, sample_number, input_fastq_list_rows));
            } else {
              /*
              Just iterate over the fastq list rows and return the path attribute for each read pair.
              */
              for (var i = 0; i < input_fastq_list_rows.length; i++){
                fastq_paths.push(input_fastq_list_rows[i].read_1.path);
                fastq_paths.push(input_fastq_list_rows[i].read_2.path);
              }
            }
          }
          
          return fastq_paths;
        }
      - var get_fastq_src_paths_array = function(){
          /*
          Get the array of src paths
          */
          return get_array_of_fastq_paths(false);
        }
      - var get_fastq_dest_paths_array = function(){
          /*
          Get the array of src paths
          */
          return get_array_of_fastq_paths(true);
        }

  InitialWorkDirRequirement:
    listing:
      - |
        ${
          /*
          Initialise listing with input jsons and cromwell script and run folder files
          */
          var e = [
                    /*
                    Input json
                    */
                    {
                     "entryname": get_input_json_path(),
                     "entry": get_input_json_content()
                    }
                  ];
  
          /*
          Check if dragen license is added
          */
          if ( inputs.dragen_license_key !== null ){
            e.push({
                      "entryname": get_dragen_license_path(),
                      "entry": inputs.dragen_license_key
                   });
          }

          /*
          Return entries
          */
          return e;
        }
      - entryname: "$(get_run_cromwell_script_path())"
        entry: |
          #!/usr/bin/env bash
          
          # Set up to fail
          set -euo pipefail
          
          # Create the directories
          echo "create analysis dirs" 1>&2
          mkdir --parents \\
            "$(get_output_dir())" \\
            "$(get_resources_dir())" \\
            "$(get_analysis_dir())" \\
            "$(get_fastq_dir_path())"
          echo "completed creation of analysis dirs" 1>&2
          
          # Copy over the resources directory to the scratch mount
          echo "start copy resources dir to scratch mount" 1>&2
          cp -r "$(inputs.resources_dir.path)/." "$(get_resources_dir())/"
          echo "completed copy of resources dir" 1>&2
          
          # Link over the fastq files into the designated fastq folder
          echo "start linking of fastq files to fastq directory" 1>&2
          fastq_src_paths_array=( \\
              $(string_bash_array_contents(get_fastq_src_paths_array())) \\
          )
          fastq_dest_paths_array=( \\
              $(string_bash_array_contents(get_fastq_dest_paths_array())) \\
          )
          fastq_files_iter_range="\$(expr \${#fastq_src_paths_array[@]} - 1)"
          
          for i in \$(seq 0 \${fastq_files_iter_range}); do
            # First create the directory needed
            mkdir -p "\$(dirname "\${fastq_dest_paths_array[$i]}")"
            ln -s "\${fastq_src_paths_array[$i]}" "\${fastq_dest_paths_array[$i]}"
          done
          
          echo "completed linking of fastq files to fastq directory" 1>&2
          
          # Start the analysis workflow task
          echo "start analysis workflow task" 1>&2
          java \\
            -DLOG_MODE=pretty \\
            -DLOG_LEVEL=INFO \\
            -jar "$(get_cromwell_path())" \\
            run \\
              --inputs "$(get_input_json_path())" \\
              "$(get_analysis_wdl_path())"
          echo "end analysis workflow task" 1>&2
          
          # Start copying outputs to the output directory
          echo "copying outputs to output dir" 1>&2
          cp -r "$(get_analysis_dir())/." "$(get_output_dir())/"
          echo "completed copy of outputs" 1>&2
          
          # Tar up the crowell executions folder
          echo "tarring up cromwell files" 1>&2
          tar \\
            --remove-files \\
            --create \\
            --gzip \\
            --file "cromwell-executions.tar.gz" \\
            "cromwell-executions"/
          echo "completed tarring of cromwell files" 1>&2
          
          # Unlink all fastq files from the fastq directory
          echo "unlinking all fastq files from fastq directory" 1>&2
          for i in \$(seq 0 \${fastq_files_iter_range}); do
            unlink "\${fastq_dest_paths_array[$i]}"
          done
          echo "completed unlinking of all fastq files from fastq directory" 1>&2


baseCommand: [ "bash" ]

arguments:
  # Run the cromwell script
  - valueFrom: "$(get_run_cromwell_script_path())"
    position: 1

inputs:
  tso500_samples:
    label: tso500 samples
    doc: |
      A list of tso500 samples each element has the following attributes:
      * sample_id
      * sample_type
      * pair_id
    type: ../../../schemas/tso500-sample/1.0.0/tso500-sample__1.0.0.yaml#tso500-sample[]
  fastq_list_rows:
    label: fastq list rows
    doc: |
      A list of fastq list rows where each element has the following attributes
      * rgid  # Not used
      * rgsm
      * rglb  # Not used
      * read_1
      * read_2
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]
  # Reference inputs
  resources_dir:
    # No input binding required, directory path is placed in input.json
    label: resources dir
    doc: |
      The directory of resources
    type: Directory
  fastq_validation_dsdm:
    # No input binding required, fastq validation dsdm path is placed in input.json
    label: fastq validation dsdm
    doc: |
      Output of demux workflow. Contains steps for each sample id to run
    type: File
  dragen_license_key:
    label: dragen license key
    doc: |
      File containing the dragen license
    type: File?
  output_dirname:
    label: output dirname
    doc: |
      Output directory name (optional)
    type: string?
    default: "analysis_workflow"

outputs:
  output_dir:
    label: output directory
    doc: |
      Output files
    type: Directory
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())"
  contamination_dsdm:
    label: contamination dsdm
    doc: |
      Contamination dsdm json, used as input for Reporting task
    type: File
    outputBinding:
      glob: "$(get_dsdm_json_path())"
  # Task directories
  # Each output is a step in the wdl task workflow
  align_collapse_fusion_caller_dir:
    label: align collapse fusion caller dir
    doc: |
      Intermediate output directory for align collapse fusion caller step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/AlignCollapseFusionCaller"
  annotation_dir:
    label: annotation dir
    doc: |
      Intermediate output directory for annotation step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/Annotation"
  cnv_caller_dir:
    label: cnv caller dir
    doc: |
      Intermediate output directory for cnv caller step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/CnvCaller"
  contamination_dir:
    label: contamination dir
    doc: |
      Intermediate output directory for contamination step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/Contamination"
  dna_fusion_filtering_dir:
    label: dna fusion filtering dir
    doc: |
      Intermediate output directory for dna fusion filtering step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/DnaFusionFiltering"
  dna_qc_metrics_dir:
    label: dna qc metrics dir
    doc: |
      Intermediate output directory for dna qc metrics step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/DnaQCMetrics"
  max_somatic_vaf_dir:
    label: max somatic vaf dir
    doc: |
      Intermediate output directory for max somatic vaf step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/MaxSomaticVaf"
  merged_annotation_dir:
    label: merged annotation dir
    doc: |
      Intermediate output directory for merged annotation step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/MergedAnnotation"
  msi_dir:
    label: msi dir
    doc: |
      Intermediate output directory for msi step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/Msi"
  phased_variants_dir:
    label: phased variants dir
    doc: |
      Intermediate output directory for phased variants step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/PhasedVariants"
  small_variant_filter_dir:
    label: small variant filter dir
    doc: |
      Intermediate output directory for small variants filter step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/SmallVariantFilter"
  stitched_realigned_dir:
    label: stitched realigned dir
    doc: |
      Intermediate output directory for stitched realigned step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/StitchedRealigned"
  tmb_dir:
    label: tmb dir
    doc: |
      Intermediate output directory for tmb step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/Tmb"
  variant_caller_dir:
    label: variant caller dir
    doc: |
      Intermediate output directory for variant caller step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/VariantCaller"
  variant_matching_dir:
    label: variant matching dir
    doc: |
      Intermediate output directory for variant matching step
    type: Directory?
    outputBinding:
      glob: "$(get_logs_intermediates_output_dir())/VariantMatching"

successCodes:
  - 0
