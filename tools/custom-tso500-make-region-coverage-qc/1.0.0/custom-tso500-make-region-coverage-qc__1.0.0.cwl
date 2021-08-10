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

# TODO - link to original git repo

s:maintainer:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: custom-tso500-make-region-coverage-qc--1.0.0
label: custom-tso500-make-region-coverage-qc v(1.0.0)
doc: |
    Documentation for custom-tso500-make-region-coverage-qc
    v1.0.0

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
      - var get_output_file_prefix = function(){
          /*
          Get the output file prefix name if specified - otherwise just use the qc file nameroot
          */
          if (inputs.prefix !== null){
            return inputs.prefix;
          } else {
            return inputs.threshold_bed_file.nameroot;
          }
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: "target_region_coverage_metrics.py"
        entry: |
          #!/usr/bin/env python3

          import pandas as pd
          import re
          import argparse
          import gzip
          from pathlib import Path
          from typing import TextIO

          """
          Calculate consensus reads coverage metrics
          """

          def get_args() -> argparse.Namespace:
              """
              Get arguments for the command
              :return: args
              """
              parser = argparse.ArgumentParser(description="From mosdepth threshold.bed to make consensus reads coverage on "
                                                           "target region (TargetRegionCoverage.tsv)")

              # List args
              parser.add_argument("-i", "--input-bed", required=True,
                                  help="Mosdepth output file 'threshold.bed.gz'")
              parser.add_argument("-p", "--output-prefix", required=False,
                                  help='output prefix for the file')

              # Return args
              return parser.parse_args()


          def get_region_coverage_df(coverage_df: pd.DataFrame) -> pd.DataFrame:
              """
              Read in the per-exon coverage df and
              :param coverage_df:
              :return: region_coverage_df
              """

              # Get passing threshold
              region_coverage_df = pd.DataFrame(data=[["TargetRegion", coverage_df['length'].sum(), "100%"]],
                                                columns=["ConsensusReadDepth", "BasePair", "Percentage"])

              # Get coverage columns
              coverage_cols = [col for col in coverage_df if re.match("\d+X", col) is not None]

              for coverage_col in coverage_cols:
                  region_coverage_df = region_coverage_df.append({
                      "ConsensusReadDepth": coverage_col,
                      "BasePair": coverage_df[coverage_col].sum(),
                      "Percentage": format(100.0 * coverage_df[coverage_col].sum() / coverage_df['length'].sum(), '.2f')
                  }, ignore_index=True)

              return region_coverage_df


          def write_out_region_coverage_file(region_coverage_df: pd.DataFrame, file_handler: TextIO):
              """
              Write out the tsv file
              :param region_coverage_df:
              :param file_handler:
              :return:
              """
              region_coverage_df.to_csv(file_handler, sep="\t", index=False)


          def main():
              """
              Generate TargetRegionCoverage.tsv
              """

              # Get / Check args
              args = get_args()
              if not args.output_prefix:
                  output_prefix = Path(args.input_bed).name.rsplit('.', 1)[0]
              else:
                  output_prefix = args.output_prefix

              # Set output coverage name
              coverage_output_tsv = Path(output_prefix + ".TargetRegionCoverage.tsv")

              # Open up gzip file
              with gzip.open(args.input_bed, 'rb') as gzip_h:
                  coverage_df = pd.read_csv(gzip_h, sep='\t', header=0)

              # Get the coverage length column
              coverage_df['length'] = coverage_df.apply(lambda x: x['end'] - x['start'], axis="columns")

              # Get the per depth metrics
              region_coverage_df = get_region_coverage_df(coverage_df)

              # write results to file
              with open(coverage_output_tsv, 'w') as output_h:
                  write_out_region_coverage_file(region_coverage_df, output_h)


          if __name__ == "__main__":
              main()


baseCommand: [ "python3", "target_region_coverage_metrics.py" ]

arguments:
  # Set the output_prefix
  - prefix: "--output-prefix"
    valueFrom: "$(get_output_file_prefix())"

inputs:
  threshold_bed_file:
    label: threshhold bed file
    doc: |
      Output from mosdepth
    type: File
    inputBinding:
      prefix: "--input-bed"
  prefix:
    label: prefix
    doc: |
      Output prefix of the file
    type: string?

outputs:
  target_region_coverage_metrics:
    label: target region coverage metrics
    doc: |
      Trans region output per target coverage threshold
    type: File
    outputBinding:
      glob: "$(get_output_file_prefix()).TargetRegionCoverage.tsv"

successCodes:
  - 0
