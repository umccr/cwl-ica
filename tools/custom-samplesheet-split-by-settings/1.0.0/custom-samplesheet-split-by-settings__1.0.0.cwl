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
    s:name: Sehrish Kanwal
    s:email: sehrish.kanwal@umccr.org

# ID/Docs
id: custom-samplesheet-split-by-settings--1.0.0
label: custom-samplesheet-split-by-settings v(1.0.0)
doc: |
  Use before running bcl-convert workflow to ensure that the bclConvert workflow can run in parallel.
  Samples will be split into separate samplesheets based on their cycles specification

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: standard
    ilmn-tes:resources/size: small
    coresMin: 2
    ramMin: 4000
  DockerRequirement:
    dockerPull: ghcr.io/umccr/alpine-pandas:1.2.2

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/settings-by-samples/1.0.0/settings-by-samples__1.0.0.yaml
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: samplesheet-by-settings.py
        entry: |
          #!/usr/bin/env python3

          """
          Take in a samplesheet,
          Look through headers, rename as necessary
          Look through samples, update settings logic as necessary
          Split samplesheet out into separate settings files
          Write to separate files
          If --samplesheet-format is set to v2 then:
          * rename Settings.Adapter to Settings.AdapterRead1
          * Reduce Data to the columns Lane, Sample_ID, index, index2, Sample_Project
          * Add FileFormatVersion=2 to Header
          * Convert Reads from list to dict with Read1Cycles and Read2Cycles as keys
          """

          # Imports
          import re
          import os
          import pandas as pd
          import numpy as np
          import logging
          import argparse
          from pathlib import Path
          import sys
          from copy import deepcopy
          import json

          # Set logging level
          logging.basicConfig(level=logging.DEBUG)

          # Globals
          SAMPLESHEET_HEADER_REGEX = r"^\[(\S+)\](,+)?"  # https://regex101.com/r/5nbe9I/1
          V2_SAMPLESHEET_HEADER_VALUES = {"Data": "BCLConvert_Data",
                                          "Settings": "BCLConvert_Settings"}
          V2_FILE_FORMAT_VERSION = "2"
          V2_DEFAULT_INSTRUMENT_TYPE = "NovaSeq 6000"


          def get_args():
              """
              Get arguments for the command
              """
              parser = argparse.ArgumentParser(description="Create samplesheets based on settings inputs."
                                                           "Expects a v1 samplesheet as input and settings by samples"
                                                           "as inputs through separated jsonised strings / arrays")

              # Arguments
              parser.add_argument("--samplesheet-csv", required=True,
                                  help="Path to v1 samplesheet csv")
              parser.add_argument("--out-dir", required=False,
                                  help="Output directory for samplesheets, set to cwd if not specified")
              parser.add_argument("--settings-by-samples", action="append", nargs='*', required=False,
                                  default=[],
                                  help="Settings logic for each sample")
              parser.add_argument("--ignore-missing-samples", required=False,
                                  default=False, action="store_true",
                                  help="If not set, error if samples in the samplesheet are not present in --settings-by-samples arg")
              parser.add_argument("--samplesheet-format", required=False,
                                  choices=["v1", "v2"], default="v1",
                                  help="Type of samplesheet we wish to output")

              return parser.parse_args()


          def set_args(args):
              """
              Convert --settings-by-samples to dict
              :return:
              """

              # Get user args
              samplesheet_csv_arg = getattr(args, "samplesheet_csv", None)
              outdir_arg = getattr(args, "out_dir", None)
              settings_by_samples_arg = getattr(args, "settings_by_samples", [])

              # Convert samplesheet csv to path
              samplesheet_csv_path = Path(samplesheet_csv_arg)
              # Check its a file
              if not samplesheet_csv_path.is_file():
                  logging.error("Could not find file {}".format(samplesheet_csv_path))
                  sys.exit(1)
              # Set attribute as Path object
              setattr(args, "samplesheet_csv", samplesheet_csv_path)

              # Checking the output path
              if outdir_arg is None:
                  outdir_arg = os.getcwd()
              outdir_path = Path(outdir_arg)
              if not outdir_path.parent.is_dir():
                  logging.error("Could not create --out-dir, make sure parents exist. Exiting")
                  sys.exit(1)
              elif not outdir_path.is_dir():
                  outdir_path.mkdir(parents=False)
              setattr(args, "out_dir", outdir_path)

              # Load json lists
              settings_by_samples_list = []
              for settings_by_samples in settings_by_samples_arg:
                  settings_by_samples_list.append(json.loads(settings_by_samples[0]))

              # Set attr as dicts grouped by each batch_name
              settings_by_batch_names = {}
              for settings_by_samples in settings_by_samples_list:
                  # Initialise batch name
                  batch_name_key = settings_by_samples.get("batch_name")
                  settings_by_batch_names[batch_name_key] = {}
                  # Add in sample ids
                  settings_by_batch_names[batch_name_key]["samples"] = settings_by_samples.get("samples")
                  # Add in settings
                  settings_by_batch_names[batch_name_key]["settings"] = settings_by_samples.get("settings")

              # Write attributes back to args dict
              setattr(args, "settings_by_batch_names", settings_by_batch_names)

              # Return args
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


          def configure_samplesheet_obj(sample_sheet_obj):
              """
              Each section of the samplesheet obj is in a ',' delimiter ini format
              Except for [Reads] which is just a list
              And [Data] which is a dataframe
              :param sample_sheet_obj:
              :return:
              """

              for section_name, section_str_list in sample_sheet_obj.items():
                  if section_name == "Data":
                      # Convert to dataframe
                      sample_sheet_obj[section_name] = pd.DataFrame(columns=section_str_list[0].split(","),
                                                                    data=[row.split(",") for row in
                                                                          section_str_list[1:]])
                  elif section_name == "Reads":
                      # Keep as a list
                      continue
                  else:
                      # Convert to dict
                      sample_sheet_obj[section_name] = {line.split(",", 1)[0]: line.split(",", 1)[-1]
                                                        for line in section_str_list
                                                        if not line.split(",", 1)[0] == ""}
                      # Check all values are non empty
                      for key, value in sample_sheet_obj[section_name].items():
                          if value == "" or value.startswith(","):
                              logging.error("Could not parse key \"{}\" in section \"{}\"".format(key, section_name))
                              logging.error("Value retrieved was \"{}\"".format(value))
                              sys.exit(1)

              return sample_sheet_obj


          def lower_under_score_to_camel_case(string):
              """
              Quick script to update a string from "this_type" to "ThisType"
              Necessary for the bclconvert settings to be in camel case
              Parameters
              ----------
              string
              Returns
              -------
              """

              camel_case_string_list = []
              words_list = string.split("_")

              for word in words_list:
                  camel_case_string_list.append(word.title())

              return "".join(map(str, camel_case_string_list))


          def strip_ns_from_indexes(samplesheetobj_data_df):
              """
              Strip Ns from the end of the index and index2 headers
              :param samplesheetobj_data_df:
              :return:
              """

              samplesheetobj_data_df['index'] = samplesheetobj_data_df['index'].apply(lambda x: x.rstrip("N"))
              if 'index2' in samplesheetobj_data_df.columns.tolist():
                  samplesheetobj_data_df['index2'] = samplesheetobj_data_df['index2'].apply(lambda x: x.rstrip("N"))
                  samplesheetobj_data_df['index2'] = samplesheetobj_data_df['index2'].replace("", np.nan)

              return samplesheetobj_data_df


          def rename_settings_and_data_headers_v2(samplesheet_obj):
              """
              :return:
              """

              for v1_key, v2_key in V2_SAMPLESHEET_HEADER_VALUES.items():
                  if v1_key in samplesheet_obj.keys():
                      samplesheet_obj[v2_key] = samplesheet_obj.pop(v1_key)

              return samplesheet_obj


          def add_file_format_version_v2(samplesheet_header):
              """
              Add FileFormatVersion key pair to samplesheet header for v2 samplesheet
              :param samplesheet_header:
              :return:
              """

              samplesheet_header['FileFormatVersion'] = V2_FILE_FORMAT_VERSION

              return samplesheet_header


          def set_instrument_type(samplesheet_header):
              """
              Fix InstrumentType if it's not specified
              :param samplesheet_header:
              :return:
              """

              if "InstrumentType" not in samplesheet_header.keys():
                  samplesheet_header["InstrumentType"] = V2_DEFAULT_INSTRUMENT_TYPE

              return samplesheet_header


          def update_settings_v2(samplesheet_settings):
              """
              Convert Adapter To AdapterRead1 for v2 samplesheet
              :param samplesheet_settings:
              :return:
              """

              # Rename Adapter to AdapterRead1
              if "Adapter" in samplesheet_settings.keys() and not "AdapterRead1" in samplesheet_settings.keys():
                  samplesheet_settings["AdapterRead1"] = samplesheet_settings.pop("Adapter")
              elif "Adapter" in samplesheet_settings.keys() and "AdapterRead1" in samplesheet_settings.keys():
                  _ = samplesheet_settings.pop("Adapter")

              # Drop any settings where settings are "" - needed for "AdapterRead2"
              samplesheet_settings = {
                                       key: val
                                       for key, val in samplesheet_settings.items()
                                       if not val == ""
                                     }
              
              # Drop AdapterRead2 if OverrideCycles match the regex \w+;\w+;[nN]\d+;[nN]\d+
              if "OverrideCycles" in samplesheet_settings.keys() and re.match(r"\w+;\w+;[nN]\d+;[nN]\d+", samplesheet_settings["OverrideCycles"]) is not None:
                if "AdapterRead2" in samplesheet_settings.keys():
                  del samplesheet_settings["AdapterRead2"]
          
              # Drop MinimumAdapterOverlap if neither AdapterRead1 nor AdapterRead2 are present
              if not "AdapterRead1" in samplesheet_settings.keys() and not "AdapterRead2" in samplesheet_settings.keys() and "MinimumAdapterOverlap" in samplesheet_settings.keys():
                del samplesheet_settings["MinimumAdapterOverlap"]
          
              return samplesheet_settings


          def truncate_data_columns_v2(samplesheet_data_df):
              """
              Truncate data columns to v2 columns
              Lane,Sample_ID,index,index2,Sample_Project
              :param samplesheet_data_df:
              :return:
              """

              v2_columns = ["Lane", "Sample_ID", "index", "index2", "Sample_Project"]
              samplesheet_data_df = samplesheet_data_df.filter(items=v2_columns)

              return samplesheet_data_df


          def convert_reads_from_list_to_dict_v2(samplesheet_reads):
              """
              Convert Reads from a list to a dict format
              :param samplesheet_reads:
              :return:
              """

              samplesheet_reads = {"Read{}Cycles".format(i + 1): rnum for i, rnum in enumerate(samplesheet_reads)}

              return samplesheet_reads


          def convert_samplesheet_to_v2(samplesheet_obj):
              """
              Runs through necessary steps to convert object to v2 samplesheet
              :param samplesheet_obj:
              :return:
              """
              samplesheet_obj["Header"] = add_file_format_version_v2(samplesheet_obj["Header"])
              samplesheet_obj["Header"] = set_instrument_type(samplesheet_obj["Header"])
              samplesheet_obj["Settings"] = update_settings_v2(samplesheet_obj["Settings"])
              samplesheet_obj["Data"] = truncate_data_columns_v2(samplesheet_obj["Data"])
              samplesheet_obj["Reads"] = convert_reads_from_list_to_dict_v2(samplesheet_obj["Reads"])
              samplesheet_obj = rename_settings_and_data_headers_v2(samplesheet_obj)

              return samplesheet_obj


          def check_samples(samplesheet_obj, settings_by_samples, ignore_missing_samples=False):
              """
              If settings_by_samples is defined, ensure that each sample is present
              """
              all_samples_in_samplesheet = samplesheet_obj["Data"]["Sample_ID"].tolist()
              popped_samples = []

              if len(settings_by_samples.keys()) == 0:
                  # No problem as we're not splitting samples by sample sheet
                  return

              for batch_name, batch_settings_and_samples_dict in settings_by_samples.items():
                  samples = batch_settings_and_samples_dict.get("samples")
                  for sample in samples:
                      if sample in popped_samples:
                          logging.error("Sample \"{}\" registered multiple times".format(sample))
                          sys.exit(1)
                      elif sample not in all_samples_in_samplesheet:
                          logging.error("Could not find sample \"{}\"".format(sample))
                          sys.exit(1)
                      else:
                          popped_samples.append(all_samples_in_samplesheet.pop(all_samples_in_samplesheet.index(sample)))

              if ignore_missing_samples:
                  # No issue
                  return

              if not len(all_samples_in_samplesheet) == 0:
                  logging.error("The following samples have no associated batch name: {}".format(
                      ", ".join(map(str, ["\"{}\"".format(sample) for sample in all_samples_in_samplesheet]))
                  ))
                  sys.exit(1)


          def write_out_samplesheets(samplesheet_obj, out_dir, settings_by_samples,
                                     is_v2=False):
              """
              Write out samplesheets to each csv file
              :return:
              """

              if not len(list(settings_by_samples.keys())) == 0:
                  for batch_name, batch_settings_and_samples_dict in settings_by_samples.items():
                      # Get settings
                      settings = batch_settings_and_samples_dict.get("settings")
                      samples = batch_settings_and_samples_dict.get("samples")
                      # Duplicate samplesheet_obj
                      samplesheet_obj_by_settings_copy = deepcopy(samplesheet_obj)
                      # Convert df to csv string
                      samplesheet_obj_by_settings_copy["Data"] = samplesheet_obj_by_settings_copy["Data"].query("Sample_ID in @samples")
                      # Update settings
                      for setting_key, setting_val in settings.items():
                          """
                          Update settings
                          """
                          if setting_val is None:
                              # Don't add None var
                              continue
                          # Update setting value for boolean types
                          if type(setting_val) == bool:
                              setting_val = 1 if setting_val else 0
                          # Then assign to settings dict
                          samplesheet_obj_by_settings_copy["Settings"][
                              lower_under_score_to_camel_case(setting_key)] = setting_val

                      # Write out config
                      write_samplesheet(samplesheet_obj=samplesheet_obj_by_settings_copy,
                                        output_file=out_dir / "SampleSheet.{}.csv".format(batch_name),
                                        is_v2=is_v2)

              else:  # No splitting required
                  write_samplesheet(samplesheet_obj=samplesheet_obj,
                                    output_file=out_dir / "SampleSheet.csv",
                                    is_v2=is_v2)


          def write_samplesheet(samplesheet_obj, output_file, is_v2):
              """
              Write out the samplesheet object and a given file
              :param samplesheet_obj:
              :param output_file:
              :param is_v2
              :return:
              """

              # Rename samplesheet at the last possible moment
              if is_v2:
                  # Drop index2 if all are "N/A"
                  if 'index2' in samplesheet_obj["Data"].columns.tolist() and \
                          samplesheet_obj["Data"]["index2"].isna().all():
                      samplesheet_obj["Data"] = samplesheet_obj["Data"].drop(columns="index2")

                  samplesheet_obj = convert_samplesheet_to_v2(samplesheet_obj)

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

              # Check missing samples
              logging.info("Checking missing samples")
              check_samples(samplesheet_obj=samplesheet_obj,
                            settings_by_samples=getattr(args, "settings_by_batch_names", {}),
                            ignore_missing_samples=args.ignore_missing_samples)

              # Strip Ns from samplesheet indexes
              logging.info("Stripping Ns from indexes")
              samplesheet_obj["Data"] = strip_ns_from_indexes(samplesheet_obj["Data"])

              # Write out samplesheets
              logging.info("Writing out samplesheets")
              write_out_samplesheets(samplesheet_obj=samplesheet_obj,
                                     out_dir=args.out_dir,
                                     settings_by_samples=getattr(args, "settings_by_batch_names", {}),
                                     is_v2=True if args.samplesheet_format == "v2" else False)

          # Run main script
          if __name__ == "__main__":
              main()

