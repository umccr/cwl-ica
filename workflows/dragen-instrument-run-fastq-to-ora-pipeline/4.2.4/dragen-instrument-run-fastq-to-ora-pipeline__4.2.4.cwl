cwlVersion: v1.1
class: Workflow

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
id: dragen-instrument-run-fastq-to-ora-pipeline--4.2.4
label: dragen-instrument-run-fastq-to-ora v(4.2.4) pipeline
doc: |
    This tool can be used for archiving purposes by first compressing fastqs prior to transfer to a long-term storage location.

hints:
  ResourceRequirement:
    ilmn-tes:resources/storage: Large  # One of Small, Medium, Large, XLarge, 2XLarge, 3XLarge

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

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
  ora_reference:
    label: ora reference
    doc: |
      The reference tar to use for the ORA compression
    type: File
  # Optional inputs
  sample_id_list:
    label: sample id list
    doc: |
      Optional list of samples to process.  
      Samples NOT in this list are NOT compressed AND NOT transferred to the final output directory!
    type: string[]?
  # CPU Configurations
  ora_parallel_files:
    label: ora parallel files
    doc: |
      The number of files to compress in parallel. If using an FPGA medium instance in the 
      run_dragen_instrument_run_fastq_to_ora_step this should be set to 16 / ora_threads_per_file.
    type: int?
    default: 2
  ora_threads_per_file:
    label: ora threads per file
    doc: |
      The number of threads to use per file. If using an FPGA medium instance in the 
      run_dragen_instrument_run_fastq_to_ora_step this should be set to 4 since there are only 16 cores available
    type: int?
    default: 8
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

steps:
  # Run Dragen Instrument Run Fastq to ORA
  run_dragen_instrument_run_fastq_to_ora_step:
    label: Run Dragen Instrument Run Fastq to ORA
    doc: |
      Run the dragen instrument run fastq to ora tool
    in:
      # Mandatory inputs
      instrument_run_directory:
        source: instrument_run_directory
      output_directory_name:
        source: instrument_run_directory
        valueFrom: |
          ${
            return self.basename;
          }
      ora_reference:
        source: ora_reference
      # Optional inputs
      sample_id_list:
        source: sample_id_list
      # CPU Configurations
      ora_parallel_files:
        source: ora_parallel_files
      ora_threads_per_file:
        source: ora_threads_per_file
      # Integrity options
      ora_print_file_info:
        source: ora_print_file_info
      ora_check_file_integrity:
        source: ora_check_file_integrity

    out:
      - id: output_directory
    run: ../../../tools/dragen-instrument-run-fastq-to-ora/4.2.4/dragen-instrument-run-fastq-to-ora__4.2.4.cwl

outputs:
  # Generate output directory
  output_directory:
    label: output directory
    doc: |
      The output directory of the instrument run with fastqs converted to oras
    type: Directory
    outputSource: run_dragen_instrument_run_fastq_to_ora_step/output_directory

