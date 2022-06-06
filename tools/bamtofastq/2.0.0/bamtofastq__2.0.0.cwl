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
id: bamtofastq--2.0.0
label: bamtofastq v(2.0.0)
doc: |
    Documentation for bamtofastq v2.0.0

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
        dockerPull: "quay.io/wtsicgp/dockstore-biobambam2:2.0.0"

baseCommand: ["/opt/wtsi-cgp/bin/bamtofastq"]

inputs:
  F:
    label: F1
    type: string?
    doc: "matched pairs first mates"
    inputBinding:
        prefix: F=
        separate: false
  F2:
    label: F2
    type: string?
    doc: "matched pairs second mates"
    inputBinding:
      prefix: F2=
      separate: false
  S:
    label: single end
    type: string?
    doc: "single end"
    inputBinding:
      prefix: S=
      separate: false
  O:
    label: unmatched pairs mate1
    type: string?
    doc: "unmatched pairs first mates"
    inputBinding:
      prefix: O=
      separate: false
  O2:
    label: unmatched pairs mate2
    type: string?
    doc: "unmatched pairs second mates"
    inputBinding:
      prefix: O2=
      separate: false
  collate:
    label: collate
    type: int?
    doc: "collate pairs"
    inputBinding:
      prefix: collate=
      separate: false
  combs:
    label: combs
    type: int?
    doc: "print some counts after collation based processing"
    inputBinding:
      prefix: combs=
      separate: false
  filename:
    label: file name
    type: File
    doc: "input filename"
    streamable: true
    inputBinding:
      prefix: filename=
      separate: false
  inputformat:
    label: input format
    type: string?
    doc: "input format: cram, bam or sam [bam]"
    inputBinding:
      prefix: inputformat=
      separate: false
  reference:
    label: reference
    type: File?
    doc: "name of reference FastA in case of inputformat=cram"
    inputBinding:
      prefix: reference=
      separate: false
  ranges:
    label: ranges
    type: string?
    doc: "input ranges (bam and cram input only, default: read complete file)"
    inputBinding:
      prefix: ranges=
      separate: false
  exclude:
    label: exclude
    type: string?
    doc: "exclude alignments matching any of the given flags [SECONDARY,SUPPLEMENTARY]"
    inputBinding:
      prefix: exclude=
      separate: false
  disablevalidation:
    label: disable validation
    type: int?
    doc: "disable validation of input data [0]"
    inputBinding:
      prefix: disablevalidation=
      separate: false
  colhlog:
    label: col h log
    type: int?
    doc: "base 2 logarithm of hash table size used for collation [18]"
    inputBinding:
      prefix: colhlog=
      separate: false
  colsbs:
    label: col s bs
    type: int?
    doc: "size of hash table overflow list in bytes [33554432]"
    inputBinding:
      prefix: colsbs=
      separate: false
  T:
    label: t
    type: string?
    doc: "temporary file name [bamtofastq_*]"
    inputBinding:
      prefix: exclude=
      separate: false
  gz:
    label: gz
    type: int?
    doc: "compress output streams in gzip format (default: 0)"
    inputBinding:
      prefix: gz=
      separate: false
  level:
    label: level
    type: int?
    doc: "compression setting if gz=1 (-1=zlib default,0=uncompressed,1=fast,9=best)"
    inputBinding:
      prefix: level=
      separate: false
  fasta:
    label: fasta
    type: int?
    doc: "output FastA instead of FastQ"
    inputBinding:
      prefix: fasta=
      separate: false
  inputbuffersize:
    label: input buffer size
    type: int?
    doc: "size of input buffer"
    inputBinding:
      prefix: inputbuffersize=
      separate: false
  outputperreadgroup:
    label: output per read group
    type: int?
    doc: "split output per read group (for collate=1 only)"
    inputBinding:
      prefix: outputperreadgroup=
      separate: false
  outputperreadgroupsuffixF:
    label: output per read group suffix F1
    type: string?
    doc: "suffix for F category when outputperreadgroup=1 [_1.fq]"
    inputBinding:
      prefix: outputperreadgroupsuffixF=
      separate: false
  outputperreadgroupsuffixF2:
    label: output per read group suffix F2
    type: string?
    doc: "suffix for F2 category when outputperreadgroup=1 [_2.fq]"
    inputBinding:
      prefix: outputperreadgroupsuffixF2=
      separate: false
  outputperreadgroupsuffixO:
    label: output per read group suffix O
    type: string?
    doc: "suffix for O category when outputperreadgroup=1 [_o1.fq]"
    inputBinding:
      prefix: outputperreadgroupsuffixO=
      separate: false
  outputperreadgroupsuffixO2:
    label: output per read group suffix O2
    type: string?
    doc: "suffix for O2 category when outputperreadgroup=1 [_o2.fq]"
    inputBinding:
      prefix: outputperreadgroupsuffixO2=
      separate: false
  outputperreadgroupsuffixS:
    label: output per read group suffix S 
    type: string?
    doc: "suffix for S category when outputperreadgroup=1 [_s.fq]"
    inputBinding:
      prefix: outputperreadgroupsuffixS=
      separate: false
  tryoq:
    label: try oq
    type: int?
    doc: "use OQ field instead of quality field if present (collate={0,1} only) [0]"
    inputBinding:
      prefix: tryoq=
      separate: false
  split:
    label: split
    type: int?
    doc: "split named output files into chunks of this amount of reads (0: do not split)"
    inputBinding:
      prefix: split=
      separate: false
  splitprefix:
    label: split prefix
    type: string?
    doc: "file name prefix if collate=0 and split>0"
    inputBinding:
      prefix: splitprefix=
      separate: false
  tags:
    label: tags
    type: int?
    doc: "list of aux tags to be copied (default: do not copy any aux fields)"
    inputBinding:
      prefix: tags=
      separate: false
  outputperreadgrouprgsm:
    label: output per readgroup rgsm
    type: int?
    doc: "add read group field SM ahead of read group id when outputperreadgroup=1 (for collate=1 only)"
    inputBinding:
      prefix: outputperreadgrouprgsm=
      separate: false
  outputperreadgroupprefix:
    label: output per read group prefix
    type: string?
    doc: "prefix added in front of file names if outputperreadgroup=1 (for collate=1 only)"
    inputBinding:
      prefix: outputperreadgroupprefix=
      separate: false

outputs:
  output:
    type:
      type: array
      items: File
    outputBinding:
      glob:
        - "*.fq"
        - "*.fq.gz"
        - "*.fa"
        - "*.fa.gz"

successCodes:
  - 0
