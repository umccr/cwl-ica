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
id: arriba-drawing--2.3.0
label: arriba-drawing v(2.3.0)
doc: |
    Documentation for arriba-drawing v2.3.0

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: standardHiCpu
    ilmn-tes:resources/size: large
    coresMin: 72
    ramMin: 140000
  DockerRequirement:
    dockerPull: "uhrigs/arriba:2.3.0"

requirements:
  InlineJavascriptRequirement: {}

baseCommand: [ "/arriba_v2.3.0/draw_fusions.R" ]

inputs:
  annotation:
    label: annotation
    doc: |
      Gene annotation in GTF format
    type: File
    inputBinding:
      prefix: --annotation=
      separate: false
      position: 1
  fusions:
    label: fusions
    doc: |
      File containing fusion predictions from Arriba
    type: File
    inputBinding:
      prefix: --fusions=
      separate: false
      position: 2
  output:
    label: output
    doc: |
      Output file in PDF format containing the visualizations of the gene fusions
    type: string?
    default: fusions.pdf
    inputBinding:
      prefix: --output=
      separate: false
      position: 3
  bam_file:
    label: alignment
    doc: |
      BAM file containing normal alignments from STAR
    type: File
    secondaryFiles: 
      - .bai
    inputBinding:
      prefix: --alignments=
      separate: false
      position: 4
  cytobands:
    label: cytobands
    doc: |
      Coordinates of the Giemsa staining bands. This information is used to draw ideograms
    type: File
    inputBinding:
      prefix: --cytobands=
      separate: false
      position: 5
  protein_domains:
    label: protein domains
    doc: |
      GFF3 file containing the genomic coordinates of protein domains
    type: File
    inputBinding:
      prefix: --proteinDomains=
      separate: false
      position: 6
  sample_name:
    label: sample name
    doc: |
      Sample name
    type: string?
    inputBinding:
      prefix: --sampleName=
      separate: false
      position: 7
  squish_introns:
    label: squish introns
    doc: |
      Squish introns. Default true
    type: boolean?
    inputBinding:
      prefix: --squishIntrons=
      separate: false
      position: 8
  print_exon_labels:
    label: print exon labels
    doc: |
      Print exon labels. Default true
    type: boolean?
    inputBinding:
      prefix: --printExonLabels=
      separate: false
      position: 9
  render_3d_effect:
    label: render 3d effect
    doc: |
      Render 3d effect. Default true
    type: boolean?
    inputBinding:
      prefix: --render3dEffect=
      separate: false
      position: 10
  pdf_width:
    label: pdf width
    doc: |
      PDF width. Default 11.692
    type: int?
    inputBinding:
      prefix: --pdfWidth=
      separate: false
      position: 11
  color_1:
    label: color 1
    doc: |
      color 1. Default #e5a5a5
    type: string?
    inputBinding:
      prefix: --color1=
      separate: false
      position: 12
  color_2:
    label: color 2
    doc: |
      color 2. Default #a7c4e5
    type: string?
    inputBinding:
      prefix: --color2=
      separate: false
      position: 13
  merge_domains_overlapping_by:
    label: merge domains overlapping
    doc: |
      Merge domains overlapping. Default 0.9
    type: int?
    inputBinding:
      prefix: --mergeDomainsOverlappingBy=
      separate: false
      position: 14
  optimize_domain_colors:
    label: optimize domain colors
    doc: |
      Optimize domain colors. Default false.
    type: boolean?
    inputBinding:
      prefix: --optimizeDomainColors=
      separate: false
      position: 15
  font_size:
    label: font size
    doc: |
      Font size. Default 1.
    type: int?
    inputBinding:
      prefix: --fontSize=
      separate: false
      position: 16
  font_family:
    label: font family
    doc: |
      Font family. Default Helvetica.
    type: string?
    inputBinding:
      prefix: --fontFamily=
      separate: false
      position: 17
  transcript_selection:
    label: transcript selection
    doc: |
      Transcript selection. Default coverage
    type: string?
    inputBinding:
      prefix: --transcriptSelection=
      separate: false
      position: 18
  fixed_scale:
    label: fixed scale
    doc: |
      Fixed scale. Default 0.
    type: int?
    inputBinding:
      prefix: --fixedScale=
      separate: false
      position: 19
  coverage_range:
    label: coverage range
    doc: |
      Coverage range. Default 0.
    type: int?
    inputBinding:
      prefix: --coverageRange=
      separate: false
      position: 20

outputs:
  output_pdf:
    label: output PDF
    doc: |
      Output pdf file with fusion drawing
    type: File
    outputBinding: 
      glob: "$(inputs.output)"

successCodes:
  - 0
