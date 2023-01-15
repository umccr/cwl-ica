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
    s:name: Yinan Wang
    s:email: ywang16@illumina.com

s:maintainer:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X


# ID/Docs
id: custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json--1.0.0
label: custom-tso500-align-collapse-fusion-caller-csv-metrics-to-json v(1.0.0)
doc: |
    Collate a list of dragen metric csv files and output as a compressed json.
    Original CWL File can be found [here](https://github.com/YinanWang16/tso500-ctdna-post-processing/blob/main/cwl/tools/tsv2json/tsv2json.cwl)

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: small
        coresMin: 1
        ramMin: 3
    DockerRequirement:
        dockerPull: ghcr.io/umccr/alpine-pandas:1.2.2

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: align_collapse_fusion_caller_csv_metrics_to_json.py
        entry: |
          #!/usr/bin/ev python3

          # Imports
          import pandas as pd
          import json
          import csv
          import re
          import argparse
          import gzip
          from typing import List
          from argparse import Namespace
          from pathlib import Path
          from itertools import chain

          # Globals
          METRICS_COLUMNS = ['metrics_name', 'place_holder', 'descriptive_name', 'value', 'percent']

          def get_args() -> Namespace:
              """
              Get all of the expected metrics files
              :return: args
              """
              parser = argparse.ArgumentParser(description='Convert AlignCollapseFusionCaller/*metrics.csv to json')

              # add Arguments
              parser.add_argument('--csv-metrics-file', action="append", nargs='*', required=True,
                                  help="List of csv metrics files")
              parser.add_argument('--output-prefix', required=False,
                                  help='Output prefix of the output file')

              return parser.parse_args()


          def string_or_list(value):
              """
              return a string or list of a value
              """

              # Umi Metrics have value outputs with the following info like: {0|0|45030|3010|163|14}
              if re.match(r'^{.*}$', str(value)) is not None:
                  value = re.sub('{|}', '', str(value))
                  return [int(s) for s in value.split('|')]
              else:
                  try:
                      return float(value)
                  except ValueError:
                      return value


          def get_series_as_dict(row: pd.Series) -> dict:
              """
              From the pandas series row,
              collect the descriptive name,
              value and percentage column (if it exists)
              :param row:
              :return:
              """

              # Initialise dict with name and value from row
              metrics_data = {
                  "name": row["descriptive_name"],
                  "value": string_or_list(row["value"])
              }

              # Add percentage if it exists
              if 'percent' in row.keys() and not pd.isna(row["percent"]):
                  # Append percentage
                  metrics_data["percent"] = pd.to_numeric(row["percent"])

              return metrics_data


          def make_metric_dict(csv_file: Path) -> dict:
              """
              Add in metrics dictionary
              Since all lines do not necessarily conform to having the same number of columns,
              we cannot use the read_csv tool and instead assign each line as a pandas series, line by line!
              :param csv_file:
              :return:
              """

              # Read csv file
              pd_series_list = []
              with open(csv_file, 'r') as csv_h:
                  # Read in each line as a list of pandas series
                  for line in csv_h.readlines():
                      # Skip commentary lines
                      if line.startswith("#"):
                          continue

                      # Append line to series
                      pd_series_list.append(pd.Series({metric_col: line_element_value
                                            for metric_col, line_element_value in zip(METRICS_COLUMNS, line.strip().split(","))}))

              metrics_df = pd.DataFrame(pd_series_list)

              metrics_as_dict = {}

              # Rename metrics name column
              metrics_df["metrics_name"] = metrics_df["metrics_name"].apply(lambda x: re.sub(" |/", "", x.title()))

              # Group by metrics_name column
              for metrics_name, metrics_name_df in metrics_df.groupby(["metrics_name"]):
                  # Iterate through the metrics
                  this_metrics_list = []

                  # Work over each line
                  for index, row in metrics_name_df.iterrows():
                      this_metrics_list.append(get_series_as_dict(row))

                  metrics_as_dict[metrics_name] = this_metrics_list

              return metrics_as_dict

          def make_metrics_dict(file_path_list: List[Path]) -> dict:
              """
              Read in each metrics file and output dict
              :param file_path_list:
              :return:
              """
              # make the metrics dictonary
              metrics_dict = {}
              for file_path in file_path_list:
                  metrics_dict.update(make_metric_dict(file_path))
              return metrics_dict

          def main():
              # Get args
              args = get_args()

              # Get the list of file paths
              metrics_file_list: List[Path] = [Path(metrics_file) for
                                               metrics_file in chain(*args.csv_metrics_file)]

              # Get the output prefix
              output_prefix = args.output_prefix

              # Get the output json file name
              output_json_gz = output_prefix + '.AlignCollapseFusionCaller_metrics.json.gz'

              # Get the dict
              sample_metrics_dict = make_metrics_dict(metrics_file_list)

              # Write out dict through json
              with gzip.open(output_json_gz, 'wt', encoding='ascii') as gzip_h:
                  json.dump(sample_metrics_dict, gzip_h)


          if __name__ == "__main__":
              main()


baseCommand: [ "python3", "align_collapse_fusion_caller_csv_metrics_to_json.py" ]

inputs:
  output_prefix:
    label: output_prefix
    doc: |
      Required, output file is then <this>.AlignCollapseFusionCaller_metrics.json.gz
    type: string?
    inputBinding:
      position: 1
      prefix: "--output-prefix"
  csv_metrics_files:
    label: csv metrics files
    doc: |
      The list of csv metrics files file
    type:
      - type: array
        items: File
        inputBinding:
          prefix: "--csv-metrics-file="
          separate: false
          valueFrom: |
            ${
              return self.path
            }

outputs:
  metrics_json_gz_out:
    label: metrics json gz out
    doc: |
      Output file in compressed json gz format
    type: File
    outputBinding:
      glob: "$(inputs.output_prefix).AlignCollapseFusionCaller_metrics.json.gz"

successCodes:
  - 0
