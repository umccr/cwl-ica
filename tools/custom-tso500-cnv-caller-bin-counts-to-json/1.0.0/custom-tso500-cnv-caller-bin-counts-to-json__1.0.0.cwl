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
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: custom-tso500-cnv-caller-bin-counts-to-json--1.0.0
label: custom-tso500-cnv-caller-bin-counts-to-json v(1.0.0)
doc: |
    Documentation for custom-tso500-cnv-caller-bin-counts-to-
    json v1.0.0

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
      - entryname: cnv_caller_bin_counts_to_json.py
        entry: |
          #!/usr/bin/env python3
          
          # Imports
          import pandas as pd
          import json
          import argparse
          import gzip
          from typing import List, Dict
          from argparse import Namespace
          from pathlib import Path
          from itertools import chain
          
          
          # Globals
          def get_args() -> Namespace:
              """
              Get all the expected metrics files
              :return: args
              """
              parser = argparse.ArgumentParser(description='Convert CnvCaller/*bin.tsv to json')
          
              # add Arguments
              parser.add_argument('--tsv-bin-file', action="append", nargs='*', required=True,
                                  help="List of tsv bin files")
              parser.add_argument('--output-prefix', required=False,
                                  help='Output prefix of the output file')
          
              return parser.parse_args()
          
          
          def make_bin_dict(bin_file_paths: List[Path]) -> Dict:
              bin_dict = {}
          
              for file_path in bin_file_paths:
                  df = pd.read_csv(file_path, sep="\t", header=0)
                  if file_path.name.endswith("_rawBinCount.tsv"):
                      bin_dict["rawBinCount"] = json.loads(df.to_json(orient="records"))
                  elif file_path.name.endswith("_normalizedBinCount.tsv"):
                      bin_dict["normalizedBinCount"] = json.loads(df.to_json(orient="records"))
                  else:
                      # Not sure how we got here
                      continue
          
              return bin_dict
          
          
          def main():
              # Get args
              args = get_args()
          
              # Get the list of file paths
              metrics_file_list: List[Path] = [
                  Path(metrics_file)
                  for metrics_file in chain(*args.tsv_bin_file)
              ]
          
              # Get the output prefix
              output_prefix = args.output_prefix
          
              # Get the output json file name
              output_json_gz = output_prefix + '.CnvCallerBinCounts.json.gz'          
              # Get the dict
              bin_dict = make_bin_dict(metrics_file_list)
          
              # Write out dict through json
              with gzip.open(output_json_gz, 'wt', encoding='ascii') as gzip_h:
                  json.dump(bin_dict, gzip_h)
          
          
          if __name__ == "__main__":
              main()


baseCommand: [ "python3", "cnv_caller_bin_counts_to_json.py" ]

inputs:
  output_prefix:
    label: output_prefix
    doc: |
      Required, output file is then <this>.CnvCallerBinCounts.json.gz
    type: string?
    inputBinding:
      position: 1
      prefix: "--output-prefix"
  tsv_bin_count_files:
    label: csv metrics files
    doc: |
      The list of csv metrics files file
    type:
      - type: array
        items: File
        inputBinding:
          prefix: "--tsv-bin-file="
          separate: false
          valueFrom: |
            ${
              return self.path
            }

outputs:
  bin_counts_gz_out:
    label: metrics json gz out
    doc: |
      Output file in compressed json gz format
    type: File
    outputBinding:
      glob: "$(inputs.output_prefix).CnvCallerBinCounts.json.gz"

successCodes:
  - 0
