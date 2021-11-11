cwlVersion: v1.1
class: Workflow

# Extensions
$namespaces:
    s: https://schema.org/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: umccrise-with-dragen-germline-pipeline--2.0.0--3.9.3
label: umccrise-with-dragen-germline-pipeline v(2.0.0--3.9.3)
doc: |
    Run UMCCRise on a dragen-somatic output, but run germline on the normal fastqs first.
    This means the inputs of this pipeline are:
    1. Fastq list rows of the germline samples
    2. An output directory from the dragen-somatic pipeline

    3. Any additional umccrise parameters
    4. Any additional germline parameters

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}
    SubworkflowFeatureRequirement: {}
    SchemaDefRequirement:
      types:
        - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
        - $import: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml

inputs:
  # Required inputs
  # Required germline inputs
  fastq_list_rows_germline:
    label: fastq list rows germline
    doc: |
      The row of fastq lists.
      Each row has the following attributes:
        * RGID
        * RGLB
        * RGSM
        * Lane
        * Read1File
        * Read2File (optional)
    type: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row[]
  reference_tar_germline:
    label: reference tar germline
    doc: |
      Path to ref data tarball
    type: File
  output_directory_germline:
    label: output directory germline
    doc: |
      The directory where all output files are placed
    type: string
  output_file_prefix_germline:
    label: output file prefix germline
    doc: |
      The prefix given to all output files
    type: string
  # Required umccrise inputs
  dragen_somatic_directory:
    label: dragen somatic directory
    doc: |
      The output from the dragen somatic workflow
    type: Directory
  reference_tar_umccrise:
    label: reference tar umccrise
    doc: |
      The reference tar ball for umccrise
    type: File
  subject_identifier_umccrise:
    label: subject identifier umccrise
    doc: |
      The subject identifier for umccrise to use on output files
    type: string
  output_directory_umccrise:
    label: output directory umccrise
    doc: |
      The name of the output directory used for umccrise step
    type: string
  # Optional germline inputs
  # TODO
  # Optional umccrise inputs
  # TODO

steps:
  # Step 1: Run the germline pipeline
  run_dragen_germline_pipeline_step:
    label: run dragen germline step
    doc: |
      Run the dragen germline workflow against the normal fastq.
    in:
      # Required inputs
      fastq_list_rows:
        source: fastq_list_rows_germline
      reference_tar:
        source: reference_tar_germline
      output_file_prefix:
        source: output_file_prefix_germline
      output_directory:
        source: output_directory_germline
      # Hardcoded values
      enable_map_align_output:
        # Must be set to true
        valueFrom: |
          ${
            return true;
          }
      # Outputs
    out:
      - id: dragen_germline_output_directory
    run:
      ../../../workflows/dragen-germline-pipeline/3.9.3/dragen-germline-pipeline__3.9.3.cwl
  # Step 2: Run the umccrise tool
  run_umccrise_pipeline_step:
    label: run umccrise pipeline step
    doc: |
      Run the umccrise pipeline using the input somatic directory and output from the dragen germline step
    in:
      # Required inputs
      dragen_somatic_directory:
        source: dragen_somatic_directory
      dragen_germline_directory:
        source: run_dragen_germline_pipeline_step/dragen_germline_output_directory
      reference_tar:
        source: reference_tar_umccrise
      subject_identifier:
        source: subject_identifier_umccrise
      output_directory_name:
        source: output_directory_umccrise
    out:
      - id: output_directory
    run:
      ../../../tools/umccrise/2.0.0--0/umccrise__2.0.0--0.cwl

outputs:
  umccrise_output_directory:
    label: umccrise output directory
    doc: |
      The output directory containing all umccrise output files
    type: Directory
    outputSource: run_umccrise_pipeline_step/output_directory