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
id: bcl-convert--4.0.3
label: bcl-convert v(4.0.3)
doc: |
    Documentation for bcl-convert v4.0.3

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: $(get_resource_hints_for_bclconvert_run(inputs, "ilmn-tes-resources-type"))
    ilmn-tes:resources/type: $(get_resource_hints_for_bclconvert_run(inputs, "ilmn-tes-resources-tier"))
    ilmn-tes:resources/size: $(get_resource_hints_for_bclconvert_run(inputs, "ilmn-tes-resources-size"))
    coresMin: $(get_resource_hints_for_bclconvert_run(inputs, "coresMin"))
    ramMin: $(get_resource_hints_for_bclconvert_run(inputs, "ramMin"))
  DockerRequirement:
    dockerPull: 'ghcr.io/umccr/bcl-convert:4.0.3'

requirements:
  NetworkAccess:
    networkAccess: true
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/get-fastq-list-rows-from-fastq-list-csv/1.0.0/get-fastq-list-rows-from-fastq-list-csv__1.0.0.cwljs
      - $include: ../../../typescript-expressions/samplesheet-builder/2.0.0--4.0.3/samplesheet-builder__2.0.0--4.0.3.cwljs
      - $include: ../../../typescript-expressions/bclconvert-run-configuration-expressions/2.0.0--4.0.3/bclconvert-run-configuration-expressions__2.0.0--4.0.3.cwljs
      - $include: ../../../typescript-expressions/utils/1.0.0/utils__1.0.0.cwljs
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/samplesheet/2.0.0--4.0.3/samplesheet__2.0.0--4.0.3.yaml
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
  InitialWorkDirRequirement:
    listing:
      # Cater for dragen
      - entryname: "run_bclconvert.sh"
        entry: |
          #!/usr/bin/env bash
          
          # Set to fail
          set -euo pipefail
          
          # Check if dragen is available on the machine
          if type /opt/edico/bin/dragen 1>/dev/null 2>&1; then
            # First reset dragen box
            /opt/edico/bin/dragen \\
              --partial-reconfig HMM \\
              --ignore-version-check true
            
            # Only set --fastq-compression-format value if 
            # --bcl-validate-sample-sheet-only is set to false
            if [[ "$(is_not_null(inputs.fastq_compression_format))" == "true" && "$(is_not_null(inputs.bcl_validate_sample_sheet_only))" == "false" ]]; then
              fastq_compression_format_parameter="--fastq-compression-format=\"$(inputs.fastq_compression_format)\""
            else
              fastq_compression_format_parameter=""
            fi
          
            # Only set --ora-reference value if
            # --bcl-validate-sample-sheet-only is set to false
            if [[ "$(is_not_null(inputs.ora_reference))" == "true" && "$(is_not_null(inputs.bcl_validate_sample_sheet_only))" == "false" ]]; then
              ora_reference_parameter="--ora-reference=\"$(get_attribute_from_optional_input(inputs.ora_reference, "path"))\""
            else
              ora_reference_parameter=""
            fi
            
            # Only set --lic-instance-id location 
            # Set to string /opt/instance-identity if instance id location is a string
            # Otherwise set to path attribute of inputs.lic_instance_id
            if [[ "$(is_not_null(inputs.lic_instance_id_location))" == "true" ]]; then
              lic_instance_id_location_parameter="--lic-instance-id=\"$(get_optional_attribute_from_multi_type_input_object(inputs.lic_instance_id_location, "path"))\""
            else
              lic_instance_id_location_parameter=""
            fi
            
            # Run bclconvert through dragen
            eval /opt/edico/bin/dragen \\
              -v \\
              --logging-to-output-dir="true" \\
              --bcl-conversion-only="true" \\
              \${fastq_compression_format_parameter} \\
              \${ora_reference_parameter} \\
              \${lic_instance_id_location_parameter} \\
              '"\${@}"'
          else
            # Run through standard bclconvert executable
            eval bcl-convert '"\${@}"'
          fi
          
          # Delete undetermined indices if set
          # TODO
      # The samplesheet.csv placed in the top directory if set
      - |
        ${
          if (inputs.samplesheet === null){
            return {};
          } else if (inputs.samplesheet.class === "File"){
            return {
              "entry": inputs.samplesheet,
              "entryname": "SampleSheet.csv"
            };
          } else {
            return {
              "entry": create_samplesheet(inputs.samplesheet)
            };
          }
        }

baseCommand: [ "bash", "run_bclconvert.sh" ]

