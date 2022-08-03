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
id: qualimap--2.2.2
label: qualimap v(2.2.2)
doc: |
    It perform RNA-seq QC analysis on paired-end data http://qualimap.bioinfo.cipf.es/doc_html/command_line.html.

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standardHiCpu
            size: medium
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: quay.io/biocontainers/qualimap:2.2.2d--hdfd78af_2

requirements:
  InlineJavascriptRequirement: {}

baseCommand: [ qualimap, rnaseq ]

arguments:
  - --paired
  - --java-mem-size=$(inputs.java_mem)
  - prefix: -outdir
    valueFrom: $(inputs.out_dir)

inputs:
  tmp_dir:
    label: tmp dir
    doc: |
      Qualimap creates temporary bam files when sorting by name, which takes up space in the system tmp dir (usually /tmp). 
      This can be avoided by sorting the bam file by name before running Qualimap.
    type: string?
  java_mem:
    label: java mem
    doc: |
      Set desired Java heap memory size
    type: string
  out_dir:
    label: out dir
    doc: |
      Output folder for HTML report and raw data.
    type: string
    inputBinding:
      prefix: "-outdir"
  algorithm:
    label: algorithm
    doc: |
      Counting algorithm:
      uniquely-mapped-reads(default) or proportional.
    type: string?
    inputBinding:
      prefix: "--algorithm"
  input_bam:
    label: input bam
    doc: |
      Input mapping file in BAM format.
    type: File
    inputBinding:
      prefix: "-bam"
  seq_protocol:
    label: seq protocol
    type:
      - "null"
      - type: enum
        symbols:
           - strand-specific-forward
           - strand-specific-reverse
           - non-strand-specific
    doc: |
      Sequencing library protocol:
      strand-specific-forward, strand-specific-reverse or 
      non-strand-specific (default).
    inputBinding:
      prefix: "--sequencing-protocol"
  gtf:
    label: gtf
    doc: |
      Region file in GTF, GFF or BED format. 
      If GTF format is provided, counting is based on
      attributes, otherwise based on feature name.
    type: File
    inputBinding:
      prefix: "-gtf"

outputs:
  qualimap_qc:
    label: qualimap qc
    doc: |
      Output directory with qc files and report
    type: Directory
    outputBinding:
      glob: "$(inputs.out_dir)" 

successCodes:
  - 0
