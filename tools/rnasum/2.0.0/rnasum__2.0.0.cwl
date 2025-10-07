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
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: rnasum--2.0.0
label: rnasum v(2.0.0)
doc: |
    Documentation for rnasum v2.0.0

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources:tier: standard
        ilmn-tes:resources:type: standard
        ilmn-tes:resources:size: large
        coresMin: 8
        ramMin: 32000
    DockerRequirement:
        dockerPull: ghcr.io/umccr/rnasum:2.0.0

baseCommand: [ "rnasum.R" ]

inputs:
  ## INPUTS (all mandatory) ##
  # Arriba
  arriba_pdf:
    label: arriba pdf
    doc: |
      PDF file containing the fusion plots produced by Arriba.
    type: File
    inputBinding:
      prefix: "--arriba_pdf"
  arriba_tsv:
    label: arriba tsv
    doc: |
      TSV file containing the fusion calls produced by Arriba.
    type: File
    inputBinding:
      prefix: "--arriba_tsv"

  # Dragen RNA
  dragen_fusions:
    label: dragen fusions
    doc: |
      File path to DRAGEN RNA-seq 'fusion_candidates.final' output.
    type: File
    inputBinding:
      prefix: "--dragen_fusions"
  dragen_mapping_metrics:
    label: dragen mapping metrics
    doc: |
      File path to DRAGEN RNA-seq 'mapping_metrics.csv' output.
    type: File
    inputBinding:
      prefix: "--dragen_mapping_metrics"
  salmon:
    label: salmon
    doc: |
      File path to 'quant.genes.sf' output.
    type: File
    inputBinding:
      prefix: "--salmon"

  # Sash
  pcgr_tiers_tsv:
    label: pcgr tiers tsv
    doc: |
      TSV file containing the PCGR tiers information.
    type: File
    inputBinding:
      prefix: "--pcgr_tiers_tsv"
  purple_gene_tsv:
    label: purple gene tsv
    doc: |
      File path to PURPLE 'purple.cnv.gene.tsv' output
    type: File
    inputBinding:
      prefix: "--purple_gene_tsv"
  sv_tsv:
    label: sv tsv
    doc: |
      TSV file containing the structural variant calls.
    type: File
    inputBinding:
      prefix: "--sv_tsv"

  ## PARAMETERS ##
  # Mandatory parameters
  dataset:
    label: dataset
    doc: |
      Dataset to use for annotation.
    type:
      type: enum
      symbols:
        - "BRCA"       # "Breast Invasive Carcinoma"
        - "THCA"       # "Thyroid Carcinoma"
        - "HNSC"       # "Head and Neck Squamous Cell Carcinoma"
        - "LGG"        # "Brain Lower Grade Glioma"
        - "KIRC"       # "Kidney Renal Clear Cell Carcinoma"
        - "LUSC"       # "Lung Squamous Cell Carcinoma"
        - "LUAD"       # "Lung Adenocarcinoma"
        - "PRAD"       # "Prostate Adenocarcinoma"
        - "STAD"       # "Stomach Adenocarcinoma"
        - "LIHC"       # "Liver Hepatocellular Carcinoma"
        - "COAD"       # "Colon Adenocarcinoma"
        - "KIRP"       # "Kidney Renal Papillary Cell Carcinoma"
        - "BLCA"       # "Bladder Urothelial Carcinoma"
        - "OV"         # "Ovarian Serous Cystadenocarcinoma"
        - "SARC"       # "Sarcoma"
        - "PCPG"       # "Pheochromocytoma and Paraganglioma"
        - "CESC"       # "Cervical Squamous Cell Carcinoma and Endocervical Adenocarcinoma"
        - "UCEC"       # "Uterine Corpus Endometrial Carcinoma"
        - "PAAD"       # "Pancreatic Adenocarcinoma"
        - "TGCT"       # "Testicular Germ Cell Tumours"
        - "LAML"       # "Acute Myeloid Leukaemia"
        - "ESCA"       # "Esophageal Carcinoma"
        - "GBM"        # "Glioblastoma Multiforme"
        - "THYM"       # "Thymoma"
        - "SKCM"       # "Skin Cutaneous Melanoma"
        - "READ"       # "Rectum Adenocarcinoma"
        - "UVM"        # "Uveal Melanoma"
        - "ACC"        # "Adrenocortical Carcinoma"
        - "MESO"       # "Mesothelioma"
        - "KICH"       # "Kidney Chromophobe"
        - "UCS"        # "Uterine Carcinosarcoma"
        - "DLBC"       # "Lymphoid Neoplasm Diffuse Large B-cell Lymphoma"
        - "CHOL"       # "Cholangiocarcinoma"
        - "LUAD-LCNEC" # "Lung Adenocarcinoma dataset including large-cell neuroendocrine carcinoma (LCNEC, n=14)"
        - "BLCA-NET"   # "Bladder Urothelial Carcinoma dataset including neuroendocrine tumours (NETs, n=2)"
        - "PAAD-IPMN"  # "Pancreatic Adenocarcinoma dataset including intraductal papillary mucinous neoplasm (IPMNs, n=2)"
        - "PAAD-NET"   # "Pancreatic Adenocarcinoma dataset including neuroendocrine tumours (NETs, n=8)"
        - "PAAD-ACC"   # "Pancreatic Adenocarcinoma dataset including acinar cell carcinoma (ACCs, n=1)"
        - "PANCAN"     # "Samples from all 33 cancer types, 10 samples from each"
        - "TEST"       # "Test samples"
    inputBinding:
      prefix: "--dataset"
  report_dir:
    label: report dir
    doc: |
      Directory path to output report.
    type: string
    inputBinding:
      prefix: "--report_dir"
  sample_name:
    label: sample name
    doc: |
      Sample name to be presented in report.
    type: string
    inputBinding:
      prefix: "--sample_name"
  subject_id:
    label: subject id
    doc: |
      Subject ID
    type: string
    inputBinding:
      prefix: "--subject_id"
  project:
    label: project
    doc: |
      Project name, used for annotation purposes only.
    type: string
    inputBinding:
      prefix: "--project"

  # Optional parameters
  batch_rm:
    label: batch rm
    doc: |
      Remove batch-associated effects between datasets.
    type: boolean?
    inputBinding:
      prefix: "--batch_rm"
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
  drugs:
    label: drugs
    doc: |
      Include drug matching section in the report.
    type: boolean?
    inputBinding:
      prefix: "--drugs"
  filter:
    label: filter
    doc: |
      Filtering out low expressed genes.
    type: boolean?
    inputBinding:
      prefix: "--filter"
  immunogram:
    label: immunogram
    doc: |
      Include drug matching section in the report.
    type: boolean?
    inputBinding:
      prefix: "--immunogram"
  log:
    label: log
    doc: |
      Log (base 2) transform data before normalisation.
    type: boolean?
    inputBinding:
      prefix: "--log"
  norm:
    label: norm
    doc: |
      Normalisation method, one of TMM, TMMwzp, RLE, upperquartile or none
    type:
      - "null"
      - type: enum
        symbols:
          - "TMM"           # "Trimmed Mean of M-values"
          - "TMMwzp"        # "TMM with zero-pseudocounts"
          - "RLE"           # "Relative Log Expression"
          - "quantile"      # "Quantile Normalization"
          - "upperquartile" # "Upper Quartile"
          - "none"          # "No normalization"
    inputBinding:
      prefix: "--norm"
  save_tables:
    label: save tables
    doc: |
      Save interactive summary tables as HTML.
    type: boolean?
    inputBinding:
      prefix: "--save_tables"
  scaling:
    label: scaling
    doc: |
      Apply "gene-wise" (default) or "group-wise" data scaling.
    type:
      type: enum
      symbols:
        - "gene-wise"  # "Scale each gene independently"
        - "group-wise" # "Scale genes within the same group together"
    inputBinding:
      prefix: "--scaling"
  top_genes:
    label: top genes
    doc: |
      The number of top ranked genes to be presented.
    type: int?
    inputBinding:
      prefix: "--top_genes"
  transform:
    label: transform
    doc: |
      Transformation method to be used when converting read counts
    type:
      type: enum
      symbols:
        - "CPM"  # "Counts Per Million"
        - "TPM"  # "Transcripts Per Million"
    inputBinding:
      prefix: "--transform"

  # PCGR parameters
  pcgr_splice_vars:
    label: PCGR splice vars
    doc: |
      Include non-coding splice region variants reported in PCGR.
    type: boolean?
    inputBinding:
      prefix: "--pcgr_splice_vars"
  pcgr_tier:
    label: pcgr tier
    doc: |
      Tier threshold for reporting variants reported in PCGR.
      Default is 4
    type: int?
    inputBinding:
      prefix: "--pcgr_tier"

  # Copy number parameter
  cn_loss:
    label: cn loss
    doc: |
      CN threshold value to classify genes within lost regions.
      Default is 5.
    type: int?
    inputBinding:
      prefix: "--cn_loss"
  cn_gain:
    label: cn gain
    doc: |
      CN threshold value to classify genes within gained regions.
      Default is 95.
    type: int?
    inputBinding:
      prefix: "--cn_gain"

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
