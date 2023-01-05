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
id: star--2.7.10
label: star v(2.7.10)
doc: |
    Documentation for star v2.7.10

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standardHiCpu
        ilmn-tes:resources/size: large
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: "quay.io/biocontainers/star"

baseCommand: [STAR, --runMode, alignReads]

inputs:
  # Required Inputs
  run_thread_n:
    label: run thread n
    doc: |
      Defines the number of threads to be used for genome generation, it has
      to be set to the number of available cores on the server node.
    type: int
    inputBinding:
      prefix: "--runThreadN"
  genome_dir:
    label: genome dir
    doc: |
      Specifies path to the directory where the genome indices are stored.
    type: Directory
    inputBinding:
      prefix: "--genomeDir"
  forward_reads:
    label: forward reads
    doc: |
      Name(s) (with path) of the files containing the sequences to be mapped.
    type:
     - File
     - File[]
    inputBinding:
      prefix: "--readFilesIn"
      itemSeparator: ","
      position: 1
  reverse_reads:
    label: reverse reads
    doc: |
      If paired-end reads (like Illumina), both 1 and 2 must be provided.
    type:
     - "null"
     - File
     - File[]
    inputBinding:
      prefix: ""
      separate: false
      itemSeparator: ","
      position: 2
  # Optional Inputs
  gtf:
    label: GTF
    doc: |
      Path to annotations file.
    type: File?
    inputBinding:
      prefix: "--sjdbGTFfile"
  overhang:
    label: Overhang
    doc: |
      Specifies the length of the genomic sequence around the annotated junction
      to be used in constructing the splice junctions database.
    type: int?
    inputBinding:
      prefix: "--sjdbOverhang"
  out_filter_type:
    label: Out filter type
    doc: |
      Type of filtering.
    type:
     - "null"
     - type: enum
       symbols:
        - Normal
        - BySJout
    inputBinding:
      prefix: "--outFilterType"
  out_filter_intron_motifs:
    label: Out filter intron motifs 
    doc: |
      Filter alignment using their motifs.
    type:
     - "null"
     - type: enum
       symbols:
        - None
        - RemoveNoncanonical
        - RemoveNoncanonicalUnannotated
    inputBinding:
      prefix: "--outFilterIntronMotifs"
  out_sam_type:
    label: Out SAM type
    doc: |
      Type of SAM/BAM output.
    type:
     - "null"
     - type: enum
       symbols:
        - "BAM"
        - "SAM"
    inputBinding:
      prefix: "--outSAMtype"
      position: 3
  un_sorted:
    label: Unsorted
    doc: |
      Standard unsorted.
    type: boolean?
    inputBinding:
      prefix: "Unsorted"
      position: 4
  sorted_by_coordinate:
    label: Sorted by coordinate
    doc: |
      Sorted by coordinate. This option will allocate extra memory for sorting 
      which can be specified by –limitBAMsortRAM.
    type: boolean?
    inputBinding:
      prefix: "SortedByCoordinate"
      position: 5
  read_files_command:
    label: read files command
    doc: |
       Command line to execute for each of the input file. 
       This command should generate FASTA or FASTQ text and send it to stdout.
    type: string?
    inputBinding:
      prefix: "--readFilesCommand"
  align_intron_min:
    label: Align intron min
    doc: |
      Minimum intron size: genomic gap is considered intron if its
      length>=alignIntronMin, otherwise it is considered Deletion.
    type: int?
    inputBinding:
      prefix: "--alignIntronMin"
  align_intron_max:
    label: Align intron max
    doc: |
      Maximum intron size, if 0, max intron size will be determined by
      (2ˆwinBinNbits)*winAnchorDistNbins.
    type: int?
    inputBinding:
      prefix: "--alignIntronMax"
  align_mates_gap_max:
    label: Align mates gap max
    doc: |
      Maximum gap between two mates, if 0, max intron gap will be determined by
      (2ˆwinBinNbits)*winAnchorDistNbins.
    type: int?
    inputBinding:
      prefix: "--alignMatesGapMax"
  align_sj_overhang_min:
    label: Slign SJ overhang min
    doc: |
       Minimum overhang (i.e. block size) for spliced alignments.
    type: int?
    inputBinding:
      prefix: "--alignSJoverhangMin"
  align_sjdb_overhang_min:
    label: Align SJDB overhang min
    doc: |
      Minimum overhang (i.e. block size) for annotated (sjdb) spliced
      alignments.
    type: int?
    inputBinding:
      prefix: "--alignSJDBoverhangMin"
  seed_search_start_lmax:
    label: See search start lmax
    doc: |
      Minimum overhang (i.e. block size) for annotated (sjdb) spliced
      alignments
    type: int?
    inputBinding:
      prefix: "--seedSearchStartLmax"
  chim_out_type:
    label: Chim out type
    doc: |
      Type of chimeric output.
    type:
     - "null"
     - type: enum
       symbols:
        - Junctions
        - SeparateSAMold
        - WithinBAM
        - "WithinBAM HardClip"
        - "WithinBAM SoftClip"
    inputBinding:
      prefix: "--chimOutType"
  chim_segment_min:
    label: Chim segment min
    doc: |
       Type of chimeric output.
    type: int?
    inputBinding:
      prefix: "--chimSegmentMin"
  chim_junction_overhang_min:
    label: Chim junction overhang min
    doc: |
      Minimum length of chimeric segment length, if ==0, no chimeric.
      output
    type: int?
    inputBinding:
      prefix: "--chimJunctionOverhangMin"
  out_filter_multi_map_nmax:
    label: Out filter multi map nmax
    doc: |
    
    type: int?
    inputBinding:
      prefix: "--outFilterMultimapNmax"
  out_filter_mismatch_nmax:
    label: Out filter mismatch nmax
    doc: |
      Max number of multiple alignments allowed for a read: if exceeded, the read is considered
      unmapped.
    type: int?
    inputBinding:
      prefix: "--outFilterMismatchNmax"
  out_filter_mismatchn_over_lmax:
    label: Out filter mismatchn over lmax
    doc: |
    
    type: double?
    inputBinding:
      prefix: "--outFilterMismatchNoverLmax"
  out_reads_unmapped:
    label: Out reads unmapped
    doc: |
       Alignment will be output only if its ratio of mismatches to *mapped*
       length is less than or equal to this value.
    type:
     - "null"
     - type: enum
       symbols:
        - None
        - Fastx
    inputBinding:
      prefix: "--outReadsUnmapped"
  out_sam_strand_field:
    label: Out sam stand field
    doc: |
      Cufflinks-like strand field flag.
    type:
     - "null"
     - type: enum
       symbols:
        - None
        - intronMotif
    inputBinding:
      prefix: "--outSAMstrandField"
  out_sam_unmapped:
    label: Out SAM unmapped
    doc: |
      Output of unmapped reads in the SAM format.
    type:
     - "null"
     - type: enum
       symbols:
        - None
        - Within
        - "Within KeepPairs"
    inputBinding:
      prefix: "--outSAMunmapped"
  out_sam_mapq_unique:
    label: Out SAM mapq unique
    doc: |
      The MAPQ value for unique mappers.
    type: int?
    inputBinding:
      prefix: "--outSAMmapqUnique"
  out_sam_mode:
    label: Out SAM mode
    doc: |
      Mode of SAM output.
    type:
     - "null"
     - type: enum
       symbols:
        - None
        - Full
        - NoQS
    inputBinding:
      prefix: "--outSAMmode"
  limit_out_sam_one_read_bytes:
    label: Limit out sam one read bytes
    doc: |
      Max size of the SAM record (bytes) for one read. Recommended value:
      >(2*(LengthMate1+LengthMate2+100)*outFilterMultimapNmax
    type: int?
    inputBinding:
      prefix: "--limitOutSAMoneReadBytes"
  out_file_name_prefix:
    label: Out file name prefix
    doc: |
       Output files name prefix (including full or relative path). Can only be
       defined on the command line.
    type: string?
    inputBinding:
      prefix: "--outFileNamePrefix"
  genome_load:
    label: Genome load
    doc: |
      ode of shared memory usage for the genome files. Only used with
      –runMode alignReads.
    type:
     - "null"
     - type: enum
       symbols:
        - LoadAndKeep
        - LoadAndRemove
        - LoadAndExit
        - Remove
        - NoSharedMemory
    inputBinding:
      prefix: "--genomeLoad"

outputs:
  alignment:
    label: Alignment
    doc: |
      Output alignment file.
    type:
     - File
     - File[]
    outputBinding:
      glob: "*.bam"
  unmapped_reads:
    label: Unmapped reads
    doc: |
      Output unmapped reads.
    type: ["null", File]
    outputBinding:
      glob: "Unmapped.out*"

successCodes:
  - 0
