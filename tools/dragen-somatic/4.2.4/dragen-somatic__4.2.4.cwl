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
id: dragen-somatic--4.2.4
label: dragen-somatic v(4.2.4)
doc: |
  Run tumor-normal dragen somatic pipeline v 4.2.4.
  Workflow takes in two separate lists of object stor version of the fastq_list.csv equivalent
  See the fastq_list_row schema definitions for more information.
  More information on the documentation can be found [here](https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/SomaticMode.htm).


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
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.0.3/dragen-tools__4.0.3.cwljs
      - $include: ../../../typescript-expressions/utils/1.0.0/utils__1.0.0.cwljs
  InitialWorkDirRequirement:
    listing:
      - entryname: $(get_script_path())
        entry: |
          #!/usr/bin/env bash
          
          # Fail on non-zero exit of subshell
          set -euo pipefail
          
          # Confirm not more than one of fastq_list, fastq_list_rows, bam_input and cram_input are defined
          if [[ "$(boolean_to_int(is_not_null(inputs.fastq_list)) + boolean_to_int(is_not_null(inputs.fastq_list_rows)) + boolean_to_int(is_not_null(inputs.bam_input)) + boolean_to_int(is_not_null(inputs.cram_input)))" -gt "1" ]]; then
            echo "Please set no more than one of fastq_list, fastq_list_rows, bam_input or cram_input for normal sample" 1>&2
            exit 1
          fi
          
          # Ensure that at least one (and only one) of tumor_fastq_list, tumor_fastq_list_rows, tumor_bam_input and tumor_cram_input are defined but not both defined (XOR)
          if [[ "$(boolean_to_int(is_not_null(inputs.tumor_fastq_list)) + boolean_to_int(is_not_null(inputs.tumor_fastq_list_rows)) + boolean_to_int(is_not_null(inputs.tumor_bam_input)) + boolean_to_int(is_not_null(inputs.tumor_cram_input)))" -ne "1" ]]; then
              echo "One and only one of inputs tumor_fastq_list, tumor_fastq_list_rows, tumor_bam_input, tumor_cram_input must be defined" 1>&2
              exit 1
          fi
          
          # Reset dragen
          /opt/edico/bin/dragen \\
            --partial-reconfig HMM \\
            --ignore-version-check true
          
          # Create directories
          mkdir --parents \\
            "$(get_ref_mount())" \\
            "$(get_intermediate_results_dir())" \\
            "$(inputs.output_directory)"
          
          # untar ref data into scratch space
          tar \\
            --directory "$(get_ref_mount())" \\
            --extract \\
            --file "$(inputs.reference_tar.path)"

          # Check if ora reference is set
          if [[ "$(is_not_null(inputs.ora_reference_tar))" == "true" ]]; then
              tar \\
              --directory "$(get_ref_mount())" \\
              --extract \\
              --file "$(get_attribute_from_optional_input(inputs.ora_reference_tar, "path"))"
          fi

          # Check if both bam inputs are set
          if [[ "$(is_not_null(inputs.bam_input))" == "true" && "$(is_not_null(inputs.tumor_bam_input))" == "true" && ( "$(get_bool_value_as_str(inputs.enable_map_align))" == "true" || "$(get_bool_value_as_str(inputs.enable_map_align_output))" == "true" ) ]]; then
            echo "More than one bam input is set, need to run enable map align first beforehand then run variant calling in a separate step" 1>&2
          
            # Collect options relating to map alignment (these options will be popped from the args list and not used in the variant calling step)
            enable_sort_parameter=""
            enable_duplicate_marking_parameter=""
            dedup_min_qual_parameter=""
          
            # Pop arguments
            # Get args from command line
            # But capture them again since we need them when we actually run dragen
            existing_args_array=()
            while [ $# -gt 0 ]; do
              case "$1" in
                --enable-sort=*)
                  enable_sort_parameter="$1"
                  ;;
                --enable-duplicate-marking=*)
                  enable_duplicate_marking_parameter="\${1}"
                  ;;
                --enable-map-align=*)
                  :  # Just popping from array, we set this by default in these steps but dont want it in final dragen call
                  ;;
                --enable-map-align-output=*)
                  :  # Just popping from array, we set this by default in these steps but dont want it in final dragen call
                  ;;
                --dedup-min-qual=*)
                  dedup_min_qual_parameter="\${1}"
                  ;;
                --bam-input=*)
                  :  # Just popping from array as we set the new location elsewhere
                  ;;
                --tumor-bam-input=*)
                  :  # Just popping from array as we set the new location elsewhere
                  ;;
                *)
                  existing_args_array+=("\${1}")
              esac
              shift 1
            done
          
            # Then run dragen map-align and place the files in the output directories
            # Tumor Then Normal
            echo "Aligning tumor" 1>&2
            # Eval prefix required here as some parameters are empty
            eval /opt/edico/bin/dragen \\
              --enable-map-align=true \\
              --enable-map-align-output=true \\
              "\${enable_sort_parameter}" \\
              "\${enable_duplicate_marking_parameter}" \\
              "\${dedup_min_qual_parameter}" \\
              "--ref-dir=$(get_ref_path(inputs.reference_tar))" \\
              "--output-directory=$(inputs.output_directory)" \\
              "--output-file-prefix=$(inputs.output_file_prefix)" \\
              "--intermediate-results-dir=$(get_intermediate_results_dir())" \\
              "--lic-instance-id-location=$(get_optional_attribute_from_multi_type_input_object(inputs.lic_instance_id_location, "path"))" \\
              "--tumor-bam-input=$(get_attribute_from_optional_input(inputs.tumor_bam_input, "path"))"
          
            echo "Aligning normal" 1>&2
            # Eval prefix required here as some parameters are empty
            eval /opt/edico/bin/dragen \\
              --enable-map-align=true \\
              --enable-map-align-output=true \\
              "\${enable_sort_parameter}" \\
              "\${enable_duplicate_marking_parameter}" \\
              "\${dedup_min_qual_parameter}" \\
              "--ref-dir=$(get_ref_path(inputs.reference_tar))" \\
              "--output-directory=$(inputs.output_directory)" \\
              "--output-file-prefix=$(inputs.output_file_prefix)" \\
              "--intermediate-results-dir=$(get_intermediate_results_dir())" \\
              "--lic-instance-id-location=$(get_optional_attribute_from_multi_type_input_object(inputs.lic_instance_id_location, "path"))" \\
              "--bam-input=$(get_attribute_from_optional_input(inputs.bam_input, "path"))"
          
            # Pop back in existing arguments into \${@}
            for existing_arg in "\${existing_args_array[@]}"; do
               set -- "\${@}" "\${existing_arg}"
            done
          
            # Update bam input and tumor bam input parameters
            set -- "\${@}" "--bam-input=$(inputs.output_directory)/$(inputs.output_file_prefix).bam"
            set -- "\${@}" "--tumor-bam-input=$(inputs.output_directory)/$(inputs.output_file_prefix)_tumor.bam"
          
            # Explicity set enable map align to false
            # Setting --enable-map-align to false, sets --enable-map-align-output to false as well
            set -- "\${@}" "--enable-map-align=false"
          fi
          
          # Check if cram inputs are set and enable map align output is set
          # Like bam inputs, we need to run map align first before running variant calling
          if [[ "$(is_not_null(inputs.cram_input))" == "true" && "$(is_not_null(inputs.tumor_cram_input))" == "true" && ( "$(get_bool_value_as_str(inputs.enable_map_align))" == "true" || "$(get_bool_value_as_str(inputs.enable_map_align_output))" == "true" ) ]]; then
            echo "More than one cram input is set, need to run enable map align first beforehand then run variant calling in a separate step" 1>&2
          
            # Collect options relating to map alignment (these options will be popped from the args list and not used in the variant calling step)
            enable_sort_parameter=""
            enable_duplicate_marking_parameter=""
            dedup_min_qual_parameter=""
            cram_reference_parameter=""
          
            # Pop arguments
            # Get args from command line
            # But capture them again since we need them when we actually run dragen
            existing_args_array=()
            while [ $# -gt 0 ]; do
              case "$1" in
                --enable-sort=*)
                  enable_sort_parameter="$1"
                  ;;
                --enable-duplicate-marking=*)
                  enable_duplicate_marking_parameter="\${1}"
                  ;;
                --enable-map-align=*)
                  :  # Just popping from array, we set this by default in these steps but dont want it in final dragen call
                  ;;
                --enable-map-align-output=*)
                  :  # Just popping from array, we set this by default in these steps but dont want it in final dragen call
                  ;;
                --dedup-min-qual=*)
                  dedup_min_qual_parameter="\${1}"
                  ;;
                --cram-input=*)
                  :  # Just popping from array as we set the new location elsewhere
                  ;;
                --tumor-cram-input=*)
                  :  # Just popping from array as we set the new location elsewhere
                  ;;
                --cram-reference=*)
                  cram_reference_parameter="\${1}"
                  ;;
                *)
                  existing_args_array+=("\${1}")
              esac
              shift 1
            done
          
            # Then run dragen map-align and place the files in the output directories
            # Tumor Then Normal
            echo "Aligning tumor" 1>&2
            # Eval prefix required here as some parameters are empty
            eval /opt/edico/bin/dragen \\
              --enable-map-align=true \\
              --enable-map-align-output=true \\
              "\${enable_sort_parameter}" \\
              "\${enable_duplicate_marking_parameter}" \\
              "\${dedup_min_qual_parameter}" \\
              "\${cram_reference_parameter}" \\
              "--ref-dir=$(get_ref_path(inputs.reference_tar))" \\
              "--output-directory=$(inputs.output_directory)" \\
              "--output-file-prefix=$(inputs.output_file_prefix)" \\
              "--intermediate-results-dir=$(get_intermediate_results_dir())" \\
              "--lic-instance-id-location=$(get_optional_attribute_from_multi_type_input_object(inputs.lic_instance_id_location, "path"))" \\
              "--tumor-cram-input=$(get_attribute_from_optional_input(inputs.tumor_cram_input, "path"))"
          
            echo "Aligning normal" 1>&2
            # Eval prefix required here as some parameters are empty
            eval /opt/edico/bin/dragen \\
              --enable-map-align=true \\
              --enable-map-align-output=true \\
              "\${enable_sort_parameter}" \\
              "\${enable_duplicate_marking_parameter}" \\
              "\${dedup_min_qual_parameter}" \\
              "\${cram_reference_parameter}" \\
              "--ref-dir=$(get_ref_path(inputs.reference_tar))" \\
              "--output-directory=$(inputs.output_directory)" \\
              "--output-file-prefix=$(inputs.output_file_prefix)" \\
              "--intermediate-results-dir=$(get_intermediate_results_dir())" \\
              "--lic-instance-id-location=$(get_optional_attribute_from_multi_type_input_object(inputs.lic_instance_id_location, "path"))" \\
              "--cram-input=$(get_attribute_from_optional_input(inputs.cram_input, "path"))"
          
            # Pop back in existing arguments into \${@}
            for existing_arg in "\${existing_args_array[@]}"; do
               set -- "\${@}" "\${existing_arg}"
            done
          
            # Update bam input and tumor bam input parameters
            # Note that we output bams by default
            set -- "\${@}" "--bam-input=$(inputs.output_directory)/$(inputs.output_file_prefix).bam"
            set -- "\${@}" "--tumor-bam-input=$(inputs.output_directory)/$(inputs.output_file_prefix)_tumor.bam"
          
            # Explicity set enable map align to false since we have already done the alignment
            # Setting --enable-map-align to false, sets --enable-map-align-output to false as well
            set -- "\${@}" "--enable-map-align=false"
          fi
          
          # Run dragen command and import options from cli
          echo "Running dragen variant calling" 1>&2
          "$(get_dragen_bin_path())" "\${@}"
          
          # Check if a normal input is set
          if [[ "$(is_not_null(inputs.fastq_list))" == "true" || "$(is_not_null(inputs.fastq_list_rows))" == "true" || "$(is_not_null(inputs.bam_input))" == "true" || "$(is_not_null(inputs.cram_input))" == "true" ]]; then
            # --enable-map-align-output is set to false
            if [[ "$(get_bool_value_as_str(inputs.enable_map_align_output))" == "false" ]]; then
              # No bams output if -enable-map-align-output is false and --enable-map-align is also false
              # if --enable-map-align-output is false and --enable-map-align is false, no bam output
              if [[ "$(get_bool_value_as_str(inputs.enable_map_align))" == "false" ]]; then
                echo "--enable-map-align-output and --enable-map-align set to false, no bam output" 1>&2
  
              # Bams output if --enable-map-align-output is false but --enable-map-align is true
              # And one of tumor_bam_input or tumor_cram_input is set 
              # And one of bam_input or cram_input is set
              # Then bam is generated even when --enable-map-align-output is explicitly set to false
              # Since we needed to align the tumor and normal prior to running the variant calling step
              # So when --enable-map-align-output is false under these conditions, we should delete the normal bam file rather than move it
              elif [[ "$(get_bool_value_as_str(inputs.enable_map_align))" == "true" && ( "$(is_not_null(inputs.tumor_bam_input))" == "true" || "$(is_not_null(inputs.tumor_cram_input))" == "true" ) && ( "$(is_not_null(inputs.bam_input))" == "true" || "$(is_not_null(inputs.cram_input))" == "true" ) ]]; then
                echo "--enable-map-align is set to true but --enable-map-align-output is set to false, but we ignored --enable-map-align-output=false because one both tumor and normal inputs were set to true and thus needed to be aligned separately, deleting tumor and normal bam files" 1>&2
                rm -f "$(inputs.output_directory)/$(inputs.output_file_prefix).bam" "$(inputs.output_directory)/$(inputs.output_file_prefix).bam.bai" "$(inputs.output_directory)/$(inputs.output_file_prefix).bam.md5sum"
                rm -f "$(inputs.output_directory)/$(inputs.output_file_prefix)_tumor.bam" "$(inputs.output_directory)/$(inputs.output_file_prefix)_tumor.bam.bai" "$(inputs.output_directory)/$(inputs.output_file_prefix)_tumor.bam.md5sum"  
              fi
              
              # No action required otherwise --enable-map-align-output is false
          
            # --enable-map-align-output is true 
            # Move normal bam file to new normal bam file name prefix
            else
              # Ensure that we have a normal RGSM value, otherwise exit.
              if [[ "$(is_not_null(get_normal_output_prefix(inputs)))" == "false" ]]; then
                echo "Could not get the normal bam file prefix" 1>&2
                echo "Exiting" 1>&2
                exit
              fi
            
              # Get new normal file name prefix from the fastq_list.csv
              new_normal_file_name_prefix="$(get_normal_output_prefix(inputs))"
            
              # Ensure output normal bam file exists and the destination normal bam file also does not exist yet
              if [[ -f "$(inputs.output_directory)/$(inputs.output_file_prefix).bam" && ! -f "$(inputs.output_directory)/\${new_normal_file_name_prefix}.bam" ]]; then
                # Move normal bam, normal bam index and normal bam md5sum
                (
                  cd "$(inputs.output_directory)"
                  mv "$(inputs.output_file_prefix).bam" "\${new_normal_file_name_prefix}.bam"
                  mv "$(inputs.output_file_prefix).bam.bai" "\${new_normal_file_name_prefix}.bam.bai"
                  mv "$(inputs.output_file_prefix).bam.md5sum" "\${new_normal_file_name_prefix}.bam.md5sum"
                )
              else
                echo "Error! Expected to move file from $(inputs.output_file_prefix).bam to \${new_normal_file_name_prefix}.bam but either $(inputs.output_file_prefix).bam does not exist or \${new_normal_file_name_prefix}.bam already exists" 1>&2
              fi
            fi
          fi
                    
          # If --enable-sv has been selected, we need to remove the empty genomeDepth directory
          # https://github.com/umccr-illumina/ica_v2/issues/131
          if [[ "$(is_not_null(inputs.enable_sv))" == "true" && "$(get_bool_value_as_str(inputs.enable_sv))" == "true" && -d "$(inputs.output_directory)/sv/" ]]; then
            find "$(inputs.output_directory)/sv/" -type d -empty -delete
          fi
      - |
        ${
          return generate_somatic_mount_points(inputs);
        }

