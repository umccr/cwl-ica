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

s:maintainer:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: dragen-germline--3.9.3
label: dragen-germline v(3.9.3)
doc: |
    Documentation for dragen-germline v3.9.3

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: fpga
            size: medium
        coresMin: 16
        ramMin: 240000
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
      - var get_dragen_eval_line = function(){
          /*
          ICA is inconsistent with cwl when it comes to handling @
          */
          return "eval \"" + get_dragen_bin_path() + "\" '\"\$@\"' \n";
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
      - |
        ${
          /*
          Add in the fastq list csv we created
          */        
          if (inputs.fastq_list_rows !== null){
            return {
                      "entryname": get_fastq_list_csv_path(),
                      "entry": get_fastq_list_csv_contents_from_fastq_list_rows_object(inputs.fastq_list_rows)
                   };
          } else if (inputs.fastq_list !== null){
            return {
                      "entryname": get_fastq_list_csv_path(),
                      "entry": inputs.fastq_list
                    };
          } else {
            return null;
          }
        }

baseCommand: [ "bash" ]

arguments:
  # Script path
  - valueFrom: "$(get_script_path())"
    position: -1
  # Set fastq list
  - prefix: "--fastq-list"
    valueFrom: "$(get_fastq_list_csv_path())"
  # Parameters that are always true
  - prefix: "--enable-variant-caller"
    valueFrom: "true"
  - prefix: "--intermediate-results-dir"
    valueFrom: "$(get_intermediate_results_dir())"


inputs:
  # File inputs
  # Option 1:
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process.
      Read1File and Read2File may be presigned urls or use this in conjunction with
      the fastq_list_mount_paths inputs.
    type: File?
  # Option 2:
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
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
  # Optional operation modes
  # Given we're running from fastqs
  # --enable-variant-caller option must be set to true (set in arguments), --enable-map-align is then activated by default
  # --enable-map-align-output to keep bams
  # --enable-duplicate-marking to mark duplicate reads at the same time
  # --enable-sv to enable the structural variant calling step.
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
      However, due to the nature of DRAGEN’s algorithms, which incorporate the hypothesis of correlated errors
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
  # cnv pipeline - with this we must also specify one of --cnv-normal-b-allele-vcf,
  # More info at https://support-docs.illumina.com/SW/DRAGEN_v39/Content/SW/DRAGEN/CNVExamples_fDG_dtREF.htm?Highlight=cnv-normal-b-allele-vcf
  enable_cnv:
    label: enable cnv calling
    doc: |
      Enable CNV processing in the DRAGEN Host Software.
    type: boolean?
    inputBinding:
      prefix: --enable-cnv
      valueFrom: "$(self.toString())"
  cnv_enable_self_normalization:
    label: cnv enable self normalization
    doc: |
      Enable CNV self normalization.
      Self Normalization requires that the DRAGEN hash table be generated with the enable-cnv=true option.
    type: boolean?
    inputBinding:
      prefix: --cnv-enable-self-normalization
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
