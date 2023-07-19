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
        dockerPull: "239164580033.dkr.ecr.us-east-1.amazonaws.com/tso500-liquid-ica-wrapper:1.2.0.1"

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/tso500-sample/1.2.0/tso500-sample__1.2.0.yaml
      - $import: ../../../schemas/tso500-outputs-by-sample/1.0.0/tso500-outputs-by-sample__1.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/tso500-ctdna/1.2.0--1/tso500-ctdna__1.2.0--1.cwljs
  InitialWorkDirRequirement:
    listing:
      - |
        ${
          return get_analysis_workflow_run_mounts(inputs)
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
            "$(get_scratch_resources_dir())" \\
            "$(get_analysis_step_analysis_dir())" \\
            "$(get_fastq_dir_path())"
          echo "completed creation of analysis dirs" 1>&2
          
          # Copy over the resources directory to the scratch mount
          echo "start copy resources dir to scratch mount" 1>&2
          cp -r "$(inputs.resources_dir.path)/." "$(get_scratch_resources_dir())/"
          echo "completed copy of resources dir" 1>&2
          
          # Link over the fastq files into the designated fastq folder
          echo "start linking of fastq files to fastq directory" 1>&2
          fastq_src_paths_array=( \\
              $(string_bash_array_contents(get_fastq_src_paths_array(inputs.tso500_samples))) \\
          )
          fastq_dest_paths_array=( \\
              $(string_bash_array_contents(get_fastq_dest_paths_array(inputs.tso500_samples))) \\
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
          cp -r "$(get_analysis_step_analysis_dir())/." "$(get_output_dir())/"
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
    type: ../../../schemas/tso500-sample/1.2.0/tso500-sample__1.2.0.yaml#tso500-sample[]
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
      glob: "$(get_analysis_logs_intermediates_output_dir())"
  contamination_dsdm:
    label: contamination dsdm
    doc: |
      Contamination dsdm json, used as input for Reporting task
    type: File
    outputBinding:
      glob: "$(get_analysis_dsdm_json_path())"
  # Task directories
  # Each output is a step in the wdl task workflow
  align_collapse_fusion_caller_dir:
    label: align collapse fusion caller dir
    doc: |
      Intermediate output directory for align collapse fusion caller step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/AlignCollapseFusionCaller"
  annotation_dir:
    label: annotation dir
    doc: |
      Intermediate output directory for annotation step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/Annotation"
  cnv_caller_dir:
    label: cnv caller dir
    doc: |
      Intermediate output directory for cnv caller step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/CnvCaller"
  contamination_dir:
    label: contamination dir
    doc: |
      Intermediate output directory for contamination step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/Contamination"
  dna_fusion_filtering_dir:
    label: dna fusion filtering dir
    doc: |
      Intermediate output directory for dna fusion filtering step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/DnaFusionFiltering"
  dna_qc_metrics_dir:
    label: dna qc metrics dir
    doc: |
      Intermediate output directory for dna qc metrics step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/DnaQCMetrics"
  max_somatic_vaf_dir:
    label: max somatic vaf dir
    doc: |
      Intermediate output directory for max somatic vaf step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/MaxSomaticVaf"
  merged_annotation_dir:
    label: merged annotation dir
    doc: |
      Intermediate output directory for merged annotation step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/MergedAnnotation"
  msi_dir:
    label: msi dir
    doc: |
      Intermediate output directory for msi step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/Msi"
  phased_variants_dir:
    label: phased variants dir
    doc: |
      Intermediate output directory for phased variants step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/PhasedVariants"
  small_variant_filter_dir:
    label: small variant filter dir
    doc: |
      Intermediate output directory for small variants filter step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/SmallVariantFilter"
  stitched_realigned_dir:
    label: stitched realigned dir
    doc: |
      Intermediate output directory for stitched realigned step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/StitchedRealigned"
  tmb_dir:
    label: tmb dir
    doc: |
      Intermediate output directory for tmb step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/Tmb"
  variant_caller_dir:
    label: variant caller dir
    doc: |
      Intermediate output directory for variant caller step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/VariantCaller"
  variant_matching_dir:
    label: variant matching dir
    doc: |
      Intermediate output directory for variant matching step
    type: Directory?
    outputBinding:
      glob: "$(get_analysis_logs_intermediates_output_dir())/VariantMatching"

successCodes:
  - 0
