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
id: rnasum--0.4.9
label: rnasum v(0.4.9)
doc: |
    Documentation for rnasum v0.4.9

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_script_path = function(){
          /*
          Abstract script path, can then be referenced in baseCommand attribute too
          Makes things more readable.
          */
          return "run_rnasum.sh";
        }
      - var get_eval_line = function(){
          /*
          ICA is inconsistent with cwl when it comes to handling @
          */
            return "eval Rscript ./RNAseq_report.R '\"\$@\"' \n";
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: $(get_script_path())
        entry: |
          #!/usr/bin/bash

          # Fail on non-zero exit code
          set -euo pipefail

          # Copy files into current working directory
          cd /rmd_files/

          # Run rnasum with input parameters
          $(get_eval_line())

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: standard
    ilmn-tes:resources/size: xxlarge
    coresMin: 8
    ramMin: 32000
  DockerRequirement:
    dockerPull: "ghcr.io/umccr/rnasum:0.4.9"

baseCommand: ["bash"]

arguments:
  - position: -1
    valueFrom: "$(get_script_path())"

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
      prefix: "--bcbio_rnaseq"
  arriba_directory:
    label: arriba directory
    doc: |
      Location of the arriba outputs directory
    type: Directory?
    inputBinding:
      prefix: "--arriba_rnaseq"
  umccrise_directory:
    label: umccrise directory
    doc: |
      The umccrise output directory
    type: Directory?
    inputBinding:
      prefix: "--umccrise"
  ref_data_directory:
    label: reference data directory
    doc: |
      Location of the reference and annotation files
    type: Directory
    inputBinding:
      prefix: "--ref_data_dir"
  report_directory:
    label: report dir
    doc: |
      Desired location for the report
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
    doc: |
      Transformation method to be used when converting read counts
    type: string?
    inputBinding:
      prefix: "--transform"
  norm:
    label: norm
    doc: |
      Normalisation method
    type: string?
    inputBinding:
      prefix: "--norm"
  batch_rm:
    label: batch rm
    doc: |
      Remove batch-associated effects between datasets
    type: boolean?
    inputBinding:
      prefix: "--batch_rm"
  filter:
    label: filter
    doc: |
      Filtering out low expressed genes
    type: boolean?
    inputBinding:
      prefix: "--filter"
  log:
    label: log
    doc: |
      Log (base 2) transform data before normalisation
    type: boolean?
    inputBinding:
      prefix: "--log"
  scaling:
    label: scaling
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
  pcgr_tier:
    label: pcgr tier
    doc: |
      Tier threshold for reporting variants reported in PCGR.
    type: int?
    inputBinding:
      prefix: "--pcgr_tier"
  pcgr_splice_vars:
    label: pcgr splice vars
    doc: |
      Include non-coding splice region variants reported in PCGR.
    type: boolean?
    inputBinding:
      prefix: "--pcgr_splice_vars"
  cn_loss:
    label: cn loss
    doc: |
      CN threshold value to classify genes within lost regions.
    type: int?
    inputBinding:
      prefix: "--cn_loss"
  cn_gain:
    label: cn gain
    doc: |
      CN threshold value to classify genes within gained regions.
    type: int?
    inputBinding:
      prefix: "--cn_gain"
  clinical_info:
    label: clinical info
    doc: |
      xslx file with clinical information.
    type: File?
    inputBinding:
      prefix: "--clinical_info"
  clinical_id:
    label: clinical id
    doc: |
      ID required to match sample with the subject clinical information (specified in flag --clinical_info).
    type: string?
    inputBinding:
      prefix: "--clinical_id"
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
    doc: |
      The number of top ranked genes to be presented.
    type: int?
    inputBinding:
      prefix: "--top_genes"
  hide_code_btn:
    label: hide code btn
    doc: |
      Hide the "Code" button allowing to show/hide code chunks in the final HTML report.
    type: boolean?
    inputBinding:
      prefix: "--hide_code_btn"
  grch_version:
    label: grch version
    doc: |
      Human reference genome version used for genes annotation.
    type: int?
    inputBinding:
      prefix: "--grch_version"
  dataset:
    label: dataset
    doc: |
      Reference dataset selection from https://github.com/umccr/RNAsum/blob/master/TCGA_projects_summary.md
    type: string
    inputBinding:
      prefix: "--dataset"
  save_tables:
    label: save tables
    doc: |
      save tables
    type: boolean?
    inputBinding:
      prefix: "--save_tables"

outputs:
  rnasum_output_directory:
    label: RNAsum output directory
    doc: Output directory containing all outputs of the RNAsum run
    type: Directory
    outputBinding:
      glob: "$(inputs.report_directory)"
  rnasum_html:
    label: rnasum html
    doc: |
      The HTML report output of RNAsum
    type: File
    outputBinding:
      glob: "$(inputs.report_directory)/$(inputs.sample_name).RNAseq_report.html"

successCodes:
  - 0