baseCommand: [ "bash" ]

arguments:
  - position: -1
    valueFrom: "$(get_script_path())"
  - position: 1
    prefix: "--enable-variant-caller="
    separate: False
    valueFrom: "true"
  - prefix: "--intermediate-results-dir="
    separate: False
    valueFrom: "$(get_intermediate_results_dir())"

inputs:
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/OptionReference.htm
  # Inputs fastq list csv or actual fastq list file with presigned urls for Read1File and Read2File columns
  # File inputs
  # Input Option 1
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files for normal sample
      to process. read_1 and read_2 components in the CSV file must be presigned urls.
    type: File?
    inputBinding:
      loadContents: true
      prefix: "--fastq-list="
      separate: False
      valueFrom: "$(get_fastq_list_csv_path())"
  tumor_fastq_list:
    label: tumor fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process. read_1 and read_2 components in the CSV file must be presigned urls.
    type: File?
    inputBinding:
      prefix: "--tumor-fastq-list="
      separate: False
      valueFrom: "$(get_tumor_fastq_list_csv_path())"
  # Input Option 2
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects for normal sample
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
    inputBinding:
      prefix: "--fastq-list="
      separate: False
      valueFrom: "$(get_fastq_list_csv_path())"
  tumor_fastq_list_rows:
    label: tumor fastq list rows
    doc: |
      Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects for tumor sample
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
    inputBinding:
      prefix: "--tumor-fastq-list="
      separate: False
      valueFrom: "$(get_tumor_fastq_list_csv_path())"
  # Input Option 3
  bam_input:
    label: bam input
    doc: |
      Input a normal BAM file for the variant calling stage
    type: File?
    inputBinding:
      prefix: "--bam-input="
      separate: False
    secondaryFiles:
      - pattern: ".bai"
        required: true
  tumor_bam_input:
    label: tumor bam input
    doc: |
      Input a tumor BAM file for the variant calling stage
    type: File?
    inputBinding:
      prefix: "--tumor-bam-input="
      separate: False
    secondaryFiles:
      - pattern: ".bai"
        required: true
  # Input Option 4
  cram_input:
    label: cram input
    doc: |
      Input a normal CRAM file for the variant calling stage
    type: File?
    inputBinding:
      prefix: "--cram-input="
      separate: False
    secondaryFiles:
      - pattern: ".crai"
        required: true
  tumor_cram_input:
    label: tumor cram input
    doc: |
      Input a tumor CRAM file for the variant calling stage
    type: File?
    inputBinding:
      prefix: "--tumor-cram-input="
      separate: False
    secondaryFiles:
      - pattern: ".crai"
        required: true
  cram_reference:
    label: cram reference
    doc: |
      Path to the reference fasta file for the CRAM input. 
      Required only if the input is a cram file AND not the reference in the tarball
    type: File?
    inputBinding:
      prefix: "--cram-reference="
      separate: False
    secondaryFiles:
      - pattern: ".fai"
        required: true

  # Dragen reference tar ball
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
    inputBinding:
      prefix: "--ref-dir="
      separate: False
      valueFrom: "$(get_ref_path(self))"
  # If fastqs are ora, then we need to provide the ora reference tar
  ora_reference_tar:
    label: ora reference tar
    doc: |
      Path to ORA ref data tarball
    type: File?
    inputBinding:
      prefix: "--ora-reference="
      separate: False
      valueFrom: "$(get_ref_path(self))"

  # Mandatory parameters
  output_directory:
    label: output directory
    doc: |
      Required - The output directory.
    type: string
    inputBinding:
      prefix: "--output-directory="
      separate: False
  output_file_prefix:
    label: output file prefix
    doc: |
      Required - the output file prefix
    type: string
    inputBinding:
      prefix: "--output-file-prefix="
      separate: False

  # Optional operation modes
  # Optional operation modes
  # Given we're running from fastqs
  # --enable-variant-caller option must be set to true (set in arguments), --enable-map-align is then activated by default
  # --enable-map-align-output to keep bams
  # --enable-duplicate-marking to mark duplicate reads at the same time
  # --enable-sv to enable the structural variant calling step.
  enable_sort:
    label: enable sort
    doc: |
      True by default, only set this to false if using --bam-input and --tumor-bam-input parameters
    type: boolean?
    inputBinding:
      prefix: "--enable-sort="
      separate: False
      valueFrom: "$(self.toString())"
  enable_map_align:
    label: enable map align
    doc: |
      Enabled by default since --enable-variant-caller option is set to true.
      Set this value to false if using bam_input AND tumor_bam_input
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align="
      separate: False
      valueFrom: "$(self.toString())"
  enable_map_align_output:
    label: enable map align output
    doc: |
      Enables saving the output from the
      map/align stage. Default is true when only
      running map/align. Default is false if
      running the variant caller.
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align-output="
      separate: False
      valueFrom: "$(self.toString())"
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Enable the flagging of duplicate output
      alignment records.
    type: boolean?
    inputBinding:
      prefix: "--enable-duplicate-marking="
      separate: False
      valueFrom: "$(self.toString())"
  enable_sv:
    label: enable sv
    doc: |
      Enable/disable structural variant
      caller. Default is false.
    type: boolean?
    inputBinding:
      prefix: "--enable-sv="
      separate: False
      valueFrom: "$(self.toString())"

  # Deduplication options
  dedup_min_qual:
    label: deduplicate minimum quality
    doc: |
      Specifies the Phred quality score below which a base should be excluded from the quality score
      calculation used for choosing among duplicate reads.
    type: int?
    inputBinding:
      prefix: "--dedup-min-qual="
      separate: False


  # Structural Variant Caller Options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/StructuralVariantCalling.htm
  sv_call_regions_bed:
    label: sv call regions bed
    doc: |
      Specifies a BED file containing the set of regions to call.
    type: File?
    inputBinding:
      prefix: "--sv-call-regions-bed="
      separate: False
  sv_region:
    label: sv region
    doc: |
      Limit the analysis to a specified region of the genome for debugging purposes.
      This option can be specified multiple times to build a list of regions.
      The value must be in the format "chr:startPos-endPos"..
    type: string?
    inputBinding:
      prefix: "--sv-region="
      separate: False
      valueFrom: "$(self.toString())"
  sv_exome:
    label: sv exome
    doc: |
      Set to true to configure the variant caller for targeted sequencing inputs,
      which includes disabling high depth filters.
      In integrated mode, the default is to autodetect targeted sequencing input,
      and in standalone mode the default is false.
    type: boolean?
    inputBinding:
      prefix: "--sv-exome="
      separate: False
      valueFrom: "$(self.toString())"
  sv_output_contigs:
    label: sv output contigs
    doc: |
      Set to true to have assembled contig sequences output in a VCF file. The default is false.
    type: boolean?
    inputBinding:
      prefix: "--sv-output-contigs="
      separate: False
      valueFrom: "$(self.toString())"
  sv_forcegt_vcf:
    label: sv forcegt vcf
    doc: |
      Specify a VCF of structural variants for forced genotyping. The variants are scored and emitted
      in the output VCF even if not found in the sample data.
      The variants are merged with any additional variants discovered directly from the sample data.
    type: File?
    inputBinding:
      prefix: "--sv-forcegt-vcf="
      separate: False
  sv_discovery:
    label: sv discovery
    doc: |
      Enable SV discovery. This flag can be set to false only when --sv-forcegt-vcf is used.
      When set to false, SV discovery is disabled and only the forced genotyping input variants
      are processed. The default is true.
    type: boolean?
    inputBinding:
      prefix: "--sv-discovery="
      separate: False
      valueFrom: "$(self.toString())"
  sv_se_overlap_pair_evidence:
    label: sv use overlap pair evidence
    doc: |
      Allow overlapping read pairs to be considered as evidence.
      By default, DRAGEN uses autodetect on the fraction of overlapping read pairs if <20%.
    type: boolean?
    inputBinding:
      prefix: "--sv-use-overlap-pair-evidence="
      separate: False
      valueFrom: "$(self.toString())"
  sv_somatic_ins_tandup_hotspot_regions_bed:
    label: sv somatic ins tandup hotspot regions bed
    doc: |
      Specify a BED of ITD hotspot regions to increase sensitivity for calling ITDs in somatic variant analysis.
      By default, DRAGEN SV automatically selects areference-specific hotspots BED file from
      /opt/edico/config/sv_somatic_ins_tandup_hotspot_*.bed.
    type: File?
    inputBinding:
      prefix: "--sv-somatic-ins-tandup-hotspot-regions-bed="
      separate: False
  sv_enable_somatic_ins_tandup_hotspot_regions:
    label: sv enable somatic ins tandup hotspot regions
    doc: |
      Enable or disable the ITD hotspot region input. The default is true in somatic variant analysis.
    type: boolean?
    inputBinding:
      prefix: "--sv-enable-somatic-ins-tandup-hotspot-regions="
      separate: False
      valueFrom: "$(self.toString())"
  sv_enable_liquid_tumor_mode:
    label: sv enable liquid tumor mode
    doc: |
      Enable liquid tumor mode.
    type: boolean?
    inputBinding:
      prefix: "--sv-enable-liquid-tumor-mode="
      separate: False
      valueFrom: "$(self.toString())"
  sv_tin_contam_tolerance:
    label: sv tin contam tolerance
    doc: |
      Set the Tumor-in-Normal (TiN) contamination tolerance level.
      You can enter any value between 0-1. The default maximum TiN contamination tolerance is 0.15.
    type: float?
    inputBinding:
      prefix: "--sv-tin-contam-tolerance="
      separate: False

  # Variant calling options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/SmallVariantCaller.htm
  vc_target_bed:
    label: vc target bed
    doc: |
      This is an optional command line input that restricts processing of the small variant caller,
      target bed related coverage, and callability metrics to regions specified in a BED file.
    type: File?
    inputBinding:
      prefix: "--vc-target-bed="
      separate: False
  vc_target_bed_padding:
    label: vc target bed padding
    doc: |
      This is an optional command line input that can be used to pad all of the target
      BED regions with the specified value.
      For example, if a BED region is 1:1000-2000 and a padding value of 100 is used,
      it is equivalent to using a BED region of 1:900-2100 and a padding value of 0.

      Any padding added to --vc-target-bed-padding is used by the small variant caller
      and by the target bed coverage/callability reports. The default padding is 0.
    type: int?
    inputBinding:
      prefix: "--vc-target-bed-padding="
      separate: False
  vc_target_coverage:
    label: vc target coverage
    doc: |
      The --vc-target-coverage option specifies the target coverage for down-sampling.
      The default value is 500 for germline mode and 50 for somatic mode.
    type: int?
    inputBinding:
      prefix: "--vc-target-coverage="
      separate: False
  vc_target_vaf:
    label: vc target vaf
    doc: |
      The vc-target-vaf is used to select the variant allele frequencies of interest. 
      The variant caller will aim to detect variants with allele frequencies larger than this setting. 
      We recommend adding a small safety factor, e.g. to ensure variants in the ballpark of 1% are detected, 
      the minimum vc-target-vaf can be specified as 0.009 (0.9%). This setting will not apply a hard threshold, 
      and it is possible to detect variants with allele frequencies lower than the selected threshold. 
      On high coverage and clean datasets, a lower target-vaf may help increase sensitivity. 
      On noisy samples (like FFPE) a higher target-vaf (like 0.03) maybe help reduce false positives. 
      Using a low target-vaf may also increase runtime. Set the vc-target-vaf to 0 to disable this feature. 
      When this feature is disabled the variant caller will require at least 2 supporting reads to discover a candidate variant. 
      Default=0.01.
    type: float?
    inputBinding:
      prefix: "--vc-target-vaf="
      separate: False
  vc_enable_gatk_acceleration:
    label: vc enable gatk acceleration
    doc: |
      If is set to true, the variant caller runs in GATK mode
      (concordant with GATK 3.7 in germline mode and GATK 4.0 in somatic mode).
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-gatk-acceleration="
      separate: False
      valueFrom: "$(self.toString())"
  vc_remove_all_soft_clips:
    label: vc remove all soft clips
    doc: |
      If is set to true, the variant caller does not use soft clips of reads to determine variants.
    type: boolean?
    inputBinding:
      prefix: "--vc-remove-all-soft-clips="
      separate: False
      valueFrom: "$(self.toString())"
  vc_decoy_contigs:
    label: vc decoy contigs
    doc: |
      The --vc-decoy-contigs option specifies a comma-separated list of contigs to skip during variant calling.
      This option can be set in the configuration file.
    type: string?
    inputBinding:
      prefix: "--vc-decoy-contigs="
      separate: False
  vc_enable_decoy_contigs:
    label: vc enable decoy contigs
    doc: |
      If --vc-enable-decoy-contigs is set to true, variant calls on the decoy contigs are enabled.
      The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-decoy-contigs="
      separate: False
      valueFrom: "$(self.toString())"
  vc_enable_phasing:
    label: vc enable phasing
    doc: |
      The -vc-enable-phasing option enables variants to be phased when possible. The default value is true.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-phasing="
      separate: False
      valueFrom: "$(self.toString())"
  vc_enable_vcf_output:
    label: vc enable vcf output
    doc: |
      The -vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-vcf-output="
      separate: False
      valueFrom: "$(self.toString())"
  # Downsampling options
  vc_max_reads_per_active_region:
    label: vc max reads per active region
    doc: |
      specifies the maximum number of reads covering a given active region.
      Default is 10000 for the somatic workflow
    type: int?
    inputBinding:
      prefix: "--vc-max-reads-per-active-region="
      separate: False
  vc_max_reads_per_raw_region:
    label: vc max reads per raw region
    doc: |
      specifies the maximum number of reads covering a given raw region.
      Default is 30000 for the somatic workflow
    type: int?
    inputBinding:
      prefix: "--vc-max-read-per-raw-region="
      separate: False
  # Ploidy support
  sample_sex:
    label: sample sex
    doc: |
      Specifies the sex of a sample
    type:
      - "null"
      - type: enum
        symbols:
          - none
          - auto
          - male
          - female
    inputBinding:
      prefix: "--sample-sex="
      separate: False
  # ROH options
  vc_enable_roh:
    label: vc enable roh
    doc: |
      Enable or disable the ROH caller by setting this option to true or false. Enabled by default for human autosomes only.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-roh="
      separate: False
      valueFrom: "$(self.toString())"
  vc_roh_blacklist_bed:
    label: vc roh blacklist bed
    doc: |
      If provided, the ROH caller ignores variants that are contained in any region in the blacklist BED file.
      DRAGEN distributes blacklist files for all popular human genomes and automatically selects a blacklist to
      match the genome in use, unless this option is used explicitly select a file.
    type: File?
    inputBinding:
      prefix: "--vc-roh-blacklist-bed="
      separate: False
  # BAF options
  vc_enable_baf:
    label: vc enable baf
    doc: |
      Enable or disable B-allele frequency output. Enabled by default.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-baf="
      separate: False
      valueFrom: "$(self.toString())"
  # Somatic calling options
  vc_base_qual_threshold:
    label: vc base qual threshold
    doc: |
      (Replaces --vc-min-base-qual)
      Specifies the minimum base quality to be considered in the active region detection of the small variant caller. 
      The default value is 10.
    type: int?
    inputBinding:
      prefix: "--vc-base-qual-threshold="
      separate: False
  vc_min_tumor_read_qual:
    label: vc min tumor read qual
    type: int?
    doc: |
      The --vc-min-tumor-read-qual option specifies the minimum read quality (MAPQ) to be considered for
      variant calling. The default value is 3 for tumor-normal analysis or 20 for tumor-only analysis.
    inputBinding:
      prefix: "--vc-min-tumor-read-qual="
      separate: False
      valueFrom: "$(self.toString())"
  vc_callability_tumor_thresh:
    label: vc callability tumor thresh
    type: int?
    doc: |
      The --vc-callability-tumor-thresh option specifies the callability threshold for tumor samples. The
      somatic callable regions report includes all regions with tumor coverage above the tumor threshold.
    inputBinding:
      prefix: "--vc-callability-tumor-thresh="
      separate: False
  vc_callability_normal_thresh:
    label: vc callability normal thresh
    type: int?
    doc: |
      The --vc-callability-normal-thresh option specifies the callability threshold for normal samples.
      The somatic callable regions report includes all regions with normal coverage above the normal threshold.
    inputBinding:
      prefix: "--vc-callability-normal-thresh="
      separate: False
  vc_somatic_hotspots:
    label: vc somatic hotspots
    type: File?
    doc: |
      The somatic hotspots option allows an input VCF to specify the positions where the risk for somatic
      mutations are assumed to be significantly elevated. DRAGEN genotyping priors are boosted for all
      postions specified in the VCF, so it is possible to call a variant at one of these sites with fewer supporting
      reads. The cosmic database in VCF format can be used as one source of prior information to boost
      sensitivity for known somatic mutations.
    inputBinding:
      prefix: "--vc-somatic-hotspots="
      separate: False
  vc_hotspot_log10_prior_boost:
    label: vc hotspot log10 prior boost
    type: int?
    doc: |
      The size of the hotspot adjustment can be controlled via vc-hotspotlog10-prior-boost,
      which has a default value of 4 (log10 scale) corresponding to an increase of 40 phred.
    inputBinding:
      prefix: "--vc-hotspot-log10-prior-boost="
      separate: False
  vc_enable_liquid_tumor_mode:
    label: vc enable liquid tumor mode
    type: boolean?
    doc: |
      In a tumor-normal analysis, DRAGEN accounts for tumor-in-normal (TiN) contamination by running liquid
      tumor mode. Liquid tumor mode is disabled by default. When liquid tumor mode is enabled, DRAGEN is
      able to call variants in the presence of TiN contamination up to a specified maximum tolerance level.
      vc-enable-liquid-tumor-mode enables liquid tumor mode with a default maximum contamination
      TiN tolerance of 0.15. If using the default maximum contamination TiN tolerance, somatic variants are
      expected to be observed in the normal sample with allele frequencies up to 15% of the corresponding
      allele in the tumor sample.
    inputBinding:
      prefix: "--vc-enable-liquid-tumor-mode="
      separate: False
      valueFrom: "$(self.toString())"
  vc_tin_contam_tolerance:
    label: vc tin contam tolerance
    type: float?
    doc: |
      vc-tin-contam-tolerance enables liquid tumor mode and allows you to
      set the maximum contamination TiN tolerance. The maximum contamination TiN tolerance must be
      greater than zero. For example, vc-tin-contam-tolerance=-0.1.
    inputBinding:
      prefix: "--vc-tin-contam-tolerance="
      separate: False
  vc_enable_orientation_bias_filter:
    label: vc enable orientation bias filter
    type: boolean?
    doc: |
      Enables the orientation bias filter. The default value is false, which means the option is disabled.
    inputBinding:
      prefix: "--vc-enable-orientation-bias-filter="
      separate: False
      valueFrom: "$(self.toString())"
  vc_enable_orientation_bias_filter_artifacts:
    label: vc enable orientation bias filter artifacts
    type: string?
    doc: |
      The artifact type to be filtered can be specified with the --vc-orientation-bias-filter-artifacts option.
      The default is C/T,G/T, which correspond to OxoG and FFPE artifacts. Valid values include C/T, or G/T, or C/T,G/T,C/A.
      An artifact (or an artifact and its reverse compliment) cannot be listed twice.
      For example, C/T,G/A is not valid, because C->G and T->A are reverse compliments.
    inputBinding:
      prefix: "--vc-enable-orientation-bias-filter-artifacts="
      separate: False
      valueFrom: "$(self.toString())"
  # Post somatic calling filtering options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/PostSomaticFilters.htm
  vc_hard_filter:
    label: vc hard filter
    doc: |
      DRAGEN provides post-VCF variant filtering based on annotations present in the VCF records.
      However, due to the nature of DRAGEN's algorithms, which incorporate the hypothesis of correlated errors
      from within the core of variant caller, the pipeline has improved capabilities in distinguishing
      the true variants from noise, and therefore the dependency on post-VCF filtering is substantially reduced.
      For this reason, the default post-VCF filtering in DRAGEN is very simple
    type: string?
    inputBinding:
      prefix: "--vc-hard-filter="
      separate: False
      valueFrom: "$(self.toString())"
  vc_sq_call_threshold:
    label: vc sq call threshold
    type: float?
    doc: |
      Emits calls in the VCF. The default is 3.
      If the value for vc-sq-filter-threshold is lower than vc-sq-callthreshold,
      the filter threshold value is used instead of the call threshold value
    inputBinding:
      prefix: "--vc-sq-call-threshold="
      separate: False
  vc_sq_filter_threshold:
    label: vc sq filter threshold
    type: float?
    doc: |
      Marks emitted VCF calls as filtered.
      The default is 17.5 for tumor-normal and 6.5 for tumor-only.
    inputBinding:
      prefix: "--vc-sq-filter-threshold="
      separate: False
  vc_enable_triallelic_filter:
    label: vc enable triallelic filter
    type: boolean?
    doc: |
      Enables the multiallelic filter. The default is true.
    inputBinding:
      prefix: "--vc-enable-triallelic-filter="
      separate: False
      valueFrom: "$(self.toString())"
  vc_enable_af_filter:
    label: vc enable af filter
    type: boolean?
    doc: |
      Enables the allele frequency filter. The default value is false. When set to true, the VCF excludes variants
      with allele frequencies below the AF call threshold or variants with an allele frequency below the AF filter
      threshold and tagged with low AF filter tag. The default AF call threshold is 1% and the default AF filter
      threshold is 5%.
      To change the threshold values, use the following command line options:
        --vc-af-callthreshold and --vc-af-filter-threshold.
    inputBinding:
      prefix: "--vc-enable-af-filter="
      separate: False
      valueFrom: "$(self.toString())"
  vc_af_call_threshold:
    label: vc af call threshold
    type: float?
    doc: |
      Set the allele frequency call threshold to emit a call in the VCF if the AF filter is enabled.
      The default is 0.01.
    inputBinding:
      prefix: "--vc-af-call-threshold="
      separate: False
  vc_af_filter_threshold:
    label: vc af filter threshold
    type: float?
    doc: |
      Set the allele frequency filter threshold to mark emitted VCF calls as filtered if the AF filter is
      enabled.
      The default is 0.05.
    inputBinding:
      prefix: "--vc-af-filter-threshold="
      separate: False
  vc_enable_non_homref_normal_filter:
    label: vc enable non homoref normal filter
    doc: |
      Enables the non-homref normal filter. The default value is true. When set to true, the VCF filters out
      variants if the normal sample genotype is not a homozygous reference.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-non-homref-normal-filter="
      separate: False
      valueFrom: "$(self.toString())"

  # Mitochondrial allele frequency filters
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/MitochondrialCalling.htm
  vc_af_call_threshold_mito:
    label: vc af call threshold mito
    doc: |
      If the AF filter is enabled using --vc-enable-af-filter-mito=true,
      the option sets the allele frequency call threshold to emit a call in the VCF for mitochondrial variant calling.
      The default value is 0.01.
    type: boolean?
    inputBinding:
      prefix: "--vc-af-call-threshold-mito="
      separate: False
      valueFrom: "$(self.toString())"
  vc_af_filter_threshold_mito:
    label: vc af filter threshold mito
    doc: |
      If the AF filter is enabled using --vc-enable-af-filter-mito=true,
      the option sets the allele frequency filter threshold to mark emitted VCF calls
      as filtered for mitochondrial variant calling. The default value is 0.02.
    type: float?
    inputBinding:
      prefix: "--vc-af-filter-threshold-mito="
      separate: False
      valueFrom: "$(self.toString())"

  # Enable non primary allelic filter
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/PostSomaticFilters.htm
  vc_enable_non_primary_allelic_filter:
    label: vc enable non primary allelic filter
    doc: |
      Similar to vc-enable-triallelic-filter, but less aggressive.
      Keep the allele per position with highest alt AD, and only filter the rest.
      The default is false. Not compatible with vc-enable-triallelic-filter.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-non-primary-allelic-filter="
      separate: False
      valueFrom: "$(self.toString())"

  # Turn off ntd error bias estimation
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/SNVErrorEstimation.htm
  vc_enable_unequal_ntd:
    label: vc enable unequal ntd
    doc: |
      Nucleotide (NTD) Error Bias Estimation is on by default and recommended as a replacement for the orientation bias filter.
      Both methods take account of strand-specific biases (systematic differences between F1R2 and F2R1 reads).
      In addition, NTD error estimation accounts for non-strand-specific biases such as sample-wide elevation of a certain SNV type,
      eg C->T or any other transition or transversion.
      NTD error estimation can also capture the biases in a trinucleotide context.
    type:
      - "null"
      - boolean
      - type: enum
        symbols:
          - "true"
          - "false"
          - "auto"
    inputBinding:
      prefix: "--vc-enable-unequal-ntd="
      separate: False
      valueFrom: "$(self.toString())"


  # Phased / MNV Calling options
  vc_combine_phased_variants_distance:
    label: vc combine phased variants distance
    doc: |
      When the specified value is greater than 0, combines all phased variants in the phasing set that have a distance 
      less than or equal to the provided value. The max allowed phasing distance is 15. 
      The default value is 0, which disables the option.
    type: int?
    inputBinding:
      prefix: "--vc-combine-phased-variants-distance="
      separate: False
  vc_combine_phased_variants_max_vaf_delta:
    label: vc combine phased variants max vaf delta
    doc: |
      Component SNVs/INDELs of MNV calls are output only if the VAF of the component 
      call is greater than that of the MNV by more than 0.1. The VAF difference 
      threshold for outputting component calls along with MNV calls can be controlled by 
      the --vc-combine-phased-variants-max-vaf-delta option.
      This option is mutually exclusive with --vc-mnv-emit-component-calls
    type: float?
    inputBinding:
      prefix: "--vc-combine-phased-variants-max-vaf-delta="
      separate: False
  vc_mnv_emit_component_calls:
    label: vc mnv emit component calls
    doc: |
      To output all component SNVs/INDELs of MNVs, regardless of VAF difference, 
      when enabled, use the option --vc-mnv-emit-component-calls. 
      This option is mutually exclusive with --vc-combine-phased-variants-max-vaf-delta
    type: boolean?
    inputBinding:
      prefix: "--vc-mnv-emit-component-calls="
      separate: False
      valueFrom: "$(self.toString())"

  # dbSNP annotation
  dbsnp_annotation:
    label: dbsnp annotation
    doc: |
      In Germline, Tumor-Normal somatic, or Tumor-Only somatic modes,
      DRAGEN can look up variant calls in a dbSNP database and add annotations for any matches that it finds there.
      To enable the dbSNP database search, set the --dbsnp option to the full path to the dbSNP database
      VCF or .vcf.gz file, which must be sorted in reference order.
    type: File?
    secondaryFiles:
      - pattern: ".tbi"
        required: true
    inputBinding:
      prefix: "--dbsnp="
      separate: False

  # cnv pipeline - with this we must also specify one of --cnv-normal-b-allele-vcf,
  # --cnv-population-b-allele-vcf, or cnv-use-somatic-vc-baf.
  # If known, specify the sex of the sample.
  # If the sample sex is not specified, the caller attempts to estimate the sample sex from tumor alignments.
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/CopyNumVariantCalling.htm
  enable_cnv:
    label: enable cnv calling
    doc: |
      Enable CNV processing in the DRAGEN Host Software.
    type: boolean?
    inputBinding:
      prefix: "--enable-cnv="
      separate: False
      valueFrom: "$(self.toString())"
  cnv_normal_b_allele_vcf:
    label: cnv normal b allele vcf
    doc: |
      Specify a matched normal SNV VCF.
    type: File?
    inputBinding:
      prefix: "--cnv-normal-b-allele-vcf="
      separate: False
  cnv_population_b_allele_vcf:
    label: cnv population b allele vcf
    doc: |
      Specify a population SNP catalog.
    type: File?
    inputBinding:
      prefix: "--cnv-population-b-allele-vcf="
      separate: False
  cnv_use_somatic_vc_baf:
    label: cnv use somatic vc baf
    doc: |
      If running in tumor-normal mode with the SNV caller enabled, use this option
      to specify the germline heterozygous sites.
    type: boolean?
    inputBinding:
      prefix: "--cnv-use-somatic-vc-baf="
      separate: False
      valueFrom: "$(self.toString())"
  # For more info on following options - see
  # https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/DRAGEN/SomaticWGSModes.htm#Germline
  cnv_normal_cnv_vcf:
    label: cnv normal cnv vcf
    doc: |
      Specify germline CNVs from the matched normal sample.
    type: boolean?
    inputBinding:
      prefix: "--cnv-normal-cnv-vcf="
      separate: False
      valueFrom: "$(self.toString())"
  cnv_use_somatic_vc_vaf:
    label: cnv use somatic vc vaf
    doc: |
      Use the variant allele frequencies (VAFs) from the somatic SNVs to help select
      the tumor model for the sample.
    type: boolean?
    inputBinding:
      prefix: "--cnv-use-somatic-vc-vaf="
      separate: False
      valueFrom: "$(self.toString())"
  cnv_somatic_enable_het_calling:
    label: cnv somatic enable het calling
    doc: |
      Enable HET-calling mode for heterogeneous segments.
    type: boolean?
    inputBinding:
      prefix: "--cnv-somatic-enable-het-calling="
      separate: False
      valueFrom: "$(self.toString())"
  cnv_enable_self_normalization:
    label: cnv enable self normalization
    doc: |
      Enable CNV self normalization.
      Self Normalization requires that the DRAGEN hash table be generated with the enable-cnv=true option.
    type: boolean?
    inputBinding:
      prefix: "--cnv-enable-self-normalization="
      separate: False
      valueFrom: "$(self.toString())"
  cnv_somatic_enable_lower_ploidy_limit:
    label: cnv somatic enable lower ploidy limit
    doc: |
      To improve accuracy on the tumor ploidy model estimation, the somatic WGS CNV caller estimates whether the chosen model calls 
      homozygous deletions on regions that are likely to reduce the overall fitness of cells, 
      which are therefore deemed to be "essential" and under negative selection. 
      In the current literature, recent efforts tried to map such cell-essential genes (eg, in 2015 - https://www.science.org/doi/10.1126/science.aac7041).
      The check on essential regions is controlled with --cnv-somatic-enable-lower-ploidy-limit (default true).
    type: boolean?
    inputBinding:
      prefix: "--cnv-somatic-enable-lower-ploidy-limit="
      separate: False
      valueFrom: "$(self.toString())"
  cnv_somatic_essential_genes_bed:
    label: cnv somatic essential genes bed
    doc: |
      Default bedfiles describing the essential regions are provided for hg19, GRCh37, hs37d5, GRCh38, 
      but a custom bedfile can also be provided in input through the 
      --cnv-somatic-essential-genes-bed=<BEDFILE_PATH> parameter. 
      In such case, the feature is automatically enabled. 
      A custom essential regions bedfile needs to have the following format: 4-column, tab-separated, 
      where the first 3 columns identify the coordinates of the essential region (chromosome, 0-based start, excluded end). 
      The fourth column is the region id (string type). For the purpose of the algorithm, currently only the first 3 columns are used. 
      However, the fourth might be helpful to investigate manually which regions drove the decisions on model plausibility made by the caller.
    type:
      - "null"
      - string
      - File
    inputBinding:
      prefix: "--cnv-somatic-essential-genes-bed="
      separate: False

  # HRD
  enable_hrd:
    label: enable hrd
    doc: |
      Set to true to enable HRD scoring to quantify genomic instability.
      Requires somatic CNV calls.
    type: boolean?
    inputBinding:
      prefix: "--enable-hrd="
      separate: False
      valueFrom: "$(self.toString())"

  # QC options
  qc_coverage_region_1:
    label: qc coverage region 1
    doc: |
      Generates coverage region report using bed file 1.
    type: File?
    inputBinding:
      prefix: "--qc-coverage-region-1="
      separate: False
  qc_coverage_region_2:
    label: qc coverage region 2
    doc: |
      Generates coverage region report using bed file 2.
    type: File?
    inputBinding:
      prefix: "--qc-coverage-region-2="
      separate: False
  qc_coverage_region_3:
    label: qc coverage region 3
    doc: |
      Generates coverage region report using bed file 3.
    type: File?
    inputBinding:
      prefix: "--qc-coverage-region-3="
      separate: False
  qc_coverage_ignore_overlaps:
    label: qc coverage ignore overlaps
    doc: |
      Set to true to resolve all of the alignments for each fragment and avoid double-counting any
      overlapping bases. This might result in marginally longer run times.
      This option also requires setting --enable-map-align=true.
    type: boolean?
    inputBinding:
      prefix: "--qc-coverage-ignore-overlaps="
      separate: False
      valueFrom: "$(self.toString())"

  # TMB options
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/Biomarkers_TMB.htm
  enable_tmb:
    label: enable tmb
    doc: |
      Enables TMB. If set, the small variant caller, Illumina Annotation Engine,
      and the related callability report are enabled.
    type: boolean?
    inputBinding:
      prefix: "--enable-tmb="
      separate: False
      valueFrom: "$(self.toString())"
  tmb_vaf_threshold:
    label: tmb vaf threshold
    doc: |
      Specify the minimum VAF threshold for a variant. Variants that do not meet the threshold are filtered out.
      The default value is 0.05.
    type: float?
    inputBinding:
      prefix: "--tmb-db-threshold="
      separate: False
  tmb_db_threshold:
    label: tmb db threshold
    doc: |
      Specify the minimum allele count (total number of observations) for an allele in gnomAD or 1000 Genome
      to be considered a germline variant.  Variant calls that have the same positions and allele are ignored
      from the TMB calculation. The default value is 10.
    type: int?
    inputBinding:
      prefix: "--tmb-db-threshold="
      separate: False

  # HLA calling
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/HLACaller.htm
  enable_hla:
    label: enable hla
    doc: |
      Enable HLA typing by setting --enable-hla flag to true
    type: boolean?
    inputBinding:
      prefix: "--enable-hla="
      separate: False
      valueFrom: "$(self.toString())"
  hla_bed_file:
    label: hla bed file
    doc: |
      Use the HLA region BED input file to specify the region to extract HLA reads from.
      DRAGEN HLA Caller parses the input file for regions within the BED file, and then
      extracts reads accordingly to align with the HLA allele reference.
    type: File?
    inputBinding:
      prefix: "--hla-bed-file="
      separate: False
  hla_reference_file:
    label: hla reference file
    doc: |
      Use the HLA allele reference file to specify the reference alleles to align against.
      The input HLA reference file must be in FASTA format and contain the protein sequence separated into exons.
      If --hla-reference-file is not specified, DRAGEN uses hla_classI_ref_freq.fasta from /opt/edico/config/.
      The reference HLA sequences are obtained from the IMGT/HLA database.
    type: File?
    inputBinding:
      prefix: "--hla-reference-file="
      separate: False
  hla_allele_frequency_file:
    label: hla allele frequency file
    doc: |
      Use the population-level HLA allele frequency file to break ties if one or more HLA allele produces the same or similar results.
      The input HLA allele frequency file must be in CSV format and contain the HLA alleles and the occurrence frequency in population.
      If --hla-allele-frequency-file is not specified, DRAGEN automatically uses hla_classI_allele_frequency.csv from /opt/edico/config/.
      Population-level allele frequencies can be obtained from the Allele Frequency Net database.
    type: File?
    inputBinding:
      prefix: "--hla-allele-frequency-file="
      separate: False
  hla_tiebreaker_threshold:
    label: hla tiebreaker threshold
    doc: |
      If more than one allele has a similar number of reads aligned and there is not a clear indicator for the best allele,
      the alleles are considered as ties. The HLA Caller places the tied alleles into a candidate set for tie breaking based
      on the population allele frequency. If an allele has more than the specified fraction of reads aligned (normalized to
      the top hit), then the allele is included into the candidate set for tie breaking. The default value is 0.97.
    type: float?
    inputBinding:
      prefix: "--hla-tiebreaker-threshold="
      separate: False
  hla_zygosity_threshold:
    label: hla zygosity threshold
    doc: |
      If the minor allele at a given locus has fewer reads mapped than a fraction of the read count of the major allele,
      then the HLA Caller infers homozygosity for the given HLA-I gene. You can use this option to specify the fraction value.
      The default value is 0.15.
    type: float?
    inputBinding:
      prefix: "--hla zygosity threshold="
      separate: False
  hla_min_reads:
    label: hla min reads
    doc: |
      Set the minimum number of reads to align to HLA alleles to ensure sufficient coverage and perform HLA typing.
      The default value is 1000 and suggested for WES samples. If using samples with less coverage, you can use a
      lower threshold value.
    type: int?
    inputBinding:
      prefix: "--hla-min-reads="
      separate: False

  # RNA
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/DRAGEN/TPipelineIntro_fDG.htm
  enable_rna:
    label: enable rna
    doc: |
      Set this option for running RNA samples through T/N workflow
    type: boolean?
    inputBinding:
      prefix: "--enable-rna="
      separate: False
      valueFrom: "$(self.toString())"

  # Repeat Expansion
  # https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/RepeatGenotyping.htm
  repeat_genotype_enable:
    label: repeat genotype enable
    doc: |
      Enables repeat expansion detection.
    type: boolean?
    inputBinding:
      prefix: "--repeat-genotype-enable="
      separate: False
      valueFrom: "$(self.toString())"
  repeat_genotype_specs:
    label: repeat genotype specs
    doc: |
      Specifies the full path to the JSON file that contains the
      repeat variant catalog (specification) describing the loci to call.
      If the option is not provided, DRAGEN attempts to autodetect the applicable catalog file
      from /opt/edico/repeat-specs/ based on the reference provided.
    type: File?
    inputBinding:
      prefix: "--repeate-genotype-specs="
      separate: False
  repeat_genotype_use_catalog:
    label: repeat genotype use catalog
    doc: |
      Repeat variant catalog type to use (default - ~60 repeats, default_plus_smn -
      same as default with SMN repeat, expanded - ~50K repeats)
    type:
      - "null"
      - type: enum
        symbols:
          - default
          - default_plus_smn
          - expanded
    inputBinding:
      prefix: "--repeat-genotype-use-catalog="
      separate: False

  # Cross-sample Contamination
  qc_somatic_contam_vcf:
    label: qc somatic contam vcf
    doc: |
      The cross-contamination metric is enabled by including one of the following flags along with a compatible VCF.
      Pre-built contamination VCF files for different human references can be found at /opt/edico/config. 
      DRAGEN supports separate modes for germline and somatic samples. 
      For hg38 references, use somatic_sample_cross_contamination_resource_hg38.vcf.gz
      For hg19 references, use somatic_sample_cross_contamination_resource_hg19.vcf.gz
      For GRCh37 references, use somatic_sample_cross_contamination_resource_GRCh37.vcf.gz
    type:
      - "null"
      - File
      - type: enum
        symbols:
          - "hg38"
          - "hg19"
          - "GRCh37"
    inputBinding:
      prefix: "--qc-cross-cont-vcf="
      separate: False
      valueFrom: >-
        ${
        return get_somatic_cross_contamination_resource(self);
        }

  # Miscell
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
      prefix: "--lic-instance-id-location="
      separate: False

outputs:
  # Will also include mounted-files.txt
  dragen_somatic_output_directory:
    label: dragen somatic output directory
    doc: |
      Output directory containing all outputs of the somatic dragen run
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory)"
  # Optional output files (inside the output directory) that we'll continue to append to as we need them
  tumor_bam_out:
    label: output tumor bam
    doc: |
      Bam file of the tumor sample.
      Exists only if --enable-map-align-output set to true
    type: File?
    outputBinding:
      glob: "$(inputs.output_directory)/$(inputs.output_file_prefix)_tumor.bam"
    secondaryFiles:
      - ".bai"
  normal_bam_out:
    label: output normal bam
    doc: |
      Bam file of the normal sample
      Exists only if --enable-map-align-output set to true
    type: File?
    outputBinding:
      glob: "$(inputs.output_directory)/$(get_normal_output_prefix(inputs)).bam"
    secondaryFiles:
      - ".bai"
  somatic_snv_vcf_out:
    label: somatic snv vcf
    doc: |
      Output of the snv vcf tumor calls
    type: File?
    outputBinding:
      glob: "$(inputs.output_directory)/$(inputs.output_file_prefix).vcf.gz"
    secondaryFiles:
      - ".tbi"
  somatic_snv_vcf_hard_filtered_out:
    label: somatic snv vcf filetered
    doc: |
      Output of the snv vcf filtered tumor calls
    type: File?
    outputBinding:
      glob: "$(inputs.output_directory)/$(inputs.output_file_prefix).hard-filtered.vcf.gz"
    secondaryFiles:
      - ".tbi"
  somatic_structural_vcf_out:
    label: somatic sv vcf filetered
    doc: |
      Output of the sv vcf filtered tumor calls.
      Exists only if --enable-sv is set to true.
    type: File?
    outputBinding:
      glob: "$(inputs.output_directory)/$(inputs.output_file_prefix).sv.vcf.gz"
    secondaryFiles:
      - ".tbi"

successCodes:
  - 0

