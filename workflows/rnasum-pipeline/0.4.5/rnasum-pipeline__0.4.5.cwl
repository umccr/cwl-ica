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
id: rnasum-pipeline--0.4.5
label: rnasum-pipeline v(0.4.5)
doc: |
    Documentation for rnasum-pipeline v0.4.5

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}

inputs:
  # Input folders
  dragen_transcriptome_directory:
    label: dragen transcriptome directory
    doc: |
      Location of the results from Dragen RNA-seq pipeline
    type: Directory?
  bcbio_transcriptome_directory:
    label: bcbio transcriptome directory
    doc: |
      Location of the results from bcbio RNA-seq pipeline
    type: Directory?
  arriba_directory:
    label: arriba directory
    doc: |
      Location of the arriba outputs directory
    type: Directory?
  umccrise_directory:
    label: umccrise directory
    doc: |
      The umccrise output directory
    type: Directory?
  ref_data_directory:
    label: reference data directory
    doc: |
      Location of the reference and annotation files
    type: Directory
  report_directory:
    label: report dir
    doc: |
      Desired location for the report
    type: string
  # Additional inputs
  sample_name:
    label: sample name
    doc: |
      Desired sample name to be presented in the report
    type: string
  transform:
    label: transform
    doc: |
      Transformation method to be used when converting read counts
    type: string?
  norm:
    label: norm
    doc: |
      Normalisation method
    type: string?
  batch_rm:
    label: batch rm
    doc: |
      Remove batch-associated effects between datasets
    type: boolean?
  filter:
    label: filter
    doc: |
      Filtering out low expressed genes
    type: boolean?
  log:
    label: log
    doc: |
      Log (base 2) transform data before normalisation
    type: boolean?
  scaling:
    label: scaling
    doc: |
      Apply "gene-wise" (default) or "group-wise" data scaling
    type: string?
  drugs:
    label: drugs
    doc: |
      Include drug matching section in the report.
    type: boolean?
  immunogram:
    label: immunogram
    doc: |
      Include drug matching section in the report.
    type: boolean?
  pcgr_tier:
    label: pcgr tier
    doc: |
      Tier threshold for reporting variants reported in PCGR.
    type: int?
  pcgr_splice_vars:
    label: pcgr splice vars
    doc: |
      Include non-coding splice region variants reported in PCGR.
    type: boolean?
  cn_loss:
    label: cn loss
    doc: |
      CN threshold value to classify genes within lost regions.
    type: int?
  cn_gain:
    label: cn gain
    doc: |
      CN threshold value to classify genes within gained regions.
    type: int?
  clinical_info:
    label: clinical info
    doc: |
      xslx file with clinical information.
    type: File?
  clinical_id:
    label: clinical id
    doc: |
      ID required to match sample with the subject clinical information (specified in flag --clinical_info).
    type: string?
  subject_id:
    label: subject id
    doc: |
      Subject ID. If umccrise output is specified (flag --umccrise) then Subject ID 
      is extracted from there and used to overwrite this argument.
    type: string?
  sample_source:
    label: sample source
    doc: |
      Source of investigated sample (e.g. fresh frozen tissue, organoid).
      This information is for annotation purposes only
    type: string?
  dataset_name_incl:
    label: dataset name incl
    doc: |
      Include dataset in the report and sample name.
    type: boolean?
  project:
    label: project
    doc: |
      Project name. This information is for annotation purposes only
    type: string?
  top_genes:
    label: top genes
    doc: |
      The number of top ranked genes to be presented.
    type: int?
  hide_code_btn:
    label: hide code btn
    doc: |
      Hide the "Code" button allowing to show/hide code chunks in the final HTML report.
    type: boolean?
  grch_version:
    label: grch version
    doc: |
      Human reference genome version used for genes annotation.
    type: int?
  dataset:
    label: dataset
    doc: |
      Reference dataset selection from https://github.com/umccr/RNAsum/blob/master/TCGA_projects_summary.md
    type: string
  save_tables:
    label: save tables
    doc: |
      save tables
    type: boolean?

steps:
  run_rnasum_step:
    label: run rnasum
    doc: |
      Run RNASum CommandlineTool
    in:
      dragen_transcriptome_directory:
        source: dragen_transcriptome_directory
      bcbio_transcriptome_directory:
        source: bcbio_transcriptome_directory
      arriba_directory:
        source: arriba_directory
      umccrise_directory:
        source: umccrise_directory
      ref_data_directory:
        source: ref_data_directory
      report_directory:
        source: report_directory
      sample_name:
        source: sample_name
      transform:
        source: transform
      norm:
        source: norm
      batch_rm:
        source: batch_rm
      filter:
        source: filter
      log:
        source: log
      scaling:
        source: scaling
      drugs:
        source: drugs
      immunogram:
        source: immunogram
      pcgr_tier:
        source: pcgr_tier
      pcgr_splice_vars:
        source: pcgr_splice_vars
      cn_loss:
        source: cn_loss
      cn_gain:
        source: cn_gain
      clinical_info:
        source: clinical_info
      clinical_id:
        source: clinical_id
      subject_id:
        source: subject_id
      sample_source:
        source: sample_source
      dataset_name_incl:
        source: dataset_name_incl
      project:
        source: project
      top_genes:
        source: top_genes
      hide_code_btn:
        source: hide_code_btn
      grch_version:
        source: grch_version
      dataset:
        source: dataset
      save_tables:
        source: save_tables
    out:
      - id: rnasum_output_directory
      - id: rnasum_html
    run: ../../../tools/rnasum/0.4.5/rnasum__0.4.5.cwl

outputs:
  rnasum_output_directory:
    label: RNAsum output directory
    doc: Output directory containing all outputs of the RNAsum run
    type: Directory
    outputSource: run_rnasum_step/rnasum_output_directory
  rnasum_html:
    label: rnasum html
    doc: |
      The HTML report output of RNAsum
    type: File
    outputSource: run_rnasum_step/rnasum_html
