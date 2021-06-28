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
id: arriba-drawing--2.0.0
label: arriba-drawing v(2.0.0)
doc: |
    Documentation for arriba-drawing v2.0.0

hints:
  ResourceRequirement:
    ilmn-tes:resources:
      type: standardHiCpu
      size: large
  DockerRequirement:
    dockerPull: "uhrigs/arriba:2.0.0"
    dockerOutputDirectory: /output

requirements:
  InlineJavascriptRequirement: {}

baseCommand: ["/arriba_v2.0.0/draw_fusions.R"]

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
  proteinDomains:
    label: protein domains
    doc: |
      GFF3 file containing the genomic coordinates of protein domains
    type: File
    inputBinding:
      prefix: --proteinDomains=
      separate: false
      position: 6

outputs:
  outPDF:
    label: output PDF
    doc: |
      Output pdf file with fusion drawing
    type: File
    outputBinding: 
      glob: "$(inputs.output)"

successCodes:
  - 0
