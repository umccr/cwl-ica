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
id: dragen-instrument-run-fastq-to-ora--4.2.4
label: dragen-instrument-run-fastq-to-ora v(4.2.4)
doc: |
    This tool can be used for archiving purposes by first compressing fastqs prior to transfer to a long-term storage location.

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

steps:
  # Run Dragen Instrument Run Fastq to ORA
  run_dragen_instrument_run_fastq_to_ora_step:
    label: Run Dragen Instrument Run Fastq to ORA
    doc: |
      Run the dragen instrument run fastq to ora tool
    in:
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
      sample_id_list:
        source: sample_id_list
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

