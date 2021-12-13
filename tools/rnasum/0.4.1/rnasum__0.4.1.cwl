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
id: rnasum--0.4.1
label: rnasum v(0.4.1)
doc: |
    RNA-seq reporting workflow designed to post-process, summarise and visualise an output from bcbio-nextgen RNA-seq or Dragen RNA pipelines. 
    Its main application is to complement genome-based findings from umccrise pipeline and to provide additional evidence for detected alterations.

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standardHiCpu
            size: large
    DockerRequirement:
        dockerPull: "umccr/rnasum:0.4.1"

baseCommand: ["Rscript"]

arguments:
  - position: -1
    valueFrom: "./RNAseq_report.R"

inputs:
  # Input folders
  dragen_transcriptome_directory:
    label: dragen transcriptome directory
    doc: |
      Location of the results from Dragen RNA-seq pipeline
    type: Directory?
    inputBinding:
      prefix: "--dragen_rnaseq"
  bcbio_transcriptome_directory:
    label: bcbio transcriptome directory
    doc: |
      Location of the results from bcbio RNA-seq pipeline
    type: Directory?
    inputBinding:
      prefix: "--dragen_rnaseq"
  umccrise_directory:
    label: umccrise directory
    doc: |
      The umccrise output directory
    type: Directory?
    inputBinding:
      prefix: " --umccrise"
  ref_data_dir:
    label: reference data directory
    doc: |
      Location of the reference and annotation files
    type: Directory
    inputBinding:
      prefix: " --ref_data_dir"
  report_dir:
    label: report dir
    doc: |
      Desired location for the report
    type: string
    inputBinding:
      prefix: " --report_dir"
  # Additional inputs
  sample_name:
    label: sample name
    doc: |
      Desired sample name to be presented in the report
    type: string
    inputBinding:
      prefix: " --sample_name"
  transform:
    label: transform
    doc: |
      Transformation method to be used when converting read counts
    type: string?
    default: "CPM"
    inputBinding:
      prefix: " --transform"
  norm:
    label: norm
    doc: |
      Normalisation method
    type: string?
    inputBinding:
      prefix: " --norm"
  batch_rm:
    label: batch rm
    doc: |
      Remove batch-associated effects between datasets
    type: boolean?
    default: true
    inputBinding:
      prefix: " --batch_rm"
  filter:
    label: filter
    doc: |
      Filtering out low expressed genes
    type: boolean?
    default: true
    inputBinding:
      prefix: " --filter"
  log:
    label: log
    doc: |
      Log (base 2) transform data before normalisation
    type: boolean?
    default: true
    inputBinding:
      prefix: " --log"
  dataset:
    label: dataset
    doc: |
      Reference dataset selection from https://github.com/umccr/RNAsum/blob/master/TCGA_projects_summary.md
    type: string?
    inputBinding:
      prefix: " --dataset"
  save_tables:
    label: save tables
    doc: |
      save tables
    type: boolean?
    inputBinding:
      prefix: "  --save_tables"

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
      glob: "$(inputs.report_dir)/*.html"

successCodes:
  - 0
