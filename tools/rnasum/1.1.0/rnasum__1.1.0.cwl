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
id: rnasum--1.1.0
label: rnasum v(1.1.0)
doc: |
    Documentation for rnasum v1.1.0

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
requirements:
  InlineJavascriptRequirement: {}
  
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: standard
    ilmn-tes:resources/size: xxlarge
    coresMin: 8
    ramMin: 32000
  DockerRequirement:
    dockerPull: "ghcr.io/umccr/rnasum:1.1.0"

baseCommand: [ "rnasum.R" ]

inputs:
  # Input folders
  dragen_wts_dir:
    label: dragen transcriptome directory
    doc: |
      Location of the results from Dragen RNA-seq pipeline
    type: Directory?
    inputBinding:
      prefix: "--dragen_wts_dir"
  dragen_mapping_metrics:
    label: dragen mapping metrics
    doc: |
      Location of the mapping metrics from Dragen RNA-seq pipeline
    type: File?
    inputBinding:
      prefix: "--dragen_mapping_metrics"
  dragen_fusions:
    label: dragen fusions
    doc: |
      Location of the fusion output from Dragen RNA-seq pipeline
    type: File?
    inputBinding:
      prefix: "--dragen_fusions"
  salmon:
    label: salmom
    doc: |
      Location of the quantification output from salmon
    type: File?
    inputBinding:
      prefix: "--salmon"
  arriba_dir:
    label: arriba directory
    doc: |
      Location of the arriba outputs directory
    type: Directory?
    inputBinding:
      prefix: "--arriba_dir"
  arriba_pdf:
    label: arriba pdf
    doc: |
      Location of the pdf output from arriba
    type: File?
    inputBinding:
      prefix: "--arriba_pdf"
  arriba_tsv:
    label: arriba tsv
    doc: |
      Location of the tsv output from arriba
    type: File?
    inputBinding:
      prefix: "--arriba_tsv"
  umccrise:
    label: umccrise directory
    doc: |
      The umccrise output directory
    type: Directory?
    inputBinding:
      prefix: "--umccrise"
  manta_tsv:
    label: manta tsv
    doc: |
      Location of the tsv output from manta
    type: File?
    inputBinding:
      prefix: "--manta_tsv"
  report_dir:
    label: report dir
    doc: |
      Desired location for the outputs
    type: string
    inputBinding:
      prefix: "--report_dir"
      valueFrom: $(runtime.outdir + "/" + self)
  # Additional inputs
  sample_name:
    label: sample name
    doc: |
      Desired sample name to be presented in the report
    type: string
    inputBinding:
      prefix: "--sample_name"
  transform:
    label: transform
    default: "CPM"
    doc: |
      Transformation method to be used when converting read counts
    type: string?
    inputBinding:
      prefix: "--transform"
  norm:
    label: norm
    default: "TMM"
    doc: |
      Normalisation method
    type: string?
    inputBinding:
      prefix: "--norm"
  scaling:
    label: scaling
    default: "gene-wise"
    doc: |
      Apply "gene-wise" (default) or "group-wise" data scaling
    type: string?
    inputBinding:
      prefix: "--scaling"
  drugs:
    label: drugs
    doc: |
      Include drug matching section in the report.
    type: boolean?
    inputBinding:
      prefix: "--drugs"
  immunogram:
    label: immunogram
    doc: |
      Include drug matching section in the report.
    type: boolean?
    inputBinding:
      prefix: "--immunogram"
  pcgr_tiers_tsv:
    label: pcgr tiers tsv
    doc: |
      Location of the tsv output from pcgr
    type: File?
    inputBinding:
      prefix: "--pcgr_tiers_tsv"
  purple_gene_tsv:
    label: purple gene tsv
    doc: |
      Location of the tsv output from purple
    type: File?
    inputBinding:
      prefix: "--purple_gene_tsv"
  pcgr_tier:
    label: pcgr tier
    default: 4
    doc: |
      Tier threshold for reporting variants reported in PCGR.
    type: int?
    inputBinding:
      prefix: "--pcgr_tier"
  cn_loss:
    label: cn loss
    default: 5
    doc: |
      CN threshold value to classify genes within lost regions.
    type: int?
    inputBinding:
      prefix: "--cn_loss"
  cn_gain:
    label: cn gain
    default: 95
    doc: |
      CN threshold value to classify genes within gained regions.
    type: int?
    inputBinding:
      prefix: "--cn_gain"
  subject_id:
    label: subject id
    doc: |
      Subject ID. If umccrise output is specified (flag --umccrise) then Subject ID 
      is extracted from there and used to overwrite this argument.
    type: string?
    inputBinding:
      prefix: "--subject_id"
  sample_source:
    label: sample source
    doc: |
      Source of investigated sample (e.g. fresh frozen tissue, organoid).
      This information is for annotation purposes only
    type: string?
    inputBinding:
      prefix: "--sample_source"
  dataset_name_incl:
    label: dataset name incl
    doc: |
      Include dataset in the report and sample name.
    type: boolean?
    inputBinding:
      prefix: "--dataset_name_incl"
  project:
    label: project
    doc: |
      Project name. This information is for annotation purposes only
    type: string?
    inputBinding:
      prefix: "--project"
  top_genes:
    label: top genes
    default: 5
    doc: |
      The number of top ranked genes to be presented.
    type: int?
    inputBinding:
      prefix: "--top_genes"
  dataset:
    label: dataset  
    default: "PANCAN"
    doc: |
      Reference dataset selection from https://github.com/umccr/RNAsum/blob/master/TCGA_projects_summary.md
    type: string
    inputBinding:
      prefix: "--dataset"
  batch_rm:
    label: batch rm
    default: TRUE
    doc: |
      Remove batch-associated effects between datasets. Available options are: "TRUE" (default) and "FALSE"
    type: boolean?
    inputBinding:
      prefix: "--batch_rm"
  filter:
    label: filter
    default: TRUE
    doc: |
      Filtering out low expressed genes. Available options are: "TRUE" (default) and "FALSE"
    type: boolean?
    inputBinding:
      prefix: "--filter"
  log:
    label: log
    default: TRUE
    doc: |
      Log (base 2) transform data before normalisation. Available options are: "TRUE" (default) and "FALSE"
    type: boolean?
    inputBinding:
      prefix: "--log"
  save_tables:
    label: save tables
    default: TRUE
    doc: |
      Save interactive summary tables as HTML. Available options are: "TRUE" (default) and "FALSE"
    type: boolean?
    inputBinding:
      prefix: "--save_tables"
  pcgr_splice_vars:
    label: PCGR splice vars
    default: TRUE
    doc: |
      Include non-coding splice region variants reported in PCGR. Available options are: "TRUE" (default) and "FALSE"
    type: boolean?
    inputBinding:
      prefix: "--pcgr_splice_vars"

outputs:
  rnasum_output_directory:
    label: RNAsum output directory
    doc: Output directory containing all outputs of the RNAsum run
    type: Directory
    outputBinding:
      glob: "$(inputs.report_dir)"
  rnasum_html:
    label: rnasum html
    doc: |
      The HTML report output of RNAsum
    type: File
    outputBinding:
      glob: "$(inputs.report_dir)/$(inputs.sample_name).RNAseq_report.html"

successCodes:
  - 0

