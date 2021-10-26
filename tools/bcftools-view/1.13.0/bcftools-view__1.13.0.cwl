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
id: bcftools-view--1.13.0
label: bcftools-view v(1.13.0)
doc: |
    Documentation for bcftools-view v1.13.0. Detail at https://samtools.github.io/bcftools/bcftools.html#view 

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: small
        coresMin: 1
        ramMin: 2000
    DockerRequirement:
        dockerPull: quay.io/biocontainers/bcftools:1.13--h3a49de5_0

requirements:
  InlineJavascriptRequirement: {}

baseCommand: [ "bcftools", "view" ]

inputs:
  vcf:
    label: vcf
    doc: |
      VCF output from Dragen run
    type: File
    inputBinding:
      # Positional argument after all other options
      position: 100
  #output options
  output:
    label: output vcf
    doc: |
      Name of the output vcf.
      Defaults to filtered.vcf.gz
    type: string
    default: "filtered.vcf.gz"
    inputBinding:
      prefix: "--output"
      valueFrom: "$(self.toString())"
  drop_genotypes:
    label: drop genotypes
    doc: |
      Output compressed BCF (b), uncompressed BCF (u), compressed VCF (z), uncompressed VCF (v). 
    type: string?
    inputBinding:
      prefix: "--drop-genotypes"
  header_only:
    label: header only
    doc: |
      Output the VCF header only
    type: boolean?
    inputBinding:
      prefix: "--header-only"
  no_header:
    label: no header
    doc: |
      Suppress the header in VCF output
    type: boolean?
    inputBinding:
      prefix: "--no-header"
  compression_level:
    label: compression level
    doc: |
      Compression level. 0 stands for uncompressed, 1 for best speed and 9 for best compression.
    type: int?
    inputBinding:
      prefix: "--compression-level"
  output_type:
    label: output type
    doc: |
      Output compressed BCF (b), uncompressed BCF (u), compressed VCF (z), uncompressed VCF (v).
      Use the -Ou option when piping between bcftools subcommands to speed up performance by removing 
      unnecessary compression/decompression and VCF←→BCF conversion.
    type: string?
    inputBinding:
      prefix: "--output-type"
  regions:
    label: regions
    doc: |
      Comma-separated list of regions, see also -R, --regions-file. 
      Overlapping records are matched even when the starting coordinate is outside of the region, 
      unlike the -t/-T options where only the POS coordinate is checked. Note that -r cannot be 
      used in combination with -R.
    type:
      - "null"
      - type: array
        items: string
    inputBinding:
      prefix: "--regions"
  regions_file:
    label: regions file
    doc: |
      Regions can be specified either on command line or in a VCF, BED, or tab-delimited file (the default). 
    type: File?
    inputBinding:
      prefix: "--regions-file"
  targets:
    label: targets
    doc: |
      Similar as -r, --regions, but the next position is accessed by streaming the whole VCF/BCF 
      rather than using the tbi/csi index. 
    type: string?
    inputBinding:
      prefix: "--targets"
  targets_file:
    label: targets file
    doc: |
      Same -t, --targets, but reads regions from a file. Note that -T cannot be used in combination with -t.
    type: File?
    inputBinding:
      prefix: "--targets-file"
  threads:
    label: threads
    doc: |
      Use multithreading with INT worker threads. The option is currently used only for the compression 
      of the output stream, only when --output-type is b or z. Default: 0.
    type: int?
    inputBinding:
      prefix: "--threads"
  #subset options
  trim_alt_alleles:
    label: trim alt alleles
    doc: |
      Remove alleles not seen in the genotype fields from the ALT column. Note that if no alternate allele 
      remains after trimming, the record itself is not removed but ALT is set to ".". If the option -s or -S 
      is given, removes alleles not seen in the subset. INFO and FORMAT tags declared as Type=A, G or R will 
      be trimmed as well.
    type: boolean?
    inputBinding:
      prefix: "--trim-alt-alleles"
  force_samples:
    label: force samples
    doc: |
      Only warn about unknown subset samples
    type: boolean?
    inputBinding:
      prefix: "--force-samples"
  no_update:
    label: no update
    doc: |
      Do not (re)calculate INFO fields for the subset (currently INFO/AC and INFO/AN)
    type: boolean?
    inputBinding:
      prefix: "--no-update"
  samples:
    label: samples
    doc: |
      Comma-separated list of samples to include or exclude if prefixed with "^". 
      The sample order is updated to reflect that given on the command line. 
    type:
      - "null"
      - type: array
        items: string
    inputBinding:
      prefix: "--samples"
  samples_file:
    label: samples file
    doc: |
      File of sample names to include or exclude if prefixed with "^". One sample per line. 
      See also the note above for the -s, --samples option.
    type: File?
    inputBinding:
      prefix: "--samples-file"
  #filter options
  include:
    label: include condition
    doc: |
      Include sites for which EXPRESSION is true.
    type: string?
    inputBinding:
      prefix: "--include"
  exclude:
    label: exclude condition
    doc: |
      Exclude sites for which EXPRESSION is true. 
    type: string?
    inputBinding:
      prefix: "--exclude"
  min_ac:
    label: min ac
    doc: |
      Minimum allele count (INFO/AC) of sites to be printed. Specifying the type of allele is optional 
      and can be set to non-reference (nref, the default), 1st alternate (alt1), the least frequent 
      (minor), the most frequent (major) or sum of all but the most frequent (nonmajor) alleles.
    type: int?
    inputBinding:
      prefix: "--min-ac"
  max_ac:
    label: max ac
    doc: |
      Maximum allele count (INFO/AC) of sites to be printed. Specifying the type of allele is optional and 
      can be set to non-reference (nref, the default), 1st alternate (alt1), the least frequent (minor), 
      the most frequent (major) or sum of all but the most frequent (nonmajor) alleles.
    type: int?
    inputBinding:
      prefix: "--max-ac"
  apply_filters:
    label: apply filters
    doc: |
      Skip sites where FILTER column does not contain any of the strings listed in LIST. 
      For example, to include only sites which have no filters set, use -f .,PASS.
    type: string?
    inputBinding:
      prefix: "--apply-filters"
  genotype:
    label: genotype
    doc: |
      Include only sites with one or more homozygous (hom), heterozygous (het) or missing (miss) genotypes.
    type: string?
    inputBinding:
      prefix: "--genotype"
  known:
    label: known
    doc: |
      Print known sites only (ID column is not ".")
    type: boolean?
    inputBinding:
      prefix: "--known"
  min_alleles:
    label: min alleles
    doc: |
      Print sites with at least INT alleles listed in REF and ALT columns.
    type: int?
    inputBinding:
      prefix: "--min-alleles"
  max_alleles:
    label: max alleles
    doc: |
      Print sites with at most INT alleles listed in REF and ALT columns. 
      Use -m2 -M2 -v snps to only view biallelic SNPs.
    type: int?
    inputBinding:
      prefix: "--max-alleles"
  novel:
    label: novel
    doc: |
      Print novel sites only (ID column is ".")
    type: boolean?
    inputBinding:
      prefix: "--novel"
  types:
    label: types
    doc: |
      Comma-separated list of variant types to select. Site is selected if any of the ALT alleles is of the type requested.  
    type:
      - "null"
      - type: array
        items: string
    inputBinding:
      prefix: "--types"
  exclude_types:
    label: exclude types
    doc: |
      comma-separated list of variant types to exclude. Site is excluded if any of the ALT alleles is of the type requested. 
    type:
      - "null"
      - type: array
        items: string
    inputBinding:
      prefix: "--exclude-types"
   
outputs:
  filtered_vcf:
    label: filtered vcf
    doc: |
      VCF filtered on the AF threshold
    type: File
    outputBinding:
      glob: "$(inputs.output)"

successCodes:
  - 0
