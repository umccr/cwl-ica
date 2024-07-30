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
id: dragen-instrument-run-fastq-to-ora--4.2.4
label: dragen-instrument-run-fastq-to-ora v(4.2.4)
doc: |
    Documentation for dragen-instrument-run-fastq-to-ora v4.2.4

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
        dockerPull: ubuntu:latest

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.0.3/dragen-tools__4.0.3.cwljs
      - $include: ../../../typescript-expressions/utils/1.0.0/utils__1.0.0.cwljs
  InitialWorkDirRequirement:
    listing:
      - entryname: "run-dragen-instrument-run-fastq-to-ora.sh"
        entry: |
          #!/usr/bin/env bash
          
          # Bash settings
          set -euo pipefail
          
          # Decompress ora reference tar ball
          echo "\$(date -Iseconds): Decompressing the ORA reference tar ball" 1>&2
          echo tar \\
            --directory "$(get_ref_mount())" \\
            --extract \\
            --file "$(inputs.ora_reference.path)"
          
          # Initialise the dragen box 
          # Ora compress the fastq files  
          echo "\$(date -Iseconds): Initialising Dragen" 1>&2
          echo /opt/edico/bin/dragen \\
            --partial-reconfig HMM \\
            --ignore-version-check true
          
          # Step 0: Create the output directory
          echo "\$(date -Iseconds): Creating the output directory at $(inputs.output_directory_name)" 1>&2
          mkdir -p "$(inputs.output_directory_name)"
          
          # Step 1: Transfer Interop Reports, and Logs directories
          echo "\$(date -Iseconds): Transferring InterOp Reports, and Logs directories to $(inputs.output_directory_name)" 1>&2
          for dir in InterOp Reports Logs; do
            # Check if the directory exists, skip otherwise
            if [[ ! -d "$(inputs.instrument_run_directory.path)/\${dir}" ]]; then
              echo "\$(date -Iseconds): Directory $(inputs.instrument_run_directory.path)/\${dir} does not exist, skipping" 1>&2
              continue
            fi
            # Copy over the directory
            echo "\$(date -Iseconds): Copying $(inputs.instrument_run_directory.path)/\${dir} to $(inputs.output_directory_name)/\${dir}" 1>&2
            cp -r "$(inputs.instrument_run_directory.path)/\${dir}/." "$(inputs.output_directory_name)/\${dir}/"
          done
          
          # Step 2: Transfer the fastq files
          while IFS= read -r -d '' dir; do
            # Collect the sample id
            sample_id="\$(basename "\${dir}")"
            
            # Collect the lane id
            lane_dirname="\$(basename "\$(dirname "\${dir}")")"  # Lane_1
            lane_id="\${lane_dirname##*_}"  # 1
            
            # Check if the sample id is in the list of samples to process
            if [[ "$(is_not_null(inputs.sample_id_list))" == "true" ]]; then
              SAMPLE_ID_LIST_ARRAY=$(get_str_list_as_bash_array(inputs.sample_id_list, "__"))
              if [[ ! " \${SAMPLE_ID_LIST_ARRAY[*]} " =~ __\${sample_id}__ ]]; then
                echo "\$(date -Iseconds): Sample \${sample_id} not in the list of samples to process, skipping" 1>&2
                continue  
              fi
            # Check if this is one of the Undetermined folders
            elif [[ "\${sample_id}" == "Undetermined" ]]; then
              continue
            fi
          
            # Log statement
            echo "\$(date -Iseconds): Processing sample \${sample_id} in lane \${lane_id}" 1>&2
          
            # Create the output directory
            sample_output_dir="$(inputs.output_directory_name)/Samples/\${lane_dirname}/\${sample_id}"
            echo "\$(date -Iseconds): Creating the output directory at \${sample_output_dir}" 1>&2
            mkdir -p "\${sample_output_dir}"
            
            # Create a trap to delete the fastq list csv if the script is interrupted
            trap 'rm -f fastq_list.csv' EXIT
            
            # Generate the fastq list csv for this sample
            echo "\$(date -Iseconds): Generating the fastq list csv for sample \${sample_id} in lane \${lane_id}, based off the fastq list csv in '$(inputs.instrument_run_directory.path)/Reports/fastq_list.csv'" 1>&2
          
            # Get rgid and lane
            rgids_and_lane_cols="\$( \\
              grep "\${sample_id},UnknownLibrary,\${lane_id}" < "$(inputs.instrument_run_directory.path)/Reports/fastq_list.csv" | \
              cut -d',' -f1-4
            )"
            
            # Confirm that the fastq list csv entry exists
            if [[ -z "\${rgids_and_lane_cols}" ]]; then
              echo "\$(date -Iseconds): No fastq list csv entry found for sample \${sample_id} in lane \${lane_id}, skipping" 1>&2
              continue
            fi
          
            # Get the read1 and read2 files
            read_1_file="\$(
              find "\${dir}" -type f -name "*_R1_001.fastq.gz" -printf "%p\\n"
            )"
            read_2_file="\$(
              find "\${dir}" -type f -name "*_R2_001.fastq.gz" -printf "%p\\n"
            )"
            
            # Generate the fastq list csv for this sample
            {
              echo "RGID,RGSM,RGLB,Lane,Read1File,Read2File"
              echo "\${rgids_and_lane_cols},\${read_1_file},\${read_2_file}"
            } > fastq_list.csv
            
            # Run the dragen ora step
            echo "\$(date -Iseconds): Running Dragen ORA for sample \${sample_id} in lane \${lane_id}" 1>&2
            echo /opt/edico/bin/dragen \\
              --enable-map-align false \\
              --fastq-list fastq_list.csv \\
              --enable-ora true \\
              --ora-reference "$(get_ref_path(inputs.ora_reference))" \\
              --output-directory "\${sample_output_dir}" \\
              --fastq-list-all-samples true
              
            # Delete the fastq list csv for this sample
            rm fastq_list.csv
          
            # Exit cleanly
            trap - EXIT
          
          done < <(find "$(inputs.instrument_run_directory.path)/Samples/" -mindepth 2 -maxdepth 2 -type d -print0)
          

baseCommand: ["bash", "run-dragen-instrument-run-fastq-to-ora.sh"]

inputs:
  # Mandatory inputs
  instrument_run_directory:
    label: instrument run directory
    doc: |
      The directory containing the instrument run. Expected to be in the BCLConvert 4.2.7 output format, with the following structure:
        Reports/
        InterOp/
        Logs/
        Samples/
        Samples/Lane_1/
        Samples/Lane_1/Sample_ID/
        Samples/Lane_1/Sample_ID/Sample_ID_S1_L001_R1_001.fastq.gz
        Samples/Lane_1/Sample_ID/Sample_ID_S1_L001_R2_001.fastq.gz
        etc...
    type: Directory
  output_directory_name:
    label: output directory name
    doc: |
      The name of the output directory
    type: string
  ora_reference:
    label: ora reference
    doc: |
      The reference to use for the ORA compression
    type: File
  # Optional inputs
  sample_id_list:
    label: sample id list
    doc: |
      Optional list of samples to process.  
      Samples NOT in this list are NOT compressed AND NOT transferred to the final output directory!
    type: string[]?

outputs:
  # Generate output directory
  output_directory:
    type: Directory
    outputBinding:
      glob: $(inputs.output_directory_name)

successCodes:
  - 0
