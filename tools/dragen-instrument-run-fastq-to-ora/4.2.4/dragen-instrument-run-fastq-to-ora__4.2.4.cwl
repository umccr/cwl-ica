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
        dockerPull: 699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:4.2.4

requirements:
  ResourceRequirement:
    tmpdirMin: |
      ${
        /* 2 Tb */
        return Math.pow(2, 21); 
      }
  LoadListingRequirement:
    loadListing: deep_listing
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
          
          # Create directories
          mkdir --parents \\
            "$(get_ref_mount())" \\
            "$(get_ora_intermediate_output_dir())" \\
            "$(get_intermediate_results_dir())" \\
            "$(inputs.output_directory_name)"
          
          # Decompress ora reference tar ball
          echo "\$(date -Iseconds): Decompressing the ORA reference tar ball" 1>&2
          tar \\
            --directory "$(get_ref_mount())" \\
            --extract \\
            --file "$(inputs.ora_reference.path)"
          
          # Initialise the dragen box 
          # Ora compress the fastq files  
          echo "\$(date -Iseconds): Initialising Dragen" 1>&2
          /opt/edico/bin/dragen \\
            --partial-reconfig HMM \\
            --ignore-version-check true
          
          (
            echo "\$(date -Iseconds): Collecting md5sums of gzipped fastq files" 1>&2 && \\
            bash "$(get_fastq_gz_md5sum_files_script_path())" > "$(inputs.output_directory_name)/fastq_gzipped.md5.txt" && \\
            echo "\$(date -Iseconds): Md5sum complete" 1>&2 && \\
            echo "\$(date -Iseconds): Collecting file sizes of gzipped fastq files" 1>&2 && \\
            bash "$(get_fastq_gz_file_sizes_script_path())" > "$(inputs.output_directory_name)/fastq_gzipped.filesizes.tsv" && \\
            echo "\$(date -Iseconds): File size collection complete" 1>&2 \\
          ) & \\
          (
            echo "\$(date -Iseconds): Ora compressing the fastq files" 1>&2 && \\
            /opt/edico/bin/dragen "\${@}" && \\
            echo "\$(date -Iseconds): Compression complete" 1>&2 && \\
            echo "\$(date -Iseconds): Generating md5sums for ora outputs" 1>&2 && \\
            bash "$(get_fastq_ora_md5sum_files_script_path())" > "$(inputs.output_directory_name)/fastq_ora.md5.txt" && \\
            echo "\$(date -Iseconds): Generating md5sums for ora outputs complete" 1>&2
            echo "\$(date -Iseconds): Generating file sizes for ora outputs" 1>&2 && \\
            bash "$(get_fastq_ora_file_sizes_script_path())" > "$(inputs.output_directory_name)/fastq_ora.filesizes.tsv" && \\
            echo "\$(date -Iseconds): Generating file sizes for ora outputs complete" 1>&2
          ) & \\
          (
            echo "\$(date -Iseconds): Moving non-fastq files to the output directory" 1>&2 && \\
            rsync --archive \\
              --include="*/" \\
              --exclude="*.fastq.gz" \\
              "$(inputs.instrument_run_directory.path)/" \\
              "$(inputs.output_directory_name)/" && \\
            echo "\$(date -Iseconds): Moving non-fastq files to the output directory complete" 1>&2 \\
          ) & \\
          wait
          
          # Remove the streaming log none file (as it is not compatible with downstream cwl services)
          rm -f "$(get_ora_intermediate_output_dir())/streaming_log_none(1000).csv"
          
          # Move the ora files from the scratch space to the output directory 
          # To where their equivalent fastq files would have been moved to 
          echo "\$(date -Iseconds): Moving fastq ora files from the scratch space to the output directory" 1>&2
          bash "$(get_ora_mv_files_script_path())"
          echo "\$(date -Iseconds): ORA Tool complete" 1>&2
          
          # Generate new fastq list csv 
          # With fastq.ora suffixes for read 1 and read 2
          # And place in output directory
          echo "\$(date -Iseconds): Generating fastq list csv for ora outputs" 1>&2
          bash "$(get_new_fastq_list_csv_script_path())" >> "$(inputs.output_directory_name)/fastq_list_ora.csv"
          echo "\$(date -Iseconds): Generating fastq list csv for ora outputs complete" 1>&2
          
          # if inputs.ora_print_file_info is true
          if [[ "$(get_bool_value_as_str(inputs.ora_print_file_info))" == "true" ]]; then
            echo "\$(date -Iseconds): Generating ora file info file, --ora-print-file-info set to true" 1>&2
            mkdir -p "$(inputs.output_directory_name)/ora-logs/file-info/"
            /opt/edico/bin/dragen \\
              --enable-map-align=false \\
              --enable-ora=true \\
              --fastq-list="$(inputs.output_directory_name)/fastq_list_ora.csv" \\
              --fastq-list-all-samples=true \\
              --ora-reference="$(get_ref_path(inputs.ora_reference))" \\
              --ora-print-file-info=true \\ 
              --ora-parallel-files=1 \\
              --intermediate-results-dir="$(get_intermediate_results_dir())" \\
              --lic-instance-id-location="$(get_optional_attribute_from_multi_type_input_object(inputs.lic_instance_id_location, "path"))" \\
              --output-directory="$(inputs.output_directory_name)/ora-logs/file-info/" \\
              1> "$(inputs.output_directory_name)/ora-logs/file-info/ora-file-info.log"
            echo "\$(date -Iseconds): Generating ora file info file complete" 1>&2
          else
            echo "\$(date -Iseconds): Skipping ora file info step --ora-print-file-info set to false" 1>&2  
          fi
          
          # If inputs.ora_check_file_integrity is true
          if [[ "$(get_bool_value_as_str(inputs.ora_check_file_integrity))" == "true" ]]; then
            echo "\$(date -Iseconds): Checking ora file integrity, --ora-check-file-integrity set to true" 1>&2
            mkdir -p "$(inputs.output_directory_name)/ora-logs/check-integrity/"
            /opt/edico/bin/dragen \\
              --enable-map-align=false \\
              --enable-ora=true \\
              --fastq-list="$(inputs.output_directory_name)/fastq_list_ora.csv" \\
              --fastq-list-all-samples=true \\
              --ora-reference="$(get_ref_path(inputs.ora_reference))" \\
              --ora-check-file-integrity=true \\
              --intermediate-results-dir="$(get_intermediate_results_dir())" \\
              --lic-instance-id-location="$(get_optional_attribute_from_multi_type_input_object(inputs.lic_instance_id_location, "path"))" \\
              --output-directory "$(inputs.output_directory_name)/ora-logs/check-integrity/" \\
              1> "$(inputs.output_directory_name)/ora-logs/check-integrity/ora-check-integrity.log"
            echo "\$(date -Iseconds): Checking ora file integrity complete" 1>&2
          else
            echo "\$(date -Iseconds): Skipping ora file integrity check step --ora-check-file-integrity set to false" 1>&2
          fi

      - |
        ${
          return generate_ora_mount_points(inputs.instrument_run_directory, inputs.output_directory_name);
        }

