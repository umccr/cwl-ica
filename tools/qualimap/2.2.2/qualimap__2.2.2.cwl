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
id: qualimap--2.2.2
label: qualimap v(2.2.2)
doc: |
    Qualimap perform RNA-seq QC analysis on paired-end data http://qualimap.bioinfo.cipf.es/doc_html/command_line.html.

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
        dockerPull: public.ecr.aws/biocontainers/qualimap:2.2.2d--hdfd78af_2

requirements:
  ResourceRequirement:
    tmpdirMin: |
      ${
        /* 1 Tb */
        return Math.pow(2, 20); 
      }
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: "run_qualimap.sh"
        entry: |
          #!/usr/bin/env bash
          
          # Set to fail
          set -euo pipefail
          
          # Set java opts
          if [[ -n "$(inputs.tmp_dir)" ]]; then
            export JAVA_OPTS="-Djava.io.tmpdir=$(inputs.tmp_dir)"
          fi
          
          # Run qualimap
          qualimap rnaseq --paired "\${@}"

baseCommand: [ "bash", "run_qualimap.sh" ]

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
    inputBinding:
      prefix: "--java-mem-size="
      separate: false
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
