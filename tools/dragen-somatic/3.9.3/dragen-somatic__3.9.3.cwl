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
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

s:maintainer:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: dragen-somatic--3.9.3
label: dragen-somatic v(3.9.3)
doc: |
  Run tumor-normal dragen somatic pipeline v 3.9.3.
  Workflow takes in two separate lists of object stor version of the fastq_list.csv equivalent
  See the fastq_list_row schema definitions for more information.
  More information on the documentation can be found [here](https://sapac.support.illumina.com/content/dam/illumina-support/help/Illumina_DRAGEN_Bio_IT_Platform_v3_7_1000000141465/Content/SW/Informatics/Dragen/GPipelineSomCom_appDRAG.htm).

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: fpga
        ilmn-tes:resources/size: medium
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: "699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:3.9.3"

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - var get_script_path = function(){
          /*
          Abstract script path, can then be referenced in baseCommand attribute too
          Makes things more readable.
          */
          return "scripts/run-dragen-script.sh";
        }
      - var get_dragen_bin_path = function(){
          /*
          Return the path of the dragen binary
          */
          return "/opt/edico/bin/dragen";
        }
      - var get_scratch_mount = function(){
          /*
          Return the path of the scratch directory space
          */
          return "/ephemeral/";
        }
      - var get_intermediate_results_dir = function() {
          /*
          Place of the intermediate results files
          */
          return get_scratch_mount() + "intermediate-results/";
        }
      - var get_fastq_list_csv_path = function() {
          /*
          The fastq list path must be placed in working directory
          */
          return "fastq_list.csv"
        }
      - var get_tumor_fastq_list_csv_path = function() {
          /*
          The tumor fastq list path must be placed in working directory
          */
          return "tumor_fastq_list.csv"
        }
      - var get_ref_mount = function() {
          /*
          Return the path of where the reference data is to be staged
          */
          return get_scratch_mount() + "ref/";
        }
      - var get_name_root_from_tarball = function(tar_file) {
          /*
          Get the name of the reference folder
          */
          var tar_ball_regex = /(\S+)\.tar\.gz/g;
          return tar_ball_regex.exec(tar_file)[1];
        }
      - var get_ref_path = function(input_obj) {
          /*
          Return the path of where the reference data is staged + the reference name
          */
          return get_ref_mount() + get_name_root_from_tarball(input_obj.basename) + "/";
        }
      - var get_value_as_str = function(input_parameter){
          if (input_parameter === null){
            return "";
          } else {
            return input_parameter.toString();
          }
        }
      - var boolean_to_int = function(input_bool){
          /*
          Return 0 for false and 1 for true
          */
          return Number(String(input_bool).toLowerCase() === "true");
        }
      - var get_normal_name_from_fastq_list_rows = function(){
          /*
          Get the normal sample name form  fastq list rows object
          */

          /*
          Check fastq list rows is defined
          */
          if (inputs.fastq_list_rows === null){
              return null;
          }

          /*
          Get RGSM value and return
          */
          var rgsm_value = inputs.fastq_list_rows[0].rgsm

          /*
          If rgsm is not in input, return null else return the value
          */
          if (rgsm_value == null) {
              return null;
          } else {
              return rgsm_value;
          }  
        }
      - var get_normal_name_from_fastq_list_csv = function(){
          /*
          First try getting the normal name from the fastq list rows (if defined in the inputs)  
          */
          if (get_normal_name_from_fastq_list_rows() !== null){
              return get_normal_name_from_fastq_list_rows();
          }

          /*
          Otherwise, get the normal list path from the input fastq list csv path
          */

          /*
          Check fastq list is defined
          */
          if (inputs.fastq_list === null){
              return null;
          }

          /*
          Check contents are defined
          */
          if (inputs.fastq_list.contents === null){
              return null;
          }

          /*
          Get header line
          */
          var column_names = inputs.fastq_list.contents.split("\n")[0].split(",")

          /*
          Get RGSM index value
          */
          var rgsm_index = column_names.indexOf("RGSM")

          /*
          RGSM is not in index. Return null
          */
          if (rgsm_index === -1){
              return null;
          }

          /*
          Get RGSM value of first row and return
          */
          return inputs.fastq_list.contents.split("\n")[1].split(",")[rgsm_index];
        }
      - var get_normal_output_prefix = function(){
          /*
          Get the normal RGSM value and then add _normal to it
          */
          return get_normal_name_from_fastq_list_csv() + "_normal";
        }
      - var get_dragen_eval_line = function(){
          /*
          ICA is inconsistent with cwl when it comes to handling @
          */
          return "eval \"" + get_dragen_bin_path() + "\" '\"\$@\"' \n";
        }
      - var is_not_null = function(input_object){
          if (input_object === null){
            return "false";
          } else {
            return "true";
          }
        }
      - var get_unique_elements_of_list = function(list){
          /*
          Get unique elements of an array - https://stackoverflow.com/a/39272981/6946787
          */
          return list.filter(function (x, i, a) {
              return a.indexOf(x) == i;
          });
        }
      - var convert_to_csv = function(double_array, column_headers){
          /*
          Given a list of lists and a set of column headers, generate a csv
          */
          var str = column_headers.join(",") + "\n";
          for (var line_iter=0; line_iter < double_array.length; line_iter++){
            str += double_array[line_iter].join(",") + "\n";
          }

          /*
          Return string of csv
          */
          return str;
        }
      - var get_fastq_list_csv_contents_from_fastq_list_rows_object = function(fastq_list_rows_object){
          /*
          Get the fastq list csv contents
          Get full set of keys and values
          */
          var all_keys = [];
          var all_row_values = [];
          
          /*
          Get all keys from all rows
          */
          fastq_list_rows_object.forEach(
            function(fastq_list_row) {
              /*
              Iterate over all fastq list rows and collect all possible key values
              */
              var row_keys = Object.keys(fastq_list_row);
              all_keys = all_keys.concat(row_keys);
            }
          );
        
          /*
          Unique keys - this will be the header of the csv
          */
          var all_unique_keys = get_unique_elements_of_list(all_keys);

          /*
          Now get items from each fastq list rows object for each key
          */
          fastq_list_rows_object.forEach(
            function(fastq_list_row) {
              /*
              Iterate over all fastq list rows and collect item for each key
              */
              var row_values = [];
          
              all_unique_keys.forEach(
                function(key){
                  if (fastq_list_row[key] === null){
                    row_values.push("");
                  } else if ( fastq_list_row[key] !== null && fastq_list_row[key].class === "File" ){
                    row_values.push(fastq_list_row[key].path);
                  } else {
                    row_values.push(fastq_list_row[key]);
                  }
                }
            );
            all_row_values.push(row_values)
          });

          /*
          Update rglb, rgsm and rgid to RGLB, RGSM and RGID respectively
          Update read_1 and read_2 to Read1File and Read2File in column headers
          Update lane to Lane
          */
          var all_unique_keys_renamed = [];
          for (var key_iter=0; key_iter < all_unique_keys.length; key_iter++ ){
            var key_value = all_unique_keys[key_iter];
            if (key_value.indexOf("rg") === 0){
              all_unique_keys_renamed.push(key_value.toUpperCase());
            } else if (key_value === "read_1"){
              all_unique_keys_renamed.push("Read1File");
            } else if (key_value === "read_2"){
              all_unique_keys_renamed.push("Read2File");
            } else if (key_value === "lane"){
              all_unique_keys_renamed.push("Lane");
            }
          }

          /*
          Return the string value of the csv
          */
          return convert_to_csv(all_row_values, all_unique_keys_renamed);
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: $(get_script_path())
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Confirm not both fastq_list and fastq_list_rows are defined
          if [[ "$(boolean_to_int(is_not_null(inputs.fastq_list)) + boolean_to_int(is_not_null(inputs.fastq_list_rows)) + boolean_to_int(is_not_null(inputs.bam_input)))" -gt "1" ]]; then
            echo "Please set no more than one of fastq_list, fastq_list_rows and bam_input for normal sample" 1>&2
            exit 1
          fi
          
          # Ensure that at one and ONLY one of tumor_fastq_list, tumor_fastq_list_rows and tumor_bam_input are defined
          if [[ "$(boolean_to_int(is_not_null(inputs.tumor_fastq_list)) + boolean_to_int(is_not_null(inputs.tumor_fastq_list_rows)) + boolean_to_int(is_not_null(inputs.tumor_bam_input)))" -ne "1" ]]; then
              echo "One and only one of inputs tumor_fastq_list, inputs.tumor_fastq_list_rows, inputs.tumor_bam_input must be defined" 1>&2
              exit 1
          fi

          # Initialise dragen
          /opt/edico/bin/dragen \\
            --partial-reconfig DNA-MAPPER \\
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

          # Run dragen command and import options from cli
          $(get_dragen_eval_line())

          # Check if fastq_list or fastq_list_rows is set
          if [[ "$(is_not_null(inputs.fastq_list))" == "true" || "$(is_not_null(inputs.fastq_list_rows))" == "true" || "$(is_not_null(inputs.bam_input))" == "true" ]]; then
            # Check if --enable-map-align-output is set
            if [[ ! "$(get_value_as_str(inputs.enable_map_align_output))" == "true" ]]; then
              echo "--enable-map-align-output not set, no need to move normal bam file" 1>&2
              echo "Exiting" 1>&2
              exit
            fi

            # Ensure that we have a normal RGSM value, otherwise exit.
            if [[ -z "$(get_value_as_str(get_normal_name_from_fastq_list_csv()))" ]]; then
              echo "Could not get the normal bam file prefix" 1>&2
              echo "Exiting" 1>&2
              exit
            fi

            # Get new normal file name prefix from the fastq_list.csv
            new_normal_file_name_prefix="$(get_normal_output_prefix())"

            # Ensure output normal bam file exists and the destination normal bam file also does not exist yet
            if [[ -f "$(inputs.output_directory)/$(inputs.output_file_prefix).bam" && ! -f "$(inputs.output_directory)/\${new_normal_file_name_prefix}.bam" ]] ; then
              # Move normal bam, normal bam index and normal bam md5sum
              (
                cd "$(inputs.output_directory)"
                mv "$(inputs.output_file_prefix).bam" "\${new_normal_file_name_prefix}.bam"
                mv "$(inputs.output_file_prefix).bam.bai" "\${new_normal_file_name_prefix}.bam.bai"
                mv "$(inputs.output_file_prefix).bam.md5sum" "\${new_normal_file_name_prefix}.bam.md5sum"
              )
            fi
          fi
      - |
        ${
            /*
            Create and add in the fastq list csv for the input fastqs
            */  
            var e = [];      
            if (inputs.fastq_list_rows !== null){
              e.push({
                        "entryname": get_fastq_list_csv_path(),
                        "entry": get_fastq_list_csv_contents_from_fastq_list_rows_object(inputs.fastq_list_rows)
                        });
            } 
            
            if (inputs.tumor_fastq_list_rows !== null){
              e.push({
                        "entryname": get_tumor_fastq_list_csv_path(),
                        "entry": get_fastq_list_csv_contents_from_fastq_list_rows_object(inputs.tumor_fastq_list_rows)
                        });
            } 
            
            if (inputs.fastq_list !== null){
              e.push({
                        "entryname": get_fastq_list_csv_path(),
                        "entry": inputs.fastq_list
                        });
            } 
            
            if (inputs.tumor_fastq_list !== null){
              e.push({
                        "entryname": get_tumor_fastq_list_csv_path(),
                        "entry": inputs.tumor_fastq_list
                        });
            } 
            
            /*
            Return file paths
            */
            return e;
        }

baseCommand: ["bash"]

arguments:
  # Run Script
  - position: -1
    valueFrom: "$(get_script_path())"
  # Mandatory arguments for the somatic workflow
  - prefix: "--enable-variant-caller"
    valueFrom: "true"
  - prefix: "--intermediate-results-dir"
    valueFrom: "$(get_intermediate_results_dir())"

inputs:
  # File inputs
  # Option 1
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files for normal sample
      to process. read_1 and read_2 components in the CSV file must be presigned urls.
    type: File?
    inputBinding:
      loadContents: true
      prefix: "--fastq-list"
      valueFrom: "$(get_fastq_list_csv_path())"
  tumor_fastq_list:
    label: tumor fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process. read_1 and read_2 components in the CSV file must be presigned urls.
    type: File?
    inputBinding:
      prefix: "--tumor-fastq-list"
      valueFrom: "$(get_tumor_fastq_list_csv_path())"
  # Option 2
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects for normal sample
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
    inputBinding:
      prefix: "--fastq-list"
      valueFrom: "$(get_fastq_list_csv_path())"
  tumor_fastq_list_rows:
    label: tumor fastq list rows
    doc: |
      Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects for tumor sample
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
    inputBinding:
      prefix: "--tumor-fastq-list"
      valueFrom: "$(get_tumor_fastq_list_csv_path())"
  # Option 3
  bam_input:
    label: bam input
    doc: |
      Input a normal BAM file for the variant calling stage
    type: File?
    inputBinding:
      prefix: "--bam-input"
  tumor_bam_input:
    label: tumor bam input
    doc: |
      Input a tumor BAM file for the variant calling stage
    type: File?
    inputBinding:
      prefix: "--tumor-bam-input"
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
    inputBinding:
      prefix: "--ref-dir"
      valueFrom: "$(get_ref_path(self))"
  # Naming options
  output_directory:
    label: output directory
    doc: |
      Required - The output directory.
    type: string
    inputBinding:
      prefix: "--output-directory"
  output_file_prefix:
    label: output file prefix
    doc: |
      Required - the output file prefix
    type: string
    inputBinding:
      prefix: "--output-file-prefix"
  # Optional operation modes
  # Given we're running from fastqs
  # --enable-variant-caller option must be set to true (set in arguments), --enable-map-align is then activated by default
  # --enable-map-align-output to keep bams
  # --enable-duplicate-marking to mark duplicate reads at the same time
  # --enable-sv to enable the structural variant calling step.
  enable_map_align_output:
    label: enable map align output
    doc: |
      Enables saving the output from the
      map/align stage. Default is true when only
      running map/align. Default is false if
      running the variant caller.
    type: boolean
    inputBinding:
      prefix: "--enable-map-align-output"
      valueFrom: "$(self.toString())"
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Enable the flagging of duplicate output
      alignment records.
    type: boolean
    inputBinding:
      prefix: "--enable-duplicate-marking"
      valueFrom: "$(self.toString())"
  enable_sv:
    label: enable sv
    doc: |
      Enable/disable structural variant
      caller. Default is false.
    type: boolean?
    inputBinding:
      prefix: "--enable-sv"
      valueFrom: "$(self.toString())"
  # Structural Variant Caller Options
  sv_call_regions_bed:
    label: sv call regions bed
    doc: |
      Specifies a BED file containing the set of regions to call.
    type: File?
    inputBinding:
      prefix: "--sv-call-regions-bed"
  sv_region:
    label: sv region
    doc: |
      Limit the analysis to a specified region of the genome for debugging purposes.
      This option can be specified multiple times to build a list of regions.
      The value must be in the format “chr:startPos-endPos”..
    type: string?
    inputBinding:
      prefix: "--sv-region"
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
      prefix: "--sv-exome"
      valueFrom: "$(self.toString())"
  sv_output_contigs:
    label: sv output contigs
    doc: |
      Set to true to have assembled contig sequences output in a VCF file. The default is false.
    type: boolean?
    inputBinding:
      prefix: "--sv-output-contigs"
      valueFrom: "$(self.toString())"
  sv_forcegt_vcf:
    label: sv forcegt vcf
    doc: |
      Specify a VCF of structural variants for forced genotyping. The variants are scored and emitted
      in the output VCF even if not found in the sample data.
      The variants are merged with any additional variants discovered directly from the sample data.
    type: File?
    inputBinding:
      prefix: "--sv-forcegt-vcf"
  sv_discovery:
    label: sv discovery
    doc: |
      Enable SV discovery. This flag can be set to false only when --sv-forcegt-vcf is used.
      When set to false, SV discovery is disabled and only the forced genotyping input variants
      are processed. The default is true.
    type: boolean?
    inputBinding:
      prefix: "--sv-discovery"
      valueFrom: "$(self.toString())"
  sv_se_overlap_pair_evidence:
    label: sv use overlap pair evidence
    doc: |
      Allow overlapping read pairs to be considered as evidence.
      By default, DRAGEN uses autodetect on the fraction of overlapping read pairs if <20%.
    type: boolean?
    inputBinding:
      prefix: "--sv-use-overlap-pair-evidence"
      valueFrom: "$(self.toString())"
  sv_somatic_ins_tandup_hotspot_regions_bed:
    label: sv somatic ins tandup hotspot regions bed
    doc: |
      Specify a BED of ITD hotspot regions to increase sensitivity for calling ITDs in somatic variant analysis.
      By default, DRAGEN SV automatically selects areference-specific hotspots BED file from
      /opt/edico/config/sv_somatic_ins_tandup_hotspot_*.bed.
    type: File?
    inputBinding:
      prefix: "--sv-somatic-ins-tandup-hotspot-regions-bed"
  sv_enable_somatic_ins_tandup_hotspot_regions:
    label: sv enable somatic ins tandup hotspot regions
    doc: |
      Enable or disable the ITD hotspot region input. The default is true in somatic variant analysis.
    type: boolean?
    inputBinding:
      prefix: "--sv-enable-somatic-ins-tandup-hotspot-regions"
      valueFrom: "$(self.toString())"
  sv_enable_liquid_tumor_mode:
    label: sv enable liquid tumor mode
    doc: |
      Enable liquid tumor mode.
    type: boolean?
    inputBinding:
      prefix: "--sv-enable-liquid-tumor-mode"
      valueFrom: "$(self.toString())"
  sv_tin_contam_tolerance:
    label: sv tin contam tolerance
    doc: |
      Set the Tumor-in-Normal (TiN) contamination tolerance level.
      You can enter any value between 0–1. The default maximum TiN contamination tolerance is 0.15.
    type: float?
    inputBinding:
      prefix: "--sv-tin-contam-tolerance"

  # Variant calling optons
  vc_target_bed:
    label: vc target bed
    doc: |
      This is an optional command line input that restricts processing of the small variant caller,
      target bed related coverage, and callability metrics to regions specified in a BED file.
    type: File?
    inputBinding:
      prefix: "--vc-target-bed"
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
      prefix: "--vc-target-bed-padding"
  vc_target_coverage:
    label: vc target coverage
    doc: |
      The --vc-target-coverage option specifies the target coverage for down-sampling.
      The default value is 500 for germline mode and 50 for somatic mode.
    type: int?
    inputBinding:
      prefix: "--vc-target-coverage"
  vc_enable_gatk_acceleration:
    label: vc enable gatk acceleration
    doc: |
      If is set to true, the variant caller runs in GATK mode
      (concordant with GATK 3.7 in germline mode and GATK 4.0 in somatic mode).
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-gatk-acceleration"
      valueFrom: "$(self.toString())"
  vc_remove_all_soft_clips:
    label: vc remove all soft clips
    doc: |
      If is set to true, the variant caller does not use soft clips of reads to determine variants.
    type: boolean?
    inputBinding:
      prefix: "--vc-remove-all-soft-clips"
      valueFrom: "$(self.toString())"
  vc_decoy_contigs:
    label: vc decoy contigs
    doc: |
      The --vc-decoy-contigs option specifies a comma-separated list of contigs to skip during variant calling.
      This option can be set in the configuration file.
    type: string?
    inputBinding:
      prefix: "--vc-decoy-contigs"
  vc_enable_decoy_contigs:
    label: vc enable decoy contigs
    doc: |
      If --vc-enable-decoy-contigs is set to true, variant calls on the decoy contigs are enabled.
      The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-decoy-contigs"
      valueFrom: "$(self.toString())"
  vc_enable_phasing:
    label: vc enable phasing
    doc: |
      The –vc-enable-phasing option enables variants to be phased when possible. The default value is true.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-phasing"
      valueFrom: "$(self.toString())"
  vc_enable_vcf_output:
    label: vc enable vcf output
    doc: |
      The –vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-vcf-output"
      valueFrom: "$(self.toString())"
  # Downsampling options
  vc_max_reads_per_active_region:
    label: vc max reads per active region
    doc: |
      specifies the maximum number of reads covering a given active region.
      Default is 10000 for the somatic workflow
    type: int?
    inputBinding:
      prefix: "--vc-max-reads-per-active-region"
  vc_max_reads_per_raw_region:
    label: vc max reads per raw region
    doc: |
      specifies the maximum number of reads covering a given raw region.
      Default is 30000 for the somatic workflow
    type: int?
    inputBinding:
      prefix: "--vc-max-read-per-raw-region"
  # Ploidy support
  sample_sex:
    label: sample sex
    doc: |
      Specifies the sex of a sample
    type:
      - "null"
      - type: enum
        symbols:
          - male
          - female
  # ROH options
  vc_enable_roh:
    label: vc enable roh
    doc: |
      Enable or disable the ROH caller by setting this option to true or false. Enabled by default for human autosomes only.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-roh"
      valueFrom: "$(self.toString())"
  vc_roh_blacklist_bed:
    label: vc roh blacklist bed
    doc: |
      If provided, the ROH caller ignores variants that are contained in any region in the blacklist BED file.
      DRAGEN distributes blacklist files for all popular human genomes and automatically selects a blacklist to
      match the genome in use, unless this option is used explicitly select a file.
    type: File?
    inputBinding:
      prefix: "--vc-roh-blacklist-bed"
  # BAF options
  vc_enable_baf:
    label: vc enable baf
    doc: |
      Enable or disable B-allele frequency output. Enabled by default.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-baf"
  # Somatic calling options
  vc_min_tumor_read_qual:
    label: vc min tumor read qual
    type: int?
    doc: |
      The --vc-min-tumor-read-qual option specifies the minimum read quality (MAPQ) to be considered for
      variant calling. The default value is 3 for tumor-normal analysis or 20 for tumor-only analysis.
    inputBinding:
      prefix: --vc-min-tumor-read-qual
  vc_callability_tumor_thresh:
    label: vc callability tumor thresh
    type: int?
    doc: |
      The --vc-callability-tumor-thresh option specifies the callability threshold for tumor samples. The
      somatic callable regions report includes all regions with tumor coverage above the tumor threshold.
    inputBinding:
      prefix: --vc-callability-tumor-thresh
  vc_callability_normal_thresh:
    label: vc callability normal thresh
    type: int?
    doc: |
      The --vc-callability-normal-thresh option specifies the callability threshold for normal samples.
      The somatic callable regions report includes all regions with normal coverage above the normal threshold.
    inputBinding:
      prefix: --vc-callability-normal-thresh
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
      prefix: --vc-somatic-hotspots
  vc_hotspot_log10_prior_boost:
    label: vc hotspot log10 prior boost
    type: int?
    doc: |
      The size of the hotspot adjustment can be controlled via vc-hotspotlog10-prior-boost,
      which has a default value of 4 (log10 scale) corresponding to an increase of 40 phred.
    inputBinding:
      prefix: --vc-hotspot-log10-prior-boost
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
      prefix: --vc-enable-liquid-tumor-mode
      valueFrom: "$(self.toString())"
  vc_tin_contam_tolerance:
    label: vc tin contam tolerance
    type: float?
    doc: |
      vc-tin-contam-tolerance enables liquid tumor mode and allows you to
      set the maximum contamination TiN tolerance. The maximum contamination TiN tolerance must be
      greater than zero. For example, vc-tin-contam-tolerance=-0.1.
    inputBinding:
      prefix: --vc-tin-contam-tolerance
  vc_enable_orientation_bias_filter:
    label: vc enable orientation bias filter
    type: boolean?
    doc: |
      Enables the orientation bias filter. The default value is false, which means the option is disabled.
    inputBinding:
      prefix: --vc-enable-orientation-bias-filter
      valueFrom: "$(self.toString())"
  vc_enable_orientation_bias_filter_artifacts:
    label: vc enable orientation bias filter artifacts
    type: string?
    doc: |
      The artifact type to be filtered can be specified with the --vc-orientation-bias-filter-artifacts option. 
      The default is C/T,G/T, which correspond to OxoG and FFPE artifacts. Valid values include C/T, or G/T, or C/T,G/T,C/A.
      An artifact (or an artifact and its reverse compliment) cannot be listed twice. 
      For example, C/T,G/A is not valid, because C→G and T→A are reverse compliments.
    inputBinding:
      prefix: --vc-enable-orientation-bias-filter-artifacts
      valueFrom: "$(self.toString())"
  # Post somatic calling filtering options
  vc_sq_call_threshold:
    label: vc sq call threshold
    type: float?
    doc: |
      Emits calls in the VCF. The default is 3.
      If the value for vc-sq-filter-threshold is lower than vc-sq-callthreshold,
      the filter threshold value is used instead of the call threshold value
    inputBinding:
      prefix: --vc-sq-call-threshold
  vc_sq_filter_threshold:
    label: vc sq filter threshold
    type: float?
    doc: |
      Marks emitted VCF calls as filtered.
      The default is 17.5 for tumor-normal and 6.5 for tumor-only.
    inputBinding:
      prefix: --vc-sq-filter-threshold
  vc_enable_triallelic_filter:
    label: vc enable triallelic filter
    type: boolean?
    doc: |
      Enables the multiallelic filter. The default is true.
    inputBinding:
      prefix: --vc-enable-triallelic-filter
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
      prefix: --vc-enable-af-filter
      valueFrom: "$(self.toString())"
  vc_af_call_threshold:
    label: vc af call threshold
    type: float?
    doc: |
      Set the allele frequency call threshold to emit a call in the VCF if the AF filter is enabled.
      The default is 0.01.
    inputBinding:
      prefix: --vc-af-call-threshold
  vc_af_filter_threshold:
    label: vc af filter threshold
    type: float?
    doc: |
      Set the allele frequency filter threshold to mark emitted VCF calls as filtered if the AF filter is
      enabled.
      The default is 0.05.
    inputBinding:
      prefix: --vc-af-filter-threshold
  vc_enable_non_homref_normal_filter:
    label: vc enable non homoref normal filter
    type: boolean?
    doc: |
      Enables the non-homref normal filter. The default value is true. When set to true, the VCF filters out
      variants if the normal sample genotype is not a homozygous reference.
    inputBinding:
      prefix: --vc-enable-non-homref-normal-filter
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
      prefix: "--dbsnp"
  # cnv pipeline - with this we must also specify one of --cnv-normal-b-allele-vcf,
  # --cnv-population-b-allele-vcf, or cnv-use-somatic-vc-baf.
  # If known, specify the sex of the sample.
  # If the sample sex is not specified, the caller attempts to estimate the sample sex from tumor alignments.
  enable_cnv:
    label: enable cnv calling
    doc: |
      Enable CNV processing in the DRAGEN Host Software.
    type: boolean?
    inputBinding:
      prefix: --enable-cnv
      valueFrom: "$(self.toString())"
  cnv_normal_b_allele_vcf:
    label: cnv normal b allele vcf
    doc: |
      Specify a matched normal SNV VCF.
    type: File?
    inputBinding:
      prefix: --cnv-normal-b-allele-vcf
  cnv_population_b_allele_vcf:
    label: cnv population b allele vcf
    doc: |
      Specify a population SNP catalog.
    type: File?
    inputBinding:
      prefix: --cnv-population-b-allele-vcf
  cnv_use_somatic_vc_baf:
    label: cnv use somatic vc baf
    doc: |
      If running in tumor-normal mode with the SNV caller enabled, use this option
      to specify the germline heterozygous sites.
    type: boolean?
    inputBinding:
      prefix: --cnv-use-somatic-vc-baf
      valueFrom: "$(self.toString())"
  # For more info on following options - see
  # https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/DRAGEN/SomaticWGSModes.htm#Germline
  cnv_normal_cnv_vcf:
    label: cnv normal cnv vcf
    doc: |
      Specify germline CNVs from the matched normal sample.
    type: boolean?
    inputBinding:
      prefix: --cnv-normal-cnv-vcf
      valueFrom: "$(self.toString())"
  cnv_use_somatic_vc_vaf:
    label: cnv use somatic vc vaf
    doc: |
      Use the variant allele frequencies (VAFs) from the somatic SNVs to help select
      the tumor model for the sample.
    type: boolean?
    inputBinding:
      prefix: --cnv-use-somatic-vc-vaf
      valueFrom: "$(self.toString())"
  cnv_somatic_enable_het_calling:
    label: cnv somatic enable het calling
    doc: |
      Enable HET-calling mode for heterogeneous segments.
    type: boolean?
    inputBinding:
      prefix: --cnv-somatic-enable-het-calling
      valueFrom: "$(self.toString())"
  # HRD
  enable_hrd:
    label: enable hrd
    doc: |
      Set to true to enable HRD scoring to quantify genomic instability.
      Requires somatic CNV calls.
    type: boolean?
    inputBinding:
      prefix: --enable-hrd
      valueFrom: "$(self.toString())"
  # QC options
  qc_coverage_region_1:
    label: qc coverage region 1
    doc: |
      Generates coverage region report using bed file 1.
    type: File?
    inputBinding:
      prefix: --qc-coverage-region-1
  qc_coverage_region_2:
    label: qc coverage region 2
    doc: |
      Generates coverage region report using bed file 2.
    type: File?
    inputBinding:
      prefix: --qc-coverage-region-2
  qc_coverage_region_3:
    label: qc coverage region 3
    doc: |
      Generates coverage region report using bed file 3.
    type: File?
    inputBinding:
      prefix: --qc-coverage-region-3
  qc_coverage_ignore_overlaps:
    label: qc coverage ignore overlaps
    doc: |
      Set to true to resolve all of the alignments for each fragment and avoid double-counting any
      overlapping bases. This might result in marginally longer run times.
      This option also requires setting --enable-map-align=true.
    type: boolean?
    inputBinding:
      prefix: --qc-coverage-ignore-overlaps
      valueFrom: "$(self.toString())"
  # TMB options
  enable_tmb:
    label: enable tmb
    doc: |
      Enables TMB. If set, the small variant caller, Illumina Annotation Engine,
      and the related callability report are enabled.
    type: boolean?
    inputBinding:
      prefix: --enable-tmb
      valueFrom: "$(self.toString())"
  tmb_vaf_threshold:
    label: tmb vaf threshold
    doc: |
      Specify the minimum VAF threshold for a variant. Variants that do not meet the threshold are filtered out.
      The default value is 0.05.
    type: float?
    inputBinding:
      prefix: --tmb-db-threshold
  tmb_db_threshold:
    label: tmb db threshold
    doc: |
      Specify the minimum allele count (total number of observations) for an allele in gnomAD or 1000 Genome
      to be considered a germline variant.  Variant calls that have the same positions and allele are ignored
      from the TMB calculation. The default value is 10.
    type: int?
    inputBinding:
      prefix: --tmb-db-threshold
  # HLA calling
  enable_hla:
    label: enable hla
    doc: |
      Enable HLA typing by setting --enable-hla flag to true
    type: boolean?
    inputBinding:
      prefix: --enable-hla
      valueFrom: "$(self.toString())"
  hla_bed_file:
    label: hla bed file
    doc: |
      Use the HLA region BED input file to specify the region to extract HLA reads from.
      DRAGEN HLA Caller parses the input file for regions within the BED file, and then
      extracts reads accordingly to align with the HLA allele reference.
    type: File?
    inputBinding:
      prefix: --hla-bed-file
  hla_reference_file:
    label: hla reference file
    doc: |
      Use the HLA allele reference file to specify the reference alleles to align against.
      The input HLA reference file must be in FASTA format and contain the protein sequence separated into exons.
      If --hla-reference-file is not specified, DRAGEN uses hla_classI_ref_freq.fasta from /opt/edico/config/.
      The reference HLA sequences are obtained from the IMGT/HLA database.
    type: File?
    inputBinding:
      prefix: --hla-reference-file
  hla_allele_frequency_file:
    label: hla allele frequency file
    doc: |
      Use the population-level HLA allele frequency file to break ties if one or more HLA allele produces the same or similar results.
      The input HLA allele frequency file must be in CSV format and contain the HLA alleles and the occurrence frequency in population.
      If --hla-allele-frequency-file is not specified, DRAGEN automatically uses hla_classI_allele_frequency.csv from /opt/edico/config/.
      Population-level allele frequencies can be obtained from the Allele Frequency Net database.
    type: File?
    inputBinding:
      prefix: --hla-allele-frequency-file
  hla_tiebreaker_threshold:
    label: hla tiebreaker threshold
    doc: |
      If more than one allele has a similar number of reads aligned and there is not a clear indicator for the best allele,
      the alleles are considered as ties. The HLA Caller places the tied alleles into a candidate set for tie breaking based
      on the population allele frequency. If an allele has more than the specified fraction of reads aligned (normalized to
      the top hit), then the allele is included into the candidate set for tie breaking. The default value is 0.97.
    type: float?
    inputBinding:
      prefix: --hla-tiebreaker-threshold
  hla_zygosity_threshold:
    label: hla zygosity threshold
    doc: |
      If the minor allele at a given locus has fewer reads mapped than a fraction of the read count of the major allele,
      then the HLA Caller infers homozygosity for the given HLA-I gene. You can use this option to specify the fraction value.
      The default value is 0.15.
    type: float?
    inputBinding:
      prefix: --hla zygosity threshold
  hla_min_reads:
    label: hla min reads
    doc: |
      Set the minimum number of reads to align to HLA alleles to ensure sufficient coverage and perform HLA typing.
      The default value is 1000 and suggested for WES samples. If using samples with less coverage, you can use a
      lower threshold value.
    type: int?
    inputBinding:
      prefix: --hla-min-reads
  # RNA
  enable_rna:
    label: enable rna
    doc: |
      Set this option for running RNA samples through T/N workflow
    type: boolean?
    inputBinding:
      prefix: "--enable-rna"
      valueFrom: "$(self.toString())"
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
      prefix: "--lic-instance-id-location"


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
      glob: "$(inputs.output_directory)/$(get_normal_output_prefix()).bam"
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
