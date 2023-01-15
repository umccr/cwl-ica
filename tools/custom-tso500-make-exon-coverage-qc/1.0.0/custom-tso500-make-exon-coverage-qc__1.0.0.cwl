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
id: custom-tso500-make-exon-coverage-qc--1.0.0
label: custom-tso500-make-exon-coverage-qc v(1.0.0)
doc: |
    Using the thresholds output from mosdepth, take in a tab delimited file of compressions and
    reduce to those exons who've failed a fixed level of coverage.
    The output of this cwl tool contains a header that is compatible with uploading the file to Pieriandx
    Original CWL file [here](https://github.com/YinanWang16/tso500-ctdna-post-processing/blob/main/cwl/tools/mosdepth/mosdepth-thresholds-bed-to-coverage-QC-step.cwl)


# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
    ResourceRequirement:
        ilmn-tes:resources/tier: standard
        ilmn-tes:resources/type: standard
        ilmn-tes:resources/size: medium
        coresMin: 1
        ramMin: 4000
    DockerRequirement:
        dockerPull: ghcr.io/umccr/alpine-pandas:1.2.2

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
        - entryname: thresholds-bed-to-coverage-qc.py
          entry: |
            #!/usr/bin/env python3

            """
            Generate Failed_Exon_coverage_QC.txt
            """

            # Standard imports
            import pandas as pd
            import re
            import argparse
            import gzip
            from pathlib import Path
            from typing import TextIO

            # Globals
            FILE_HEADER="Level 2: 100x coverage for > 50% of positions was not achieved for the targeted exon regions listed below:"

            # Helper functions
            def get_args() -> argparse.Namespace:
                """
                Get arguments for the command
                :return: args
                """
                parser = argparse.ArgumentParser(description="From mosdepth output 'shreshold.bed' to generate 'Failed_Exon_coverage_QC.txt' for PierianDx CGW")

                # List args
                parser.add_argument("-i", "--input-bed", required=True,
                                    help="Mosdepth output file 'threshold.bed.gz'")
                parser.add_argument("-p", "--output-prefix", required=False,
                                    help="File output prefix")

                # Return args
                return parser.parse_args()


            def filter_coverage_df(coverage_df: pd.DataFrame) -> pd.DataFrame:
                """
                Apply column additions and filtering of the coverage dataframe
                :param coverage_df:
                :return:
                """

                # Get length of regions
                coverage_df['length'] = coverage_df.apply(lambda x: x['end'] - x['start'], axis='columns')

                # Get Percentage of region in '100'
                coverage_df['pct_100X'] = coverage_df.apply(lambda x: round((100.0 * x['100X']) / x['length'], 1), axis='columns')

                # Filter out regions where pct_100X > 50
                coverage_df.query("pct_100X <= 50", inplace=True)

                # Get name from bed region
                coverage_df['region_name_len'] = coverage_df['region'].apply(lambda x: len(x.split("_")))

                # Filter out regions where region doesn't conform to '<gene>_<exon>_<transcript>' nomenclature
                coverage_df.query("region_name_len >= 3", inplace=True)

                # Split 'region' into '<gene>_<exon>_<transcript>'
                coverage_df[["gene_id", "exon_id", "transcript_id"]] = coverage_df["region"].str.split("_", 2, expand=True)

                # Filter out regions that aren't refseq transcripts
                coverage_df.query("transcript_id.str.startswith('NM')", inplace=True)

                # Get 250X as a percentage
                coverage_df["pct_250X"] = coverage_df.apply(lambda x: round((100.0 * x['250X']) / x['length'], 1), axis='columns')

                # Strip Exon or Intron from the start of the ID
                coverage_df["exon_id"] = coverage_df["exon_id"].apply(lambda x: re.sub("^(Exon|Intron)", "", x))

                return coverage_df


            def write_out_coverage_file(coverage_df: pd.DataFrame, file_handler: TextIO):
                """
                Write out the coverage file to the file handler
                :param coverage_df:
                :param file_handler:
                :return:
                """
                coverage_df.rename(columns={
                    "region": "index",
                    "gene_id": "gene",
                    "transcript_id": "transcript_acc",
                    "pct_100X": "GE100",
                    "pct_250X": "GE250"
                })[["index", "gene", "transcript_acc", "exon_id", "GE100", "GE250"]].to_csv(file_handler, sep="\t", index=False)


            def main():
                """
                Generate Failed_Exon_coverage_QC.txt
                """

                # Get / Check args
                args = get_args()
                if not args.output_prefix:
                    output_prefix = Path(args.input_bed).name.rsplit('.', 1)[0]
                else:
                    output_prefix = args.output_prefix

                # Open up gzip file
                with gzip.open(args.input_bed, 'rb') as gzip_h:
                    coverage_df = pd.read_csv(gzip_h, sep='\t', header=0)

                # Set output coverage name
                coverage_output_tsv = Path(output_prefix + '_Failed_Exon_coverage_QC.txt')

                coverage_df = filter_coverage_df(coverage_df)

                # define header of the file
                with open(coverage_output_tsv.name, 'w') as output_h:
                    output_h.write(FILE_HEADER + "\n")
                    write_out_coverage_file(coverage_df, output_h)


            if __name__ == "__main__":
                main()


baseCommand: ["python3", "thresholds-bed-to-coverage-qc.py" ]

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
  failed_coverage_txt:
    label: failed qc coverage txt
    doc: |
      The Failed QC exon coverage output file ready for upload to PierianDx
    type: File
    outputBinding:
      glob: "$(get_output_file_prefix())_Failed_Exon_coverage_QC.txt"


successCodes:
  - 0
