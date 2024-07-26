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
id: dragen-germline--3.7.5
label: dragen-germline v(3.7.5)
doc: |
    Documentation for dragen-germline v3.7.5

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
        dockerPull: "699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:3.7.5"

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
  - prefix: "--enable-variant-caller"
    valueFrom: "true"
  - prefix: "--intermediate-results-dir"
    valueFrom: "$(get_intermediate_results_dir())"


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
      Path to fastq list mount path
    type: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml#predefined-mount-path[]?
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball
    type: File
    inputBinding:
      prefix: "--ref-dir"
      valueFrom: "$(get_ref_path(self))"
  # Output naming options
  output_file_prefix:
    label: output file prefix
    doc: |
      The prefix given to all output files
    type: string
    inputBinding:
      prefix: "--output-file-prefix"
  output_directory:
    label: output directory
    doc: |
      The directory where all output files are placed
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
  dedup_min_qual:
    label: deduplicate minimum quality
    doc: |
      Specifies the Phred quality score below which a base should be excluded from the quality score
      calculation used for choosing among duplicate reads.
    type: int?
    inputBinding:
      prefix: "--dedup-min-qual"
      valueFrom: "$(self.toString())"
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
      The -vc-enable-phasing option enables variants to be phased when possible. The default value is true.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-phasing"
      valueFrom: "$(self.toString())"
  vc_enable_vcf_output:
    label: vc enable vcf output
    doc: |
      The -vc-enable-vcf-output option enables VCF file output during a gVCF run. The default value is false.
    type: boolean?
    inputBinding:
      prefix: "--vc-enable-vcf-output"
      valueFrom: "$(self.toString())"
  # Downsampling options
  vc_max_reads_per_active_region:
    label: vc max reads per active region
    doc: |
      specifies the maximum number of reads covering a given active region.
      Default is 10000 for the germline workflow
    type: int?
    inputBinding:
      prefix: "--vc-max-reads-per-active-region"
  vc_max_reads_per_raw_region:
    label: vc max reads per raw region
    doc: |
      specifies the maximum number of reads covering a given raw region.
      Default is 30000 for the germline workflow
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
    type: File?
    inputBinding:
      prefix: "--vc-enable-baf"
  # Germline variant small hard filtering options
  vc_hard_filter:
    label: vc hard fitler
    doc: |
      DRAGEN provides post-VCF variant filtering based on annotations present in the VCF records.
      However, due to the nature of DRAGEN's algorithms, which incorporate the hypothesis of correlated errors
      from within the core of variant caller, the pipeline has improved capabilities in distinguishing
      the true variants from noise, and therefore the dependency on post-VCF filtering is substantially reduced.
      For this reason, the default post-VCF filtering in DRAGEN is very simple
    type: string?
    inputBinding:
      prefix: "--vc-hard-filter"
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
  # Force genotyping
  vc_forcegt_vcf:
    label: vc forcegt vcf
    doc: |
      AGENsupports force genotyping (ForceGT) for Germline SNV variant calling.
      To use ForceGT, use the --vc-forcegt-vcf option with a list of small variants to force genotype.
      The input list of small variants can be a .vcf or .vcf.gz file.

      The current limitations of ForceGT are as follows:
      *	ForceGT is supported for Germline SNV variant calling in the V3 mode.
      The V1, V2, and V2+ modes are not supported.
      *	ForceGT is not supported for Somatic SNV variant calling.
      *	ForceGT variants do not propagate through Joint Genotyping.
    type: File?
    secondaryFiles:
      - pattern: ".tbi"
        required: true
    inputBinding:
      prefix: "--vc-forcegt-vcf"
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
      prefix: "--lic-instance-id-location"


outputs:
  # Will also include mounted-files.txt
  dragen_germline_output_directory:
    label: dragen germline output directory
    doc: |
      The output directory containing all germline output files
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
  # Should always be available as an output
  dragen_vcf_out:
    label: dragen vcf out
    doc: |
      The output germline vcf file
    type: File?
    outputBinding:
      glob: "$(inputs.output_directory)/$(inputs.output_file_prefix).vcf.gz"
    secondaryFiles:
      - ".tbi"


successCodes:
  - 0
