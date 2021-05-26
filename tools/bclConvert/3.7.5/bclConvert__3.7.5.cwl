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
id: bclConvert--3.7.5
label: bclConvert v(3.7.5)
doc: |
    Runs the BCL Convert application off standard architechture

hints:
  ResourceRequirement:
    ilmn-tes:resources:
      type: standardHiCpu
      size: large
    coresMin: 72
    ramMin: 64000
  DockerRequirement:
    dockerPull: 173606189969.dkr.ecr.us-east-1.amazonaws.com/dragen/bclconvert:3.7.5

requirements:
  # This overrides the hints
  DockerRequirement:
    dockerPull: 'umccr/bcl-convert:3.7.5'
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
  InitialWorkDirRequirement:
    listing:
      - entryname: "scripts/run_bclconvert.sh"
        entry: |
          #!/usr/bin/bash

          # Fail on non-zero exit code
          set -euo pipefail

          # Run bcl-convert with input parameters
          eval bcl-convert '"\${@}"'

          # Delete undetermined indices
          if [[ "$(inputs.delete_undetermined_indices)" == "true" ]]; then
            echo "Deleting undetermined indices" 1>&2
            find "$(inputs.output_directory)" -mindepth 1 -maxdepth 1 -name 'Undetermined_S0_*' -exec rm {} \\;
          fi

baseCommand: [ "bash" ]

arguments:
  - position: -1
    valueFrom: "scripts/run_bclconvert.sh"

inputs:
  # Required inputs
  bcl_input_directory:
    label: bcl input directory
    doc: |
      A main command-line option that indicates the path to the run
      folder directory
    type: Directory
    inputBinding:
      prefix: --bcl-input-directory
  output_directory:
    label: output directory
    doc: |
      A required command-line option that indicates the path to
      demultuplexed fastq output. The directory must not exist, unless -f,
      force is specified
    type: string
    inputBinding:
      prefix: --output-directory
  # Optional inputs
  force:
    label: force
    doc: |
      Allow for the directory specified by the --output-directory
      option to already exist. Default is false
    type: boolean?
    inputBinding:
      prefix: --force
  samplesheet:
    label: sample sheet
    doc: |
      Indicates the path to the sample sheet to specify the
      sample sheet location and name, if different from the default.
    type: File?
    inputBinding:
      prefix: --sample-sheet
  bcl_only_lane:
    label: convert only one lane
    doc: |
      Convert only the specified lane number. The value must
      be less than or equal to the number of lanes specified in the
      RunInfo.xml. Must be a single integer value.
    type: int?
    inputBinding:
      prefix: --bcl-only-lane
  first_tile_only:
    label: first tile only
    doc: |
      true — Only process the first tile of the first swath of the
      top surface of each lane specified in the sample sheet.
      false — Process all tiles in each lane, as specified in the sample
      sheet. Default is false
    type: boolean?
    inputBinding:
      prefix: --first-tile-only
      valueFrom: "$(self.toString())"
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
      prefix: --strict-mode
      valueFrom: "$(self.toString())"
  bcl_sampleproject_subdirectories:
    label: bcl sample project subdirectories
    doc: |
      true — Allows creation of Sample_Project subdirectories
      as specified in the sample sheet. This option must be set to true for
      the Sample_Project column in the data section to be used.
      Default set to false.
    type: boolean?
    inputBinding:
      prefix: --bcl-sampleproject-subdirectories
      valueFrom: "$(self.toString())"
  # Performance options
  bcl_num_parallel_tiles:
    label: bcl num parallel tiles
    doc: |
      Specifies number of tiles being converted to FASTQ files in
      parallel. Must be between 1 and available hardware threads,
      inclusive.
    type: int?
    inputBinding:
      prefix: "--bcl-num-parallel-tiles"
  bcl_conversion_threads:
    label: bcl conversion threads
    doc: |
      Specifies number of threads used for conversion per tile.
      Must be between 1 and available hardware threads,
      inclusive.
    type: int?
    inputBinding:
      prefix: "--bcl-conversion-threads"
  bcl_num_compression_threads:
    label: bcl num compression threads
    doc: |
      Specifies number of CPU threads used for compression of
      output FASTQ files. Must be between 1 and available
      hardware threads, inclusive.
    type: int?
    inputBinding:
      prefix: "--bcl-num-compression-threads"
  bcl_num_decompression_threads:
    label: bcl num decompression threads
    doc: |
      Specifies number of CPU threads used for decompression
      of input base call files. Must be between 1 and available
      hardware threads, inclusive.
    type: int?
    inputBinding:
      prefix: "--bcl-num-decompression-threads"
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
      prefix: "--shared-thread-odirect-output"
  # Customised options
  delete_undetermined_indices:
    label: delete undetermined indices
    doc: |
      Delete undetermined indices on completion of the run
      Default: false
    type: boolean?

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
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq_list_row[]
    outputBinding:
      glob: "$(inputs.output_directory)/Reports/fastq_list.csv"
      loadContents: true
      outputEval: |
        ${
            /*
            Load inputs initialise output variables
            */
            var output_array = [];
            var lines = self[0].contents.split("\n")

            /*
            Generate output object by iterating through fastq_list csv
            */
            for (var i=0; i < lines.length - 1; i++){
                /*
                First line is a header row skip it
                */
                if (i === 0){
                  continue;
                }

                /*
                Split row and collect corresponding file paths
                */
                var rgid = lines[i].split(",")[0];
                var rgsm = lines[i].split(",")[1];
                var rglb = lines[i].split(",")[2];
                var lane = parseInt(lines[i].split(",")[3]);
                var read_1_path = lines[i].split(",")[4];
                var read_2_path = lines[i].split(",")[5];

                /*
                Initialise the output row as a dict
                */
                var output_fastq_list_row = {
                                              "rgid": rgid,
                                              "rglb": rglb,
                                              "rgsm": rgsm,
                                              "lane": lane,
                                              "read_1": {
                                                "class": "File",
                                                "path": read_1_path
                                              },
                }


                if (read_2_path !== ""){
                  /*
                  read 2 path exists
                  */
                  output_fastq_list_row["read_2"] = {
                    "class": "File",
                    "path": read_2_path
                  }
                }

                /*
                Append object to output array
                */
                output_array.push(output_fastq_list_row);
            }
            return output_array;
        }

successCodes:
  - 0