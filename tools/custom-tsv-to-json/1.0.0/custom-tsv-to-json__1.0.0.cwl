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
    s:name: Yinan Wang
    s:email: ywang16@illumina.com

s:maintainer:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: custom-tsv-to-json--1.0.0
label: custom-tsv-to-json v(1.0.0)
doc: |
    Given a tsv file (or csv / text file), strip the first set of rows as indicated in 'skip_rows' and convert
    the remainder to a compressed json file (in orient format).
    Original cwl tool can be found [here](https://github.com/YinanWang16/tso500-ctdna-post-processing/blob/main/cwl/tools/tsv2json/tsv2json.cwl)

# ILMN Resources Guide: https://support-docs.illumina.com/SW/ICA/ICA_CLI/Content/SW/ICA/IAPWES_RequestResources.htm
hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: medium
        coresMin: 1
        ramMin: 4000
    DockerRequirement:
        dockerPull: umccr/alpine-pandas:1.2.2


requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_output_file_name = function(input_tsv_file) {
          /*
          Get the name of the output file
          */
          var output_file_name_regex = /(\S+)\.(csv|tsv|txt)$/g;
          return output_file_name_regex.exec(input_tsv_file)[1] + ".json.gz";
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: tsv_to_json.py
        entry: |
          #!/usr/bin/env python3

          """
          Convert tsv to json
          """

          import pandas as pd
          import numpy as np
          import json
          from pathlib import Path
          import argparse
          from argparse import Namespace
          import re
          import gzip
          from typing import List

          # Get arguments
          def get_args() -> Namespace:
              """
              Get arguments for the command
              """
              parser = argparse.ArgumentParser(description='Convert tsv to json')

              # Arguments
              parser.add_argument('-i', '--input-file', required=True,
                                  help="Input tsv/csv file")
              parser.add_argument('-r', '--skip-rows', required=False,
                                  default=0, type=int,
                                  help="Skip first n rows of the input file")
              return parser.parse_args()


          def read_tsv(tsv_file: Path, skip_rows: int) -> pd.DataFrame:
              """
              Convert the csv/tsv file into a pandas dataframe
              :param tsv_file:
              :param skip_rows:
              :return:
              """

              # Could be a csv file, convert to records
              if tsv_file.name.endswith(".csv"):
                  df = pd.read_csv(tsv_file, sep=',', header=0, comment='#', skiprows=skip_rows)
              else:  # Could be .tsv or .txt
                  df = pd.read_csv(tsv_file, sep='\t', header=0, comment='#', skiprows=skip_rows)

              return df


          def main():
              """
              Convert tsv / csv to json
              """
              # Get args
              args = get_args()

              # File input
              input_csv_file = Path(args.input_file)
              skip_rows = args.skip_rows

              # Get the output file name
              json_file = re.sub(".(csv|tsv|txt)$", ".json.gz", input_csv_file.name)

              # Get the tsv as a pandas data frame
              tsv_df = read_tsv(input_csv_file, skip_rows)

              # Write tsv as a compressed json
              tsv_df.to_json(json_file, orient="records", force_ascii=True, compression="gzip")


          if __name__ == "__main__":
              main()


baseCommand: ["python3", "tsv_to_json.py"]


inputs:
  tsv_file:
    label: tsv file
    doc: |
      TSV file to be converted into json format
    type: File
    inputBinding:
      prefix: "--input"
  skip_rows:
    label: skip rows
    doc: |
      skip rows of the tsv file
    type: int?
    inputBinding:
      prefix: "--skip-rows"


outputs:
  json_gz_out:
    label: output json gzipped file
    doc: |
      The output gzipped json file
    type: File
    outputBinding:
      glob: "$(get_output_file_name(inputs.tsv_file.basename))"


successCodes:
  - 0