baseCommand: ["bash", "run-dragen-instrument-run-fastq-to-ora.sh"]

arguments:
  - prefix: --enable-map-align=
    separate: False
    valueFrom: "false"
  - prefix: --fastq-list=
    separate: False
    valueFrom: fastq_list.csv
  - prefix: --enable-ora=
    separate: False
    valueFrom: "true"
  - prefix: --intermediate-results-dir=
    separate: False
    valueFrom: "$(get_intermediate_results_dir())"
  - prefix: --output-directory=
    separate: False
    valueFrom: "$(get_ora_intermediate_output_dir())"
  - prefix: --fastq-list-all-samples=
    separate: False
    valueFrom: "true"

inputs:
  # Mandatory inputs
  instrument_run_directory:
    label: instrument run directory
    doc: |
      The directory containing the fastq files.  
      The fastq files are compressed using the ORA algorithm.
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
    inputBinding:
      prefix: --ora-reference=
      separate: False
      valueFrom: "$(get_ref_path(self))"
  # Optional inputs
  sample_id_list:
    label: sample id list
    doc: |
      Optional list of samples to process.  
      Samples NOT in this list are NOT compressed AND NOT transferred to the final output directory!
    type: string[]?
  # CPU
  ora_parallel_files:
    label: ora parallel files
    doc: |
      The number of files to compress in parallel
      ORA threads per file is set to 8 by default, 
      so this value should represent 16 / number of cores available
    default: 2
    type: int?
    inputBinding:
      prefix: --ora-parallel-files=
      separate: False
  ora_threads_per_file:
    label: ora threads per file
    doc: |
      The number of threads to use per file. If using an FPGA medium instance in the 
      run_dragen_instrument_run_fastq_to_ora_step this should be set to 4 since there are only 16 cores available
    default: 8
    type: int?
    inputBinding:
      prefix: --ora-threads-per-file=
      separate: False
  # Integrity options
  ora_print_file_info:
    label: ora print file info
    doc: |
      Prints file information summary of ORA compressed files.
    default: false
    type: boolean
  ora_check_file_integrity:
    label: ora check file integrity
    doc: |
      Set to true to perform and output result of FASTQ file and decompressed FASTQ.ORA integrity check. The default value is false.
    default: false
    type: boolean
  # Miscellaneous options
  lic_instance_id_location:
    label: license instance id location
    doc: |
      You may wish to place your own in.
      Optional value, default set to /opt/instance-identity
      which is a path inside the dragen container
    type:
      - File?
      - string?
    default: "/opt/instance-identity"
    inputBinding:
      prefix: --lic-instance-id-location=
      separate: False

outputs:
  # Generate output directory
  output_directory:
    label: output directory
    doc: |
      The output directory containing the instrument run with compressed ORA files
    type: Directory
    outputBinding:
      glob: $(inputs.output_directory_name)

successCodes:
  - 0
