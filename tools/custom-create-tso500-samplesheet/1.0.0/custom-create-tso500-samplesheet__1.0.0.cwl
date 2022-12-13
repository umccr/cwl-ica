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
id: custom-create-tso500-samplesheet--1.0.0
label: custom-create-tso500-samplesheet v(1.0.0)
doc: |
    Given a v2 samplesheet updates the [<SampleSheet_Prefix"_Data] section to include the 'Sample_Type' and 'Pair_ID' attributes

hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: small
        coresMin: 2
        ramMin: 4000
    DockerRequirement:
        dockerPull: ghcr.io/umccr/alpine-pandas:1.2.2

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/tso500-sample/1.0.0/tso500-sample__1.0.0.yaml
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: create-tso500-samplesheet.py
        entry: |
          #!/usr/bin/env python3

          """
          Take in a samplesheet,

          """

          # Imports
          import re
          import pandas as pd
          import logging
          import argparse
          from pathlib import Path
          import sys
          import json

          # Set logging level
          logging.basicConfig(level=logging.DEBUG)

          # Globals
          SAMPLESHEET_HEADER_REGEX = r"^\[(\S+)\](,+)?"  # https://regex101.com/r/5nbe9I/1
          VALID_CTTSO_INDEX_PAIR = ["TCCGGAGA", "CCTATCCT"]


          def get_args():
              """
              Get arguments for the command
              """
              parser = argparse.ArgumentParser(description="Create a tso500 samplesheet based on sample name and type")

              # Arguments
              parser.add_argument("--samplesheet-csv", required=True,
                                  help="Path to samplesheet csv")
              parser.add_argument("--samplesheet-prefix", required=True,
                                  help="Data and Settings prefix sections to update")
              parser.add_argument("--out-file", required=True,
                                  help="Output modified sample sheet name")
              parser.add_argument("--tso500-samples", action="append", nargs='*', required=True,
                                  default=[],
                                  help="tso500 sample objects")
              parser.add_argument("--coerce-valid-index", action='store_true', default=False, required=False,
                                  help="Overwrite index1 and index2 in samplesheet as valid ctTSO indexes")

              return parser.parse_args()


          def set_args(args):
              """
              # File checks
              Check samplesheet input is a file
              Create directory for out-file if required.

              # Array checks
              Check sample-types are
              :return:
              """

              # Get user args
              samplesheet_csv_arg = getattr(args, "samplesheet_csv", None)
              out_file_arg = getattr(args, "out_file", None)
              tso500_samples_arg = getattr(args, "tso500_samples", [])

              # Convert samplesheet csv to path
              samplesheet_csv_path = Path(samplesheet_csv_arg)
              if not samplesheet_csv_path.is_file():
                  logging.error("Sample sheet file was not found at {}".format(samplesheet_csv_arg))
                  sys.exit(1)

              # Convert out_file to path
              out_file_path = Path(out_file_arg)

              # Check if parent is directory, create otherwise
              if not out_file_path.parent.is_dir():
                  out_file_path.parent.mkdir()

              # Set path args
              setattr(args, "samplesheet_csv_path", samplesheet_csv_path)
              setattr(args, "out_file_path", out_file_path)

              # Load json lists
              tso500_samples_list = []
              for tso500_samples in tso500_samples_arg:
                  tso500_samples_list.append(json.loads(tso500_samples[0]))

              # Make sure no two samples have the same sample_id or sample_name attribute
              if not len(list(set([sample.get("sample_id") for sample in tso500_samples_list]))) == len(tso500_samples_list):
                  logger.error("It appears multiple samples have matching sample ids")
                  sys.exit(1)

              if not len(list(set([sample.get("sample_name") for sample in tso500_samples_list]))) == len(tso500_samples_list):
                  logger.error("It appears multiple samples have matching sample names")
                  sys.exit(1)

              setattr(args, "tso500_samples_list", tso500_samples_list)

              return args


          def read_samplesheet_csv(samplesheet_csv_path):
              """
              Read the samplesheet like a dodgy INI parser
              :param samplesheet_csv_path:
              :return:
              """
              with open(samplesheet_csv_path, "r") as samplesheet_csv_h:
                  # Read samplesheet in
                  sample_sheet_sections = {}
                  current_section = None
                  current_section_item_list = []
                  header_match_regex = re.compile(SAMPLESHEET_HEADER_REGEX)

                  for line in samplesheet_csv_h.readlines():
                      # Check if blank line
                      if line.strip().rstrip(",") == "":
                          continue
                      # Check if the current line is a header
                      header_match_obj = header_match_regex.match(line.strip())
                      if header_match_obj is not None and current_section is None:
                          # First line, don't need to write out previous section to obj
                          # Set current section to first group
                          current_section = header_match_obj.group(1)
                          current_section_item_list = []
                      elif header_match_obj is not None and current_section is not None:
                          # A header further down, write out previous section and then reset sections
                          sample_sheet_sections[current_section] = current_section_item_list
                          # Now reset sections
                          current_section = header_match_obj.group(1)
                          current_section_item_list = []
                      # Make sure the first line is a section
                      elif current_section is None and header_match_obj is None:
                          logging.error("Top line of csv was not a section header. Exiting")
                          sys.exit(1)
                      else:  # We're in a section
                          if not current_section == "Data":
                              # Strip trailing slashes from line
                              current_section_item_list.append(line.strip().rstrip(","))
                          else:
                              # Don't strip trailing slashes from line
                              current_section_item_list.append(line.strip())

                  # Write out the last section
                  sample_sheet_sections[current_section] = current_section_item_list

                  return sample_sheet_sections


          def configure_samplesheet_obj(samplesheet_obj):
              """
              Each section of the samplesheet obj is in a ',' delimiter ini format
              Except for [Reads] which is just a list
              And [Data] which is a dataframe
              :param samplesheet_obj:
              :return:
              """

              for section_name, section_str_list in samplesheet_obj.items():
                  if section_name.endswith("Data"):
                      # Convert to dataframe
                      samplesheet_obj[section_name] = pd.DataFrame(columns=section_str_list[0].split(","),
                                                                   data=[row.split(",") for row in
                                                                         section_str_list[1:]])
                  elif section_name == "Reads":
                      # Keep as a list
                      continue
                  else:
                      # Convert to dict
                      samplesheet_obj[section_name] = {line.split(",", 1)[0]: line.split(",", 1)[-1]
                                                       for line in section_str_list
                                                       if not line.split(",", 1)[0] == ""}
                      # Check all values are non empty
                      for key, value in samplesheet_obj[section_name].items():
                          if value == "" or value.startswith(","):
                              logging.error("Could not parse key \"{}\" in section \"{}\"".format(key, section_name))
                              logging.error("Value retrieved was \"{}\"".format(value))
                              sys.exit(1)

              return samplesheet_obj


          def truncate_sample_sheet_to_sample_ids(samplesheet_obj, samples, samplesheet_prefix, coerce_valid_index=False):
              """
              Truncate the sample sheet to the sample names in --sample-names
              Parameters
              ----------
              samplesheet_obj
              samples

              Returns
              -------

              """
              sample_ids_array = [item.get('sample_id') for item in samples] # Used in the query statement below

              samplesheet_obj[f"{samplesheet_prefix}_Data"] = samplesheet_obj[f"{samplesheet_prefix}_Data"].query("Sample_ID in @sample_ids_array")

              if coerce_valid_index and samplesheet_obj[f"{samplesheet_prefix}_Data"].shape[0] == 1:
                samplesheet_obj[f"{samplesheet_prefix}_Data"]["index"] = VALID_CTTSO_INDEX_PAIR[0]
                samplesheet_obj[f"{samplesheet_prefix}_Data"]["index2"] = VALID_CTTSO_INDEX_PAIR[1]

              # Check dataframe is not empty
              if samplesheet_obj[f"{samplesheet_prefix}_Data"].shape[0] == 0:
                  logging.error("Could not find any of {} in the sample sheet, exiting".format(", ".join(sample_ids_array)))
                  sys.exit(1)

              return samplesheet_obj


          def add_sample_type_and_pair_id_to_sample_sheet(samplesheet_obj, samples, samplesheet_prefix):
              """
              Adds the Sample_Type and Pair_ID to each Sample_ID value
              Parameters
              ----------
              samplesheet_obj
              samples

              Returns
              -------

              """

              sample_sheet_df = samplesheet_obj[f"{samplesheet_prefix}_Data"]
              sample_sheet_dfs = []

              for sample_id, sample_df in sample_sheet_df.groupby("Sample_ID"):
                  sample = [sample
                            for sample in samples if sample.get('sample_id') == sample_id
                           ][0]
                  sample_df["Sample_Type"] = sample.get('sample_type')
                  sample_df["Pair_ID"] = sample.get('pair_id')

                  sample_sheet_dfs.append(sample_df)

              # Concatenate back together
              sample_sheet_df = pd.concat(sample_sheet_dfs, axis="rows")
              samplesheet_obj[f"{samplesheet_prefix}_Data"] = sample_sheet_df

              return samplesheet_obj


          def write_samplesheet(samplesheet_obj, output_file):
              """
              Write out the samplesheet object and a given file
              :param samplesheet_obj:
              :param output_file:
              :return:
              """

              # Write the output file
              with open(output_file, 'w') as samplesheet_h:
                  for section, section_values in samplesheet_obj.items():
                      # Write out the section header
                      samplesheet_h.write("[{}]\n".format(section))
                      # Write out values
                      if type(section_values) == list:  # [Reads] for v1 samplesheets
                          # Write out each item in a new line
                          samplesheet_h.write("\n".join(section_values))
                      elif type(section_values) == dict:
                          samplesheet_h.write("\n".join(map(str, ["{},{}".format(key, value)
                                                                  for key, value in section_values.items()])))
                      elif type(section_values) == pd.DataFrame:
                          section_values.to_csv(samplesheet_h, index=False, header=True, sep=",")
                      # Add new line before the next section
                      samplesheet_h.write("\n\n")


          def main():
              # Get args
              args = get_args()

              # Check / set args
              logging.info("Checking args")
              args = set_args(args=args)

              # Read config
              logging.info("Reading samplesheet")
              samplesheet_obj = read_samplesheet_csv(samplesheet_csv_path=args.samplesheet_csv)

              # Configure samplesheet
              logging.info("Configuring samplesheet")
              samplesheet_obj = configure_samplesheet_obj(samplesheet_obj)

              # Truncate sample sheet
              logging.info("Truncating samplesheet")
              samplesheet_obj = truncate_sample_sheet_to_sample_ids(samplesheet_obj=samplesheet_obj,
                                                                    samples=args.tso500_samples_list,
                                                                    samplesheet_prefix=args.samplesheet_prefix,
                                                                    coerce_valid_index=args.coerce_valid_index)

              # Append Sample Type and Pair ID
              logging.info("Adding sample type and pair id columns to sample sheet")
              samplesheet_obj = add_sample_type_and_pair_id_to_sample_sheet(samplesheet_obj=samplesheet_obj,
                                                                            samples=args.tso500_samples_list,
                                                                            samplesheet_prefix=args.samplesheet_prefix)

              # Write out sample sheet
              logging.info("Writing out sample sheet")
              write_samplesheet(samplesheet_obj=samplesheet_obj,
                                output_file=args.out_file)


          if __name__ == "__main__":
              main()


baseCommand: [ "python", "create-tso500-samplesheet.py" ]


inputs:
  samplesheet:
    label: samplesheet
    doc: |
      The v2 samplesheet used for demultiplexing the tso500 samples with
    type: File
    inputBinding:
      prefix: "--samplesheet-csv"
  samplesheet_prefix:
    label: samplesheet_prefix
    doc: |
      The samplesheet prefix for v2 samplesheets
    type: string?
    default: "TSO500L"
    inputBinding:
      prefix: "--samplesheet-prefix"
  coerce_valid_index:
    label: coerce valid index
    doc: |
      Coerce a valid index for ctTSO sample
    type: boolean?
    default: false
    inputBinding:
      prefix: "--coerce-valid-index"
  tso500_samples:
    label: tso500 samples
    doc: |
      The tso500 sample objects
    type:
      - type: array
        items: ../../../schemas/tso500-sample/1.0.0/tso500-sample__1.0.0.yaml#tso500-sample
        inputBinding:
          prefix: "--tso500-samples="
          separate: false
          valueFrom: |
            ${
              return JSON.stringify(self);
            }
  out_file:
    label: output file name
    doc: |
      Set to samplesheet.tso500.csv by default
    type: string?
    default: "SampleSheet.TSO500.csv"
    inputBinding:
      prefix: "--out-file"

outputs:
  tso500_samplesheet:
    label: tso500 samplesheet
    doc: |
      The updated samplesheet with the Sample_Type and Pair_ID columns in the Data section
    type: File
    outputBinding:
      glob: "$(inputs.out_file)"

successCodes:
  - 0
