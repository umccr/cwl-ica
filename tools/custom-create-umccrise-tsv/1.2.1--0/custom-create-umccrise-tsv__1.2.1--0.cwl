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
id: custom-create-umccrise-tsv--1.2.1--0
label: custom-create-umccrise-tsv v(1.2.1--0)
doc: |
    Create umccrise tsv based on the mount paths. Take inputs as a json string and drop null columns.

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/Content/SW/ICA/RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: small
        coresMin: 1
        ramMin: 3000
    DockerRequirement:
        dockerPull: umccr/alpine-pandas:1.2.2

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: "create-umccr-tsv.py"
        entry: |
          #!/usr/bin/env python3

          """
          Import args
          Collect args and confirm
          Generate csv from args
          Set paths as uuids for each sample row
          """

          # Imports
          import pandas as pd
          from pathlib import Path
          import argparse
          from uuid import uuid4
          import json
          from typing import List

          # Globals
          SET_COLUMNS = ["sample", "wgs", "normal",
                         "exome", "exome_normal",
                         "rna", "rna_bcbio", "rna_sample",
                         "somatic_vcf", "germline_vcf", "sv_vcf"]

          # Inputs
          def get_args():
              """
              Get arguments for the command
              """
              parser = argparse.ArgumentParser(description="Create fastq list file from inputs")

              # Arguments
              parser.add_argument("--umccrise-input-row", action="append", nargs='*', required=True,
                                  help="Input element to the")
              parser.add_argument("--output-file", required=True,
                                  help="Where to write the outputs to")

              return parser.parse_args()


          # Check args
          def set_args(args):
              """
              Check arguments
              """

              # Create directory for csv path
              output_umccrise_input_tsv_arg = getattr(args, "output_file", None)
              output_umccrise_input_tsv_path = Path(output_umccrise_input_tsv_arg)
              output_umccrise_input_tsv_path.parent.mkdir(parents=True, exist_ok=True)
              setattr(args, "output_file", output_umccrise_input_tsv_path)

              # Get fastq list rows as list of dicts
              umccrise_input_rows_arg = getattr(args, "umccrise_input_row", [])
              umccrise_input_rows = []

              # Import fastq list row arg
              print(umccrise_input_rows_arg)
              for umccrise_input_row_arg in umccrise_input_rows_arg:
                  umccrise_input_rows.append(json.loads(umccrise_input_row_arg[0]))
              setattr(args, "umccrise_input_row_list", umccrise_input_rows)

              return args


          # Create DF from args dict
          def create_umccrise_df_from_args_dict(umccrise_rows: List[dict]) -> pd.DataFrame:
              """
              Create a dataframe from the set args output
              """
              # Set umccrise_df
              umccrise_df = pd.DataFrame(columns=SET_COLUMNS)

              # Create dataframe from args dict
              for umccrise_row in umccrise_rows:
                  umccrise_df = umccrise_df.append(umccrise_row, ignore_index=True)

              # Drop na columns
              umccrise_df.dropna(axis='columns', how='all', inplace=True)

              return umccrise_df


          def write_umccrise_to_csv(umccrise_df: pd.DataFrame, output_file: Path):
              """
              Write the umccrise tsv to the output file
              """

              umccrise_df.to_csv(output_file, header=True, index=False, sep="\t")


          def main():
              # Get args
              args = get_args()

              # Get args dict from args and check args
              args = set_args(args)

              # Create df from args dict
              umccrise_df = create_umccrise_df_from_args_dict(args.umccrise_input_row_list)

              # Write out mount paths
              write_umccrise_to_csv(umccrise_df, args.output_file)


          if __name__ == "__main__":
              main()



baseCommand: [ "python3", "create-umccr-tsv.py" ]

inputs:
  input_json_strs:
    label: input json strs
    doc: |
      A list json strings as output from the the create-predefined-mount-paths-and-umccrise-row-from-umccrise-input-schema expression
    type:
      - type: array
        items: string
        inputBinding:
          prefix: "--umccrise-input-row"
          position: 1
  output_file:
    label: output file
    doc: |
      Name of the output file
    type: string?
    default: "umccrise.tsv"
    inputBinding:
      prefix: "--output-file"

outputs:
  umccrise_input_tsv:
    label: umccrise input tsv
    doc: |
      The umccrse input tsv file
    type: File
    outputBinding:
      glob: "$(inputs.output_file)"

successCodes:
  - 0