baseCommand: ["python3", "samplesheet-by-settings.py"]

inputs:
  samplesheet_csv:
    label: samplesheet csv
    doc: |
      The path to the original samplesheet csv file
    type: File
    inputBinding:
      prefix: "--samplesheet-csv"
  out_dir:
    label: out dir
    doc: |
      Where to place the output samplesheet csv files
    type: string?
    inputBinding:
      prefix: "--out-dir"
    default: "samplesheets-by-override-cycles"
  # Override cycles settings
  settings_by_samples:
    label: settings by samples
    doc: |
      Takes in an object form of settings by samples. This is used to split samplesheets
    type:
      - "null"
      - type: array
        items: ../../../schemas/settings-by-samples/1.0.0/settings-by-samples__1.0.0.yaml#settings-by-samples
        inputBinding:
          prefix: "--settings-by-samples="
          separate: false
          valueFrom: |
            ${
              /*
              Format is {"batch_name": "WGS", "sample_ids":["S1", "S2", "S3"], "settings":{"adapter_read_1":"foo", "setting_2":"bar"}}
              Although BCLConvert settings are in camel-case, we have settings in lower case, with underscore separation instead
              Settings are translated to camel case in the workflow. adapter_read_1 becomes AdapterRead1
              */
              return JSON.stringify(self);
            }
    inputBinding:
      position: 1  # Make sure all parameters are together
  # Miscell
  ignore_missing_samples:
    label: ignore missing samples
    doc: |
      Don't raise an error if samples from the override cycles list are missing. Just remove them
    type: boolean?
    inputBinding:
      prefix: "--ignore-missing-samples"
  samplesheet_format:
    label: samplesheet format
    type:
      - "null"
      - type: enum
        symbols:
          - v1
          - v2
    doc: |
      Set samplesheet to be in v1 or v2 format
    inputBinding:
      prefix: "--samplesheet-format"
outputs:
  samplesheet_outdir:
    label: samplesheets outdir
    doc: |
      Directory of samplesheets
    type: Directory
    outputBinding:
      glob: "$(inputs.out_dir)"
  samplesheets:
    label: output samplesheets
    doc: |
      List of output samplesheets
    type: File[]
    outputBinding:
      glob: "$(inputs.out_dir)/*.csv"

successCodes:
  - 0
