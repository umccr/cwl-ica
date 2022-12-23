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
id: custom-create-regions-bed-from-contigs-list--1.0.0
label: custom-create-regions-bed-from-contigs-list v(1.0.0)
doc: |
  create a bed file from a list of contigs objects

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: small
        coresMin: 1
        ramMin: 2000
    DockerRequirement:
        dockerPull: ghcr.io/umccr/alpine-pandas:1.4.3

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/contig/1.0.0/contig__1.0.0.yaml
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: get_regions_bed.py
        entry: |
          #!/usr/bin/env python3

          """
          Import args
          Collect args and confirm
          Generate regions bed from args
          """

          # Imports
          import pandas as pd
          import argparse
          from itertools import chain
          import sys
          from pathlib import Path

          # Globals
          OUTPUT_COLUMNS = ["chromosome", "start", "end"]

          # Inputs
          def get_args():
              """
              Get arguments for the command
              """
              parser = argparse.ArgumentParser(description="Create regions bed from contigs object list")

              # Arguments
              parser.add_argument("--output-regions-bed", required=True,
                                  help="Path to output bed file")
              parser.add_argument("--contig", action="append", nargs='*', required=True,
                                  help="Each of the contig objects")
              return parser.parse_args()


          # Check args
          def set_args(args):
              """
              Check arguments
              """

              # Create directory for bed file
              parent_dir = Path(getattr(args, "output_regions_bed", None)).parent
              parent_dir.mkdir(parents=True, exist_ok=True)

              # Initialise args dict with mandatory args
              contigs_arg = getattr(args, "fastq_list_row", [])
              contigs = []

              for contig in contigs_arg:
                contigs.append(json.loads(contig[0]))
              setattr(args, "contigs_list", contigs)

              return args


          # Create DF from args dict
          def create_regions_bed_from_contigs(contigs):
              """
              Create a dataframe from the set args output
              """

              # Create dataframe from args dict
              regions_df = pd.DataFrame(contigs)

              # Return data frame
              return regions_df


          def finalise_output_df(regions_df):
              """
              Returns the regions bed with the right column order.
              The should already be in this order but just to make sure
              """

              regions_df = regions_df.reindex(columns=OUTPUT_COLUMNS)

              return regions_df


          def write_regions_obj_to_bed(regions_df, output_file):
              """
              Write the regions_df to the specified output file
              """

              regions_df.to_csv(output_file, sep="\t", header=False, index=False)


          def main():
              # Get args
              args = get_args()

              # Get args dict from args and check args
              args = set_args(args)

              # Create df from args dict
              regions_df = create_regions_bed_from_args(args.contigs_list)

              # Construct output dfs
              regions_df = finalise_output_df(regions_df)

              # Write out csv
              write_regions_obj_to_bed(regions_df, args.output_regions_bed)


          if __name__ == "__main__":
              main()

baseCommand: [ "python", "get_regions_bed.py" ]

inputs:
  contig_list:
    label: List of contigs
    doc: |
      Each contig has the following attributes:
        * chromosome
        * start
        * end
    type:
      - type: array
        items: ../../../schemas/contig/1.0.0/contig__1.0.0.yaml#contig
        inputBinding:
          prefix: "--contig="
          separate: false
          valueFrom: |
            ${
              return JSON.stringify(self);
            }
    inputBinding:
      # Makes sure all items are together
      position: 1
  regions_bed:
    label: output file name for the regions bed file
    doc: |
      The output regions bed file name
    type: string?
    default: "regions.bed"
    inputBinding:
      prefix: "--output-regions-bed"

outputs:
  regions_bed_out:
    label: regions bed out
    doc: |
      This is the output of the regions bed file
    type: File
    outputBinding:
      glob: "$(inputs.regions_bed)"


successCodes:
  - 0
