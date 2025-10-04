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
id: rnasum-pipeline--2.0.0
label: rnasum-pipeline v(2.0.0)
doc: |
    Documentation for rnasum-pipeline v2.0.0

requirements:
    InlineJavascriptRequirement: {}
    ScatterFeatureRequirement: {}
    MultipleInputFeatureRequirement: {}
    StepInputExpressionRequirement: {}

inputs:
  ## INPUTS (all mandatory) ##
  # Arriba
  arriba_pdf:
    label: arriba pdf
    doc: |
      PDF file containing the fusion plots produced by Arriba.
    type: File
  arriba_tsv:
    label: arriba tsv
    doc: |
      TSV file containing the fusion calls produced by Arriba.
    type: File

  # Dragen RNA
  dragen_fusions:
    label: dragen fusions
    doc: |
      File path to DRAGEN RNA-seq 'fusion_candidates.final' output.
    type: File
  dragen_mapping_metrics:
    label: dragen mapping metrics
    doc: |
      File path to DRAGEN RNA-seq 'mapping_metrics.csv' output.
    type: File
  salmon:
    label: salmon
    doc: |
      File path to 'quant.genes.sf' output.
    type: File

  # Sash
  pcgr_tiers_tsv:
    label: pcgr tiers tsv
    doc: |
      TSV file containing the PCGR tiers information.
    type: File
  purple_gene_tsv:
    label: purple gene tsv
    doc: |
      File path to PURPLE 'purple.cnv.gene.tsv' output
    type: File
  sv_tsv:
    label: sv tsv
    doc: |
      TSV file containing the structural variant calls.
    type: File

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
  report_dir:
    label: report dir
    doc: |
      Directory path to output report.
    type: string
  sample_name:
    label: sample name
    doc: |
      Sample name to be presented in report.
    type: string
  subject_id:
    label: subject id
    doc: |
      Subject ID
    type: string
  project:
    label: project
    doc: |
      Project name, used for annotation purposes only.
    type: string

  # Optional parameters
  batch_rm:
    label: batch rm
    doc: |
      Remove batch-associated effects between datasets.
    type: boolean?
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
  drugs:
    label: drugs
    doc: |
      Include drug matching section in the report.
    type: boolean?
  filter:
    label: filter
    doc: |
      Filtering out low expressed genes.
    type: boolean?
  immunogram:
    label: immunogram
    doc: |
      Include drug matching section in the report.
    type: boolean?
  log:
    label: log
    doc: |
      Log (base 2) transform data before normalisation.
    type: boolean?
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
  save_tables:
    label: save tables
    doc: |
      Save interactive summary tables as HTML.
    type: boolean?
  scaling:
    label: scaling
    doc: |
      Apply "gene-wise" (default) or "group-wise" data scaling.
    type:
      type: enum
      symbols:
        - "gene-wise"  # "Scale each gene independently"
        - "group-wise" # "Scale genes within the same group together"
  top_genes:
    label: top genes
    doc: |
      The number of top ranked genes to be presented.
    type: int?
  transform:
    label: transform
    doc: |
      Transformation method to be used when converting read counts
    type:
      type: enum
      symbols:
        - "CPM"  # "Counts Per Million"
        - "TPM"  # "Transcripts Per Million"

  # PCGR parameters
  pcgr_splice_vars:
    label: PCGR splice vars
    doc: |
      Include non-coding splice region variants reported in PCGR.
    type: boolean?
  pcgr_tier:
    label: pcgr tier
    doc: |
      Tier threshold for reporting variants reported in PCGR.
      Default is 4
    type: int?

  # Copy number parameter
  cn_loss:
    label: cn loss
    doc: |
      CN threshold value to classify genes within lost regions.
      Default is 5.
    type: int?
  cn_gain:
    label: cn gain
    doc: |
      CN threshold value to classify genes within gained regions.
      Default is 95.
    type: int?


steps:
  run_rnasum_step:
    label: run rnasum step
    doc: |
      Run the rnasum pipeline step
    in:
      ## INPUTS (all mandatory) ##
      # Arriba
      arriba_pdf:
        source: arriba_pdf
      arriba_tsv:
        source: arriba_tsv
      # Dragen RNA
      dragen_fusions:
        source: dragen_fusions
      dragen_mapping_metrics:
        source: dragen_mapping_metrics
      salmon:
        source: salmon
      # Sash
      pcgr_tiers_tsv:
        source: pcgr_tiers_tsv
      purple_gene_tsv:
        source: purple_gene_tsv
      sv_tsv:
        source: sv_tsv
      ## PARAMETERS ##
      # Mandatory parameters
      dataset:
        source: dataset
      report_dir:
        source: report_dir
      sample_name:
        source: sample_name
      subject_id:
        source: subject_id
      project:
        source: project
      # Optional parameters
      batch_rm:
        source: batch_rm
      sample_source:
        source: sample_source
      dataset_name_incl:
        source: dataset_name_incl
      drugs:
        source: drugs
      filter:
        source: filter
      immunogram:
        source: immunogram
      log:
        source: log
      norm:
        source: norm
      save_tables:
        source: save_tables
      scaling:
        source: scaling
      top_genes:
        source: top_genes
      transform:
        source: transform
      # PCGR parameters
      pcgr_splice_vars:
        source: pcgr_splice_vars
      pcgr_tier:
        source: pcgr_tier
      # Copy number parameter
      cn_loss:
        source: cn_loss
      cn_gain:
        source: cn_gain
    out:
      - id: rnasum_output_directory
      - id: rnasum_html
    run: ../../../tools/rnasum/2.0.0/rnasum__2.0.0.cwl


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