inputs:
  # Required inputs
  bcl_input_directory:
    label: bcl input directory
    doc: |
      A main command-line option that indicates the path to the run
      folder directory.
      This parameter must be set, but is optional in the case that --bcl-validate-sample-sheet-only
      is set and --run-info and --sample-sheet are provided
    type: Directory?
    inputBinding:
      prefix: "--bcl-input-directory="
      separate: False
  output_directory:
    label: output directory
    doc: |
      A required command-line option that indicates the path to
      demultuplexed fastq output. The directory must not exist, unless -f,
      force is specified
    type: string
    inputBinding:
      prefix: "--output-directory="
      separate: False
  # Optional inputs
  samplesheet:
    label: sample sheet
    doc: |
      Use sample sheet object to specify the
      sample sheet location and name, if different from the default under /bcl_input_directory / SampleSheet.csv.
    type:
      - "null"
      - ../../../schemas/samplesheet/2.0.0--4.0.3/samplesheet__2.0.0--4.0.3.yaml#samplesheet
      - File
    inputBinding:
      prefix: "--sample-sheet="
      separate: False
      valueFrom: "SampleSheet.csv"
  bcl_only_lane:
    label: convert only one lane
    doc: |
      Convert only the specified lane number. The value must
      be less than or equal to the number of lanes specified in the
      RunInfo.xml. Must be a single integer value.
    type: int?
    inputBinding:
      prefix: "--bcl-only-lane="
      separate: False
  strict_mode:
    label: strict mode
    doc: |
      true — Abort the program if any filter, locs, bcl, or bci lane
      files are missing or corrupt.
      false — Continue processing if any filter, locs, bcl, or bci lane files
      are missing. Return a warning message for each missing or corrupt
      file.
    type: boolean?
    inputBinding:
      prefix: "--strict-mode="
      separate: False
      valueFrom: "$(self.toString())"
  # Tile options
  first_tile_only:
    label: first tile only
    doc: |
      true — Only process the first tile of the first swath of the
      top surface of each lane specified in the sample sheet.
      false — Process all tiles in each lane, as specified in the sample
      sheet. Default is false
    type: boolean?
    inputBinding:
      prefix: "--first-tile-only="
      separate: False
      valueFrom: "$(self.toString())"
  tiles:
    label: tiles
    doc: |
      Only converts tiles that match a set of regular expressions.
    type: string?
    inputBinding:
      prefix: "--tiles="
      separate: False
  exclude_tiles:
    label: tiles
    doc: |
      Do not convert tiles that match a set of regular expressions, even if included in --tiles.
    type: string?
    inputBinding:
      prefix: "--exclude-tiles="
      separate: False
  # Output configuration options
  bcl_sampleproject_subdirectories:
    label: bcl sample project subdirectories
    doc: |
      true — Allows creation of Sample_Project subdirectories
      as specified in the sample sheet. This option must be set to true for
      the Sample_Project column in the data section to be used.
      Default set to false.
    type: boolean?
    inputBinding:
      prefix: "--bcl-sampleproject-subdirectories="
      separate: False
      valueFrom: "$(self.toString())"
  sample_name_column_enabled:
    label: sample name column enabled
    doc: |
      Use Sample_Name Sample Sheet column for *.fastq file names in Sample_Project subdirectories 
      (requires bcl-sampleproject-subdirectories true as well).
    type: boolean?
    inputBinding:
      prefix: "--sample-name-column-enabled="
      separate: False
      valueFrom: "$(self.toString())"
  # Performance options
  fastq_gzip_compression_level:
    label: fastq gzip compression label
    doc: |
      Set fastq output compression level 0-9 (default 1)
    type: int?
    inputBinding:
      prefix: "--fastq-gzip-compression-level="
      separate: False
  shared_thread_odirect_output:
    label: shared thread odirect output
    doc: |
      Uses experimental shared-thread file output code, which
      requires O_DIRECT mode. Must be true or false.
      This file output method is optimized for sample counts
      greater than 100,000. It is not recommended for lower
      sample counts or using a distributed file system target such
      as GPFS or Lustre. Default is false
    type: boolean?
    inputBinding:
      prefix: "--shared-thread-odirect-output="
      separate: False
      valueFrom: "$(self.toString())"
  bcl_num_parallel_tiles:
    label: bcl num parallel tiles
    doc: |
      Specifies number of tiles being converted to FASTQ files in
      parallel. Must be between 1 and available hardware threads,
      inclusive.
    type: int?
    inputBinding:
      prefix: "--bcl-num-parallel-tiles="
      separate: False
  bcl_conversion_threads:
    label: bcl conversion threads
    doc: |
      Specifies number of threads used for conversion per tile.
      Must be between 1 and available hardware threads,
      inclusive.
    type: int?
    inputBinding:
      prefix: "--bcl-conversion-threads="
      separate: False
  bcl_num_compression_threads:
    label: bcl num compression threads
    doc: |
      Specifies number of CPU threads used for compression of
      output FASTQ files. Must be between 1 and available
      hardware threads, inclusive.
    type: int?
    inputBinding:
      prefix: "--bcl-num-compression-threads="
      separate: False
  bcl_num_decompression_threads:
    label: bcl num decompression threads
    doc: |
      Specifies number of CPU threads used for decompression
      of input base call files. Must be between 1 and available
      hardware threads, inclusive.
    type: int?
    inputBinding:
      prefix: "--bcl-num-decompression-threads="
      separate: False
  # Miscellaneous options
  bcl_only_matched_reads:
    label: bcl only matched reads
    doc: |
      Disable outputting unmapped reads to FASTQ files marked as Undetermined.
    type: boolean?
    inputBinding:
      prefix: "--bcl-only-matched-reads="
      separate: False
      valueFrom: "$(self.toString())"
  run_info:
    label: run info
    doc: |
      Overrides the path to the RunInfo.xml file.
    type: File?
    inputBinding:
      prefix: "--run-info="
      separate: False
  no_lane_splitting:
    label: no lane splitting
    doc: |
      Consolidates FASTQ files across lanes.
      Each sample is provided into the same file on a per-read basis.
       *  Must be true or false.
       *  Only allowed when Lane column is excluded from the sample sheet.
    type: boolean?
    inputBinding:
      prefix: "--no-lane-splitting="
      separate: False
      valueFrom: "$(self.toString())"
  num_unknown_barcodes_reported:
    label: num unknown barcodes reported
    doc: |
      Num of Top Unknown Barcodes to output (1000 by default)
    type: int?
    inputBinding:
      prefix: "--num-unknown-barcodes-reported="
      separate: False
  bcl_validate_sample_sheet_only:
    label: bcl validate sample sheet only
    doc: |
      Only validate RunInfo.xml & SampleSheet files (produce no FASTQ files)
    type: boolean?
    inputBinding:
      prefix: "--bcl-validate-sample-sheet-only="
      separate: False
      valueFrom: "$(self.toString())"
  output_legacy_stats:
    label: output legacy stats
    doc: |
      Also output stats in legacy (bcl2fastq) format (false by default)
    type: boolean?
    inputBinding:
      prefix: "--output-legacy-stats="
      separate: False
  # Dragen ora specific parameters
  ora_reference:
    label: ora reference
    doc: |
      Required to output compressed FASTQ.ORA files. 
      Specify the path to the directory that contains the compression reference and index file.
    type: Directory?
    # FIXME: Inputbinding now handled in bash script due to incompatibility with --bcl-validate-sample-sheet-only parameter
    # inputBinding:
    #   prefix: --ora-reference
  fastq_compression_format:
    label: fastq compression format
    doc: |
      Required for DRAGEN ORA compression to specify the type of compression: 
      use dragen for regular DRAGEN ORA compression, or dragen-interleaved for DRAGEN ORA paired compression.
    type: string?
    # FIXME: Inputbinding now handled in bash script due to incompatibility with --bcl-validate-sample-sheet-only parameter
    # inputBinding:
    #   prefix: --fastq-compression-format
  # Cannot specify as input binding since we may be running through the standard bclconvert
  lic_instance_id_location:
    label: lic instance id location
    doc: |
      The license instance id location
    type:
      - string
      - File
    default: "/opt/instance-identity"

