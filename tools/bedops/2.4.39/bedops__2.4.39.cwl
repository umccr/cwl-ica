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
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: bedops--2.4.39
label: bedops v(2.4.39)
doc: |
  Runs bedops v2.4.39. Multifunctional tool
  bedops documentation can be found [here](https://bedops.readthedocs.io/en/latest/)
  Usage:
  Every input file must be sorted per the sort-bed utility.
  Each operation requires a minimum number of files as shown below.
    There is no fixed maximum number of files that may be used.
  Input files must have at least the first 3 columns of the BED specification.
  The program accepts BED and Starch file formats.
  May use '-' for a file to indicate reading from standard input (BED format only).

hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: xlarge
        coresMin: 4
        ramMin: 14000
    DockerRequirement:
        dockerPull: public.ecr.aws/biocontainers/bedops:2.4.39--hc9558a2_0

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: "run-bedops.sh"
        entry: |
          #!/usr/bin/env bash

          # Set up for failure
          set -euo pipefail

          # Run bedops command, write to output file
          eval bedops '"\${@}"' 1> "$(inputs.output_filename)"

baseCommand: [ "bash", "run-bedops.sh" ]

inputs:
  # Required inputs
  input_files:
    label: input files
    doc: |
      The bcl directory
    type: File[]
    inputBinding:
      # After all other arguments
      position: 100
  output_filename:
    label: output filename
    doc: |
      Redirects stdout
    type: string
  # Process flags (before all other arguments)
  chromosome:
    label: chromosome
    doc: |
      Jump to and process data for given <chromosome> only.
    type: string?
    inputBinding:
      position: 1
      prefix: "--chrom"
  ec:
    label: ec
    doc: |
      Error check input files (slower).
    type: boolean?
    inputBinding:
      position: 1
      prefix: "--ec"
  header:
    label: header
    doc: |
      Accept headers (VCF, GFF, SAM, BED, WIG) in any input file.
    type: string?
    inputBinding:
      position: 1
      prefix: "--header"
  range:
    label: range
    doc: |
      --range L:R:
      Add 'L' bp to all start coordinates and 'R' bp to end
      coordinates. Either value may be + or - to grow or
      shrink regions.  With the -e/-n operations, the first
      (reference) file is not padded, unlike all other files.
      OR:
      --range -S:S:
      Pad or shrink input file(s) coordinates symmetrically by S.
      This is shorthand for:
    type: string?
    inputBinding:
      position: 1
      prefix: "--range"
  # Operations (choose one of) - after process flags
  complement:
    label: complement
    doc: |
      Using the -c or --complement operation requires at least 1 BED file input.
      The output consists of the first 3 columns of the BED specification.
      Reports the intervening intervals in between all coordinates found in the input file(s).
    type: boolean?
    inputBinding:
      position: 2
      prefix: "--complement"
  difference:
    label: difference
    doc: |
      Using the -d or --difference operation requires at least 2 BED file inputs.
      The output consists of the first 3 columns of the BED specification.
      Reports the intervals found in the first file that are not present in the 2nd (or 3rd or 4th...) files.
    type: boolean?
    inputBinding:
      position: 2
      prefix: "--position"
  element_of:
    label: element of
    doc: |
      Using the -e or --element-of operation requires at least 2 BED file inputs.
      The output consists of all columns from qualifying rows of the first input file.
      -e produces exactly everything that -n does not, given the same overlap criterion.
    type: boolean?
    inputBinding:
      position: 2
      prefix: "--element-of"
  intersect:
    label: intersect
    doc: |
      Using the -i or --intersect operation requires at least 2 BED file inputs.
      The output consists of the first 3 columns of the BED specification.
      Reports the intervals common to all input files.
    type: boolean?
    inputBinding:
      position: 2
      prefix: "--intersect"
  merge:
    label: merge
    doc: |
      Using the -m or --merge operation requires at least 1 BED file input.
      The output consists of the first 3 columns of the BED specification.
      Merges together (flattens) all disjoint, overlapping, and adjoining intervals from all input files into
      contiguous, disjoint regions.
    type: boolean?
    inputBinding:
      position: 2
      prefix: "--merge"
  not_element_of:
    label: not element of
    doc: |
      Using the -n or --not-element-of operation requires at least 2 BED file inputs.
      The output consists of all columns from qualifying rows of the first input file.
      -n produces exactly everything that -e does not, given the same overlap criterion.
    type: boolean?
    inputBinding:
      position: 2
      prefix: "--not-element-of"
  partition:
    label: partition
    doc: |
      Using the -p or --partition operation requires at least 1 BED file input.
      The output consists of the first 3 columns of the BED specification.
      Breaks up inputs into disjoint (often adjacent) bed intervals.
    type: boolean?
    inputBinding:
      position: 2
      prefix: "--partition"
  symdiff:
    label: symdiff
    doc: |
      Using the -s or --symmdiff operation requires at least 2 BED file inputs.
      The output consists of the first 3 columns of the BED specification.
      Reports the intervals found in exactly 1 input file.
    type: boolean?
    inputBinding:
      position: 2
      prefix: "--symdiff"
  everything:
    label: everything
    doc: |
      Using the -u or --everything operation requires at least 1 BED file input.
      The output consists of all columns from all rows of all input files.
      If multiple rows are identical, the output will consist of all of them.
    type: boolean?
    inputBinding:
      position: 2
      prefix: "--everything"
  chop:
    label: chop
    doc: |
      Using the -w or --chop operation requires at least 1 BED file input.
      The output consists of the first 3 columns of the BED specification.
      Produces windowed slices from the merged regions of all input files.
    type: boolean?
    inputBinding:
      position: 2
      prefix: "--chop"


outputs:
  output_file:
    label: output file
    doc: |
      Output file, of varying format depending on the command run
    type: File
    outputBinding:
      glob: "$(inputs.output_filename)"

successCodes:
  - 0
