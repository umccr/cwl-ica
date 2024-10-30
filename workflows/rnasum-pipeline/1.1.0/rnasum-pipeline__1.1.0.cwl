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
id: rnasum-pipeline--1.1.0
label: rnasum-pipeline v(1.1.0)
doc: |
    Documentation for rnasum-pipeline v1.1.0

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}

inputs:
  # Input folders
  dragen_wts_dir:
    label: dragen transcriptome directory
    doc: |
      Location of the results from Dragen RNA-seq pipeline
    type: Directory?
  dragen_mapping_metrics:
    label: dragen mapping metrics
    doc: |
      Location of the mapping metrics from Dragen RNA-seq pipeline
    type: File?
  dragen_fusions:
    label: dragen fusions
    doc: |
      Location of the fusion output from Dragen RNA-seq pipeline
    type: File?
  salmon:
    label: salmom
    doc: |
      Location of the quantification output from salmon
    type: File?
  arriba_dir:
    label: arriba directory
    doc: |
      Location of the arriba outputs directory
    type: Directory?
  arriba_pdf:
    label: arriba pdf
    doc: |
      Location of the pdf output from arriba
    type: File?
  arriba_tsv:
    label: arriba tsv
    doc: |
      Location of the tsv output from arriba
    type: File?
  umccrise:
    label: umccrise directory
    doc: |
      The umccrise output directory
    type: Directory?
  manta_tsv:
    label: manta tsv
    doc: |
      Location of the tsv output from manta
    type: File?
  report_dir:
    label: report dir
    doc: |
      Desired location for the outputs
    type: string
  # Additional inputs
  sample_name:
    label: sample name
    doc: |
      Desired sample name to be presented in the report
    type: string
  transform:
    label: transform
    default: "CPM"
    doc: |
      Transformation method to be used when converting read counts
    type: string?
  norm:
    label: norm
    default: "TMM"
    doc: |
      Normalisation method
    type: string?
  scaling:
    label: scaling
    default: "gene-wise"
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
  pcgr_tiers_tsv:
    label: pcgr tiers tsv
    doc: |
      Location of the tsv output from pcgr
    type: File?
  purple_gene_tsv:
    label: purple gene tsv
    doc: |
      Location of the tsv output from purple
    type: File?
  pcgr_tier:
    label: pcgr tier
    default: 4
    doc: |
      Tier threshold for reporting variants reported in PCGR.
    type: int?
  cn_loss:
    label: cn loss
    default: 5
    doc: |
      CN threshold value to classify genes within lost regions.
    type: int?
  cn_gain:
    label: cn gain
    default: 95
    doc: |
      CN threshold value to classify genes within gained regions.
    type: int?
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
    default: 5
    doc: |
      The number of top ranked genes to be presented.
    type: int?
  dataset:
    label: dataset
    default: "PANCAN"
    doc: |
      Reference dataset selection from https://github.com/umccr/RNAsum/blob/master/TCGA_projects_summary.md
    type: string
  batch_rm:
    label: batch rm
    default: TRUE
    doc: |
      Remove batch-associated effects between datasets. Available options are: "TRUE" (default) and "FALSE"
    type: boolean?
  filter:
    label: filter
    default: TRUE
    doc: |
      Filtering out low expressed genes. Available options are: "TRUE" (default) and "FALSE"
    type: boolean?
  log:
    label: log
    default: TRUE
    doc: |
      Log (base 2) transform data before normalisation. Available options are: "TRUE" (default) and "FALSE"
    type: boolean?
  save_tables:
    label: save tables
    default: TRUE
    doc: |
      Save interactive summary tables as HTML. Available options are: "TRUE" (default) and "FALSE"
    type: boolean?
  pcgr_splice_vars:
    label: PCGR splice vars
    default: TRUE
    doc: |
      Include non-coding splice region variants reported in PCGR. Available options are: "TRUE" (default) and "FALSE"
    type: boolean?

steps:
  run_rnasum_step:
    label: run rnasum step
    doc: |
      Run the rnasum pipeline
    in:
      dragen_wts_dir:
        source: dragen_wts_dir
      dragen_mapping_metrics:
        source: dragen_mapping_metrics
      dragen_fusions:
        source: dragen_fusions
      salmon:
        source: salmon
      arriba_dir:
        source: arriba_dir
      arriba_pdf:
        source: arriba_pdf
      arriba_tsv:
        source: arriba_tsv
      umccrise:
        source: umccrise
      manta_tsv:
        source: manta_tsv
      report_dir:
        source: report_dir
      sample_name:
        source: sample_name
      transform:
        source: transform
      norm:
        source: norm
      scaling:
        source: scaling
      drugs:
        source: drugs
      immunogram:
        source: immunogram
      pcgr_tiers_tsv:
        source: pcgr_tiers_tsv
      purple_gene_tsv:
        source: purple_gene_tsv
      pcgr_tier:
        source: pcgr_tier
      cn_loss:
        source: cn_loss
      cn_gain:
        source: cn_gain
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
      dataset:
        source: dataset
      batch_rm:
        source: batch_rm
      filter:
        source: filter
      log:
        source: log
      save_tables:
        source: save_tables
      pcgr_splice_vars:
        source: pcgr_splice_vars
    out:
      - id: rnasum_output_directory
      - id: rnasum_html
    run: ../../../tools/rnasum/1.1.0/rnasum__1.1.0.cwl

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