# Set outputs
outputs:
  bcl_convert_directory_output:
    label: bcl convert directory output
    doc: |
      Output directory containing the fastq files, reports and stats
    type: Directory
    outputBinding:
      glob: $(inputs.output_directory)
  fastq_list_rows:
    label: fastq list rows
    doc: |
      This schema contains the following inputs:
      * rgid: The id of the sample
      * rgsm: The name of the sample
      * rglb: The library of the sample
      * lane: The lane of the sample
      * read_1: The read 1 File of the sample
      * read_2: The read 2 File of the sample (optional)
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
    outputBinding:
      glob: "$(inputs.output_directory)/Reports/fastq_list.csv"
      loadContents: true
      outputEval: |
        ${
          if (self.length === 0){
            return null;  
          }
          return get_fastq_list_rows_from_file(self[0]);
        }
  samplesheet_out:
    label: samplesheet out
    doc: |
      The samplesheet used by the bclconvert workflow
    type: File
    outputBinding:
      glob: "$(inputs.output_directory)/Reports/SampleSheet.csv"
  run_info_out:
    label: run info out
    doc: |
      The run info file used by the bclconvert workflow
    type: File
    outputBinding:
      glob: "$(inputs.output_directory)/Reports/RunInfo.xml"

successCodes:
  - 0