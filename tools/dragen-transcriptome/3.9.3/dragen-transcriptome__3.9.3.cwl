cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
    s: https://schema.org/
    ilmn-tes: http://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: dragen-transcriptome--3.9.3
label: dragen-transcriptome v(3.9.3)
doc: |
    Documentation for dragen-transcriptome v3.9.3

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/ICA_CLI/Content/SW/ICA/IAPWES_RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: fpga
            size: medium
    DockerRequirement:
        dockerPull: "699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:3.9.3"

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - var get_script_path = function(){
          /*
          Abstract script path, can then be referenced in baseCommand attribute too
          Makes things more readable.  FIXME
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
      - var get_fastq_list_path = function() {
          /*
          The fastq list path must be placed in working directory
          */
          return "fastq_list.csv"
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
      - var get_script_contents = function(){
          /*
          Split dirent out from the listing JS.
          Makes things a little more readable
          Split arguments over multiple lines for greater readability
          Use full long arguments where possible
          */
          return "#!/usr/bin/env bash\n" +
          "\n" +
          "# Fail on non-zero exit of subshell\n" +
          "set -euo pipefail\n" +
          "\n" +
          "# Initialise dragen\n" +
          "/opt/edico/bin/dragen \\\n" +
          "  --partial-reconfig DNA-MAPPER \\\n" +
          "  --ignore-version-check true\n" +
          "\n" +
          "# Create directories\n" +
          "mkdir --parents \\\n" +
          "  \"" + get_ref_mount() + "\" \\\n" +
          "  \"" + get_intermediate_results_dir() + "\" \\\n" +
          "  \"" + inputs.output_directory + "\"\n" +
          "\n" +
          "# untar ref data into scratch space\n" +
          "tar \\\n" +
          "  --directory \"" + get_ref_mount() + "\" \\\n" +
          "  --extract \\\n" +
          "  --file \"" + inputs.reference_tar.path + "\"\n" +
          "\n" +
          "# Run dragen command and import options from cli\n" +
          "eval \"" + get_dragen_bin_path() + "\" '\"\$@\"' \n";
        }
  InitialWorkDirRequirement:
    listing: |
      ${
          /*
          Initialise the array of files to mount
          Add in the script path and the script contents
          We also add in the fastq-list.csv into the working directory,
          since Read1File and Read2File are relative its position
          */

          var e = [{
                      "entryname": get_script_path(),
                      "entry": get_script_contents()
                    },
                   {
                      "entryname": get_fastq_list_path(),
                      "entry": inputs.fastq_list
                   }];

          /*
          Check if input_mounts record is defined
          The fastq-list.csv could be using presigned urls instead
          */
          if (inputs.fastq_list_mount_paths === null){
              return e;
          }

          /*
          Iterate through each file to mount
          Mount that object at the same reference to the mount point index.
          */
          inputs.fastq_list_mount_paths.forEach(function(mount_path_record){
            e.push({
                'entry': mount_path_record.file_obj,
                'entryname': mount_path_record.mount_path
            });
          });

          /*
          Return file paths
          */
          return e;
      }


baseCommand: [ "bash" ]

arguments:
  # Script path
  - valueFrom: "$(get_script_path())"
    position: -1
  # Parameters that are always true
  - prefix: "--intermediate-results-dir"
    valueFrom: "$(get_intermediate_results_dir())"
  - prefix: "--enable-rna"
    valueFrom: "true"

inputs:
  # File inputs
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process.
      Read1File and Read2File may be presigned urls or use this in conjunction with
      the fastq_list_mount_paths inputs.
    type: File
    inputBinding:
      prefix: "--fastq-list"
  fastq_list_mount_paths:
    label: fastq list mount paths
    doc: |
      Path to fastq list mount path.
    type: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml#predefined-mount-path[]?
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball.
    type: File
    inputBinding:
      prefix: "--ref-dir"
      valueFrom: "$(get_ref_path(self))"
  # Output naming options
  output_file_prefix:
    label: output file prefix
    doc: |
      The prefix given to all output files.
    type: string
    inputBinding:
      prefix: "--output-file-prefix"
  output_directory:
    label: output directory
    doc: |
      The directory where all output files are placed.
    type: string
    inputBinding:
      prefix: "--output-directory"
  # Alignment options
  enable_map_align_output:
    label: enable map align output
    doc: |
      Do you wish to have the output bam files present
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align-output"
      valueFrom: "$(self.toString())"
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Mark identical alignments as duplicates
    type: boolean?
    inputBinding:
      prefix: "--enable-duplicate-marking"
      valueFrom: "$(self.toString())"
  # Transcript annotation file
  annotation_file:
    label: annotation file
    doc: |
      Path to annotation transcript file.
    type: File
    inputBinding:
      prefix: "--annotation-file"
  # Optional operation modes
  enable_rna_quantification:
    label: enable rna quantification
    type: boolean?
    default: true
    doc: |
      Enable the quantification module. The default value is true.
    inputBinding:
      prefix: "--enable-rna-quantification"
      valueFrom: "$(self.toString())"
  enable_rna_gene_fusion:
    label: enable rna gene fusion
    type: boolean?
    default: true
    doc: |
      Enable the DRAGEN Gene Fusion module. The default value is true.
    inputBinding:
      prefix: "--enable-rna-gene-fusion"
      valueFrom: "$(self.toString())"
  enable_rrna_filter:
    label: enable rrna filtering
    type: boolean?
    default: true
    doc: |
      Use the DRAGEN RNA pipeline to filter rRNA reads during alignment. The default value is false.
    inputBinding:
      prefix: "--rrna-filter-enable"
      valueFrom: "$(self.toString())"
  rrna_filter_contig:
    label: name of the rRNA sequences to use for filtering
    type: string
    default: chrUn_GL000220v1
    doc: |
      Specify the name of the rRNA sequences to use for filtering.
    inputBinding:
      prefix: "--rrna-filter-contig"

outputs:
  # Will also include mounted-files.txt
  dragen_transcriptome_directory:
    label: dragen transcriptome output directory
    doc: |
      The output directory containing all wts analysis output files
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory)"
  # Optional files to be used in downstream workflows.
  # Whilst these files reside inside the germline directory, specifying them here as outputs
  # provides easier access and reference
  # Only exists if --enable-map-align-output is set to true#
  dragen_bam_out:
    label: dragen bam out
    doc: |
      The output bam file, exists only if --enable-map-align-output is set to true
    type: File?
    outputBinding:
      glob: "$(inputs.output_directory)/$(inputs.output_file_prefix).bam"
    secondaryFiles:
      - ".bai"

successCodes:
  - 0
