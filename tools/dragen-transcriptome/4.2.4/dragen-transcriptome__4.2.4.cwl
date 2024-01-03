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

# ID/Docs
id: dragen-transcriptome--4.2.4
label: dragen-transcriptome v(4.2.4)
doc: |
    Documentation for dragen-transcriptome v4.2.4

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: fpga
    ilmn-tes:resources/size: medium
    coresMin: 16
    ramMin: 240000
    tmpdirMin: |
      ${
        /* 1 Tb * /
        return 2 ** 20; 
      }
  DockerRequirement:
    dockerPull: "699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:4.2.4"

requirements:
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
            return generate_transcriptome_mount_points(inputs);
        }

baseCommand: [ "bash" ]

arguments:
  # Script path
  - valueFrom: "$(get_script_path())"
    position: -1
  # Set intermediate directory
  - prefix: "--intermediate-results-dir="
    separate: False
    valueFrom: "$(get_intermediate_results_dir())"
  # Parameters that are always true
  - prefix: "--enable-rna="
    separate: False
    valueFrom: "true"

inputs:
  # File inputs
  # Option 1:
  fastq_list:
    label: fastq list
    doc: |
      CSV file that contains a list of FASTQ files
      to process. read_1 and read_2 components in the CSV file must be presigned urls.
    type: File?
    inputBinding:
      loadContents: true
      prefix: "--fastq-list="
      separate: False
      valueFrom: "$(get_fastq_list_csv_path())"
  # Option 2:
  fastq_list_rows:
    label: fastq list rows
    doc: |
      Alternative to providing a file, one can instead provide a list of 'fastq-list-row' objects
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]?
    inputBinding:
      prefix: "--fastq-list="
      separate: False
      valueFrom: "$(get_fastq_list_csv_path())"
  # Option 3
  bam_input:
    label: bam input
    doc: |
      Input a BAM file for the Dragen RNA options
    type: File?
    inputBinding:
      prefix: "--bam-input="
      separate: False
    secondaryFiles:
      - pattern: ".bai"
        required: true
  reference_tar:
    label: reference tar
    doc: |
      Path to ref data tarball.
    type: File
    inputBinding:
      prefix: "--ref-dir="
      separate: False
      valueFrom: "$(get_ref_path(self))"
  # Output naming options
  output_file_prefix:
    label: output file prefix
    doc: |
      The prefix given to all output files.
    type: string
    inputBinding:
      prefix: "--output-file-prefix="
      separate: False
  output_directory:
    label: output directory
    doc: |
      The directory where all output files are placed.
    type: string
    inputBinding:
      prefix: "--output-directory="
      separate: False
  # Alignment options
  enable_map_align:
    label: enable map align
    doc: |
      Enabled by default.
      Set this value to false if using bam_input
    type: boolean?
    inputBinding:
      prefix: "--enable-map-align="
      separate: False
      valueFrom: "$(self.toString())"
  enable_map_align_output:
    label: enable map align output
    doc: |
      Do you wish to have the output bam files present
    type: boolean
    inputBinding:
      prefix: "--enable-map-align-output="
      separate: False
      valueFrom: "$(self.toString())"
  enable_sort:
    label: enable sort
    doc: |
      True by default, only set this to false if using --bam-input parameters
    type: boolean?
    inputBinding:
      prefix: "--enable-sort="
      separate: False
      valueFrom: "$(self.toString())"
  enable_duplicate_marking:
    label: enable duplicate marking
    doc: |
      Mark identical alignments as duplicates
    type: boolean
    inputBinding:
      prefix: "--enable-duplicate-marking="
      separate: False
      valueFrom: "$(self.toString())"
  # Transcript annotation file
  annotation_file:
    label: annotation file
    doc: |
      Path to annotation transcript file.
    type: File
    inputBinding:
      prefix: "--annotation-file="
      separate: False
  # Optional operation modes
  enable_rna_quantification:
    label: enable rna quantification
    type: boolean?
    default: true
    doc: |
      Enable the quantification module. The default value is true.
    inputBinding:
      prefix: "--enable-rna-quantification="
      separate: False
      valueFrom: "$(self.toString())"
  enable_rna_gene_fusion:
    label: enable rna gene fusion
    type: boolean?
    default: true
    doc: |
      Enable the DRAGEN Gene Fusion module. The default value is true.
    inputBinding:
      prefix: "--enable-rna-gene-fusion="
      separate: False
      valueFrom: "$(self.toString())"
  enable_rrna_filter:
    label: enable rrna filtering
    type: boolean?
    default: true
    doc: |
      Use the DRAGEN RNA pipeline to filter rRNA reads during alignment. The default value is false.
    inputBinding:
      prefix: "--rrna-filter-enable="
      separate: False
      valueFrom: "$(self.toString())"
  rrna_filter_contig:
    label: name of the rRNA sequences to use for filtering
    type: string?
    #default: chrUn_GL000220v1
    doc: |
      Specify the name of the rRNA sequences to use for filtering.
    inputBinding:
      prefix: "--rrna-filter-contig="
      separate: False
  read_trimmers:
    label: read trimming
    type: string?
    doc: |
      To enable trimming filters in hard-trimming mode, set to a comma-separated list of the trimmer tools 
      you would like to use. To disable trimming, set to none. During mapping, artifacts are removed from all reads.
      Read trimming is disabled by default.
    inputBinding:
      prefix: "--read-trimmers="
      separate: False
  soft_read_trimmers:
    label: soft read trimming
    type: string?
    doc: |
      To enable trimming filters in soft-trimming mode, set to a comma-separated list of the trimmer tools 
      you would like to use. To disable soft trimming, set to none. During mapping, reads are aligned as if trimmed,
      and bases are not removed from the reads. Soft-trimming is enabled for the polyg filter by default.
    inputBinding:
      prefix: "--soft-read-trimmers="
      separate: False
  trim_adapter_read1:
    label: trim adapter read1
    type: File?
    doc: |
      Specify the FASTA file that contains adapter sequences to trim from the 3' end of Read 1.
    inputBinding:
      prefix:  "--trim-adapter-read1="
      separate: False
  trim_adapter_read2:
    label: trim adapter read2
    type: File?
    doc: |
      Specify the FASTA file that contains adapter sequences to trim from the 3' end of Read 2.
    inputBinding:
      prefix:  "--trim_adapter_read2="
      separate: False
  trim_adapter_r1_5prime:
    label: trim adapter r1 5prime
    type: File?
    doc: |
      Specify the FASTA file that contains adapter sequences to trim from the 5' end of Read 1. 
      NB: the sequences should be in reverse order (with respect to their appearance in the FASTQ) but not complemented.
    inputBinding:
      prefix:  "--trim-adapter-r1-5prime="
      separate: False
  trim_adapter_r2_5prime:
    label: trim adapter r2 5prime
    type: File?
    doc: |
      Specify the FASTA file that contains adapter sequences to trim from the 5' end of Read 2.
      NB: the sequences should be in reverse order (with respect to their appearance in the FASTQ) but not complemented.
    inputBinding:
      prefix:  "--trim-adapter-r2-5prime="
      separate: False
  trim_adapter_stringency:
    label: trim adapter stringency
    type: int?
    doc: |
      Specify the minimum number of adapter bases required for trimming
    inputBinding:
      prefix:  "--trim-adapter-stringency="
      separate: False
  trim_r1_5prime:
    label: trim r1 5prime
    type: int?
    doc: |
      Specify the minimum number of bases to trim from the 5' end of Read 1 (default: 0).
    inputBinding:
      prefix: "--trim-min-r1-5prime="
      separate: False
  trim_r1_3prime:
    label: trim r1 3prime
    type: int?
    doc: |
      Specify the minimum number of bases to trim from the 3' end of Read 1 (default: 0).
    inputBinding:
      prefix: "--trim-min-r1-3prime="
      separate: False
  trim_r2_5prime:
    label: trim r2 5prime
    type: int?
    doc: |
      Specify the minimum number of bases to trim from the 5' end of Read 2 (default: 0).
    inputBinding:
      prefix: "--trim-min-r2-5prime="
      separate: False
  trim_r2_3prime:
    label: trim r2 3prime
    type: int?
    doc: |
      Specify the minimum number of bases to trim from the 3' end of Read 2 (default: 0).
    inputBinding:
      prefix: "--trim-min-r2-3prime="
      separate: False
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