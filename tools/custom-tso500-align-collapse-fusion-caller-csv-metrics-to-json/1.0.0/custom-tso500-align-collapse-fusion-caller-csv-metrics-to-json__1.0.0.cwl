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
        ramMin: 4000
    DockerRequirement:
        dockerPull: ghcr.io/umccr/alpine-pandas:1.2.2

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: align_collapse_fusion_caller_csv_metrics_to_json.py
        entry: |
          #!/usr/bin/env python3

          # Imports
          import pandas as pd
          import json
          import re
          import argparse
          import gzip
          from typing import List, Dict
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


          def get_series_as_dict(row: pd.Series) -> Dict:
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


          def get_metric_df(file_path: Path) -> pd.DataFrame:
              """
              Get the metric file as a dataframe
              Since all lines do not necessarily conform to having the same number of columns,
              we cannot use the read_csv tool and instead assign each line as a pandas series, line by line!
              :param file_path:
              :return:
              """
              # Read csv file
              pd_series_list = []
              with open(file_path, 'r') as csv_h:
                  # Read in each line as a list of pandas series
                  for line in csv_h.readlines():
                      # Skip commentary lines
                      if line.startswith("#"):
                          continue

                      # Append line to series
                      pd_series_list.append(pd.Series({metric_col: line_element_value
                                                       for metric_col, line_element_value in
                                                       zip(METRICS_COLUMNS, line.strip().split(","))}))

              return pd.DataFrame(pd_series_list)


          def make_metric_dict(file_path: Path) -> Dict:
              """
              Add in metrics dictionary
              Since all lines do not necessarily conform to having the same number of columns,
              we cannot use the read_csv tool and instead assign each line as a pandas series, line by line!
              :param csv_file:
              :return:
              """
              # Get metrics df
              if file_path.name.endswith(".fastqc_metrics.csv"):
                  metrics_df = pd.read_csv(file_path, header=None, names=METRICS_COLUMNS)
                  metrics_df['descriptive_name'] = metrics_df.apply(
                      lambda x: x.place_holder + " " + x.descriptive_name,
                      axis='columns'
                  )
              else:
                  metrics_df = get_metric_df(file_path)

              # Collect metrics as dict
              metrics_as_dict = {}

              # Rename metrics name column
              metrics_df["metrics_name"] = metrics_df["metrics_name"].apply(lambda x: re.sub(" |/", "", x.title()))

              # Group by metrics_name column
              for metrics_name, metrics_name_df in metrics_df.groupby("metrics_name"):
                  # Iterate through the metrics
                  this_metrics_list = []

                  # Work over each line
                  for index, row in metrics_name_df.iterrows():
                      this_metrics_list.append(get_series_as_dict(row))

                  metrics_as_dict[metrics_name] = this_metrics_list

              return metrics_as_dict
          
          def make_fragment_length_hist(file_path) -> Dict:
              """
              #Sample: PRJ210166_L2101400
              FragmentLength,Count
              32,1
              33,0
              34,0
              35,0
              36,3
              37,2
              38,3
              39,2
              """
              hist_json = pd.read_csv(
                  file_path,
                  header=0,
                  comment='#'
              ).to_json(
                  orient="records"
              )

              return json.loads(hist_json)
          
          def make_wgs_overall_mean_cov(file_path) -> Dict:
              """
              This file only has one line in it
              Average alignment coverage over wgs, 9.82
              :param file_path:
              :return:
              """
              # Average alignment coverage over wgs, 9.82
              with open(file_path, 'r') as contig_h:
                  key, value = contig_h.read().rstrip().split(",")

              return {
                  key: value
              }


          def make_wgs_contig_mean_cov_dict(file_path) -> Dict:
              """
              # Indexed not like othe rfiles
              chr1,2474321537,10.9833
              chr2,1911660869,8.02529
              :param file_path:
              :return:
              """
              mean_cov_json = pd.read_csv(
                  file_path,
                  header=None,
                  names=["contig", "bases_cov", "mean_cov"]
              ).to_json(
                  orient="records"
              )

              return json.loads(mean_cov_json)


          def make_wgs_fine_hist_dict(file_path: Path) -> Dict:
              """
              Csv looks like the following
              Depth,Overall
              0,2056333599
              1,228370278
              2,431359784
              :param file_path:
              :return:
              """
              hist_json = pd.read_csv(
                  file_path,
                  header=0,
              ).to_json(
                  orient="records"
              )

              return json.loads(hist_json)


          def make_wgs_hist_dict(file_path: Path) -> Dict:
              """
              Csv looks like the following
              PCT of bases in wgs with coverage [100x:inf), 0.18
              PCT of bases in wgs with coverage [50x:100x), 0.04
              PCT of bases in wgs with coverage [20x:50x), 0.11
              PCT of bases in wgs with coverage [15x:20x), 0.06
              PCT of bases in wgs with coverage [10x:15x), 0.15
              PCT of bases in wgs with coverage [3x:10x), 5.81
              PCT of bases in wgs with coverage [1x:3x), 22.75
              PCT of bases in wgs with coverage [0x:1x), 70.91
              :param file_path:
              :return:
              """
              hist_json = pd.read_csv(
                  file_path,
                  header=None,
                  names=["descriptive_name", "value"]
              ).to_json(
                  orient="records"
              )

              return json.loads(hist_json)


          def make_metrics_dict(file_path_list: List[Path]) -> Dict:
              """
              Read in each metrics file and output dict
              :param file_path_list:
              :return:
              """
              # make the metrics dictonary
              metrics_dict = {}
              for file_path in file_path_list:
                  if file_path.name.endswith(".fragment_length_hist.csv"):
                      metrics_dict["FragmentLengthHist"] = make_fragment_length_hist(file_path)
                  elif file_path.name.endswith(".wgs_fine_hist.csv"):
                      metrics_dict["WgsFineHist"] = make_wgs_fine_hist_dict(file_path)
                  elif file_path.name.endswith(".wgs_contig_mean_cov.csv"):
                      metrics_dict["WgsContigMeanCov"] = make_wgs_contig_mean_cov_dict(file_path)
                  elif file_path.name.endswith(".wgs_hist.csv"):
                      metrics_dict["WgsHist"] = make_wgs_hist_dict(file_path)
                  elif file_path.name.endswith(".wgs_overall_mean_cov.csv"):
                      metrics_dict["WgsOverallMeanCov"] = make_wgs_overall_mean_cov(file_path)
                  else:
                      metrics_dict.update(make_metric_dict(file_path))
              return metrics_dict


          def main():
              # Get args
              args = get_args()

              # Get the list of file paths
              metrics_file_list: List[Path] = [
                  Path(metrics_file)
                  for metrics_file in chain(*args.csv_metrics_file)
              ]

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
