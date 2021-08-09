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
id: custom-create-csv-from-fastq-list-row--1.0.0
label: custom-create-csv-from-fastq-list-row v(1.0.0)
doc: |
    Takes a set of fastq list rows and creates a csv.
    Outputs are the predefined mount paths of read 1 and read 2, and the csv file,
    Both of these must be taken into the germline step


hints:
    ResourceRequirement:
        ilmn-tes:resources:
            tier: standard
            type: standard
            size: small
        coresMin: 1
        ramMin: 2000
    DockerRequirement:
        dockerPull: umccr/alpine-pandas:1.2.2

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml
      - $import: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - var get_mount_path_csv = function(){
          /*
          Set the csv containing the mount paths
          */
          return "predefined_mount_paths.csv";
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: fastq-list.py
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
          from itertools import chain
          import sys
          from uuid import uuid4
          import json

          # Globals
          INPUT_FOLDER = "input_fastq_files"
          OUTPUT_COLUMNS = ["RGID", "RGLB", "RGSM", "Lane", "Read1File", "Read2File"]


          # Inputs
          def get_args():
              """
              Get arguments for the command
              """
              parser = argparse.ArgumentParser(description="Create fastq list file from inputs")

              # Arguments
              parser.add_argument("--output-fastq-list-csv", required=True,
                                  help="Path to output fastq list file")
              parser.add_argument("--output-predefined-mount-points-csv", required=True,
                                  help="Path to output predefined mount opints file")
              parser.add_argument("--fastq-list-row", action="append", nargs='*', required=True,
                                  help="Each of the fastq-list-row objects in python")

              return parser.parse_args()


          # Check args
          def set_args(args):
              """
              Check arguments
              """

              # Create directory for csv path
              output_fastq_list_csv_arg = getattr(args, "output_fastq_list_csv", None)
              output_fastq_list_csv_path = Path(output_fastq_list_csv_arg)
              output_fastq_list_csv_path.parent.mkdir(parents=True, exist_ok=True)
              setattr(args, "output_fastq_list_csv_path", output_fastq_list_csv_path)

              # Create directory for predefined mount points csv
              output_predefined_mount_points_csv_arg = getattr(args, "output_predefined_mount_points_csv", None)
              output_predefined_mount_points_csv_path = Path(output_predefined_mount_points_csv_arg)
              output_predefined_mount_points_csv_path.parent.mkdir(parents=True, exist_ok=True)
              setattr(args, "output_predefined_mount_points_csv_path", output_predefined_mount_points_csv_path)

              # Get fastq list rows as list of dicts
              fastq_list_rows_arg = getattr(args, "fastq_list_row", [])
              fastq_list_rows = []

              # Import fastq list row arg
              for fastq_list_row_arg in fastq_list_rows_arg:
                  fastq_list_rows.append(json.loads(fastq_list_row_arg[0]))
              setattr(args, "fastq_list_rows_list", fastq_list_rows)

              return args

          # Create DF from args dict
          def create_fastq_list_from_args_dict(fastq_list_rows):
              """
              Create a dataframe from the set args output
              """

              # Create dataframe from args dict
              fastq_list_df = pd.DataFrame(fastq_list_rows)

              # Add read2 column if it doesn't exist. Keep empty
              if not 'read2' in fastq_list_df.columns.tolist():
                  fastq_list_df["read2"] = ""

              # Rename columns
              fastq_list_df.rename(columns={
                  "rgid": "RGID",
                  "rglb": "RGLB",
                  "rgsm": "RGSM",
                  "lane": "Lane",
                  "read_1": "Read1File",
                  "read_2": "Read2File"
              }, inplace=True)

              # Return data frame
              return fastq_list_df


          def get_uuid():
              """
              Unique for each row
              """
              return str(uuid4())


          def extend_uuid_to_path(read_name, uuid):
              """
              Extend the uuid to the path
              """

              # If Read2 isn't defined
              if read_name == "":
                  return ""

              # Get name
              read_uuid_path = Path(INPUT_FOLDER) / Path(uuid) / Path(read_name)

              return read_uuid_path


          def add_uuid_to_read_columns(fastq_list_df):
              """
              Add the UUID prefix to the fastq_list_df reads
              """
              # Get uuid for each row
              fastq_list_df["UUID"] = fastq_list_df.apply(lambda x: get_uuid(), axis="columns")

              # Convert Read1File and Read2File to uuid mount paths
              fastq_list_df["Read1File"] = fastq_list_df.apply(lambda x: extend_uuid_to_path(x.Read1File, x.UUID),
                                                               axis="columns")

              # Convert Read2File
              fastq_list_df["Read2File"] = fastq_list_df.apply(lambda x: extend_uuid_to_path(x.Read2File, x.UUID),
                                                               axis="columns")

              # Drop UUID
              fastq_list_df.drop(columns=["UUID"], inplace=True)

              return fastq_list_df


          def finalise_output_df(fastq_list_df):
              """
              Returns the fastq_list_df with the right column order.
              """

              fastq_list_df = fastq_list_df.reindex(columns=OUTPUT_COLUMNS)

              return fastq_list_df


          def write_fastq_list_to_csv(fastq_list_df, output_file):
              """
              Write the fastq_list_df to the specified output file
              """

              fastq_list_df.to_csv(output_file, header=True, index=False)


          def write_mount_paths_to_csv(fastq_list_df, output_file):
              """
              Write the mount paths to the specified output file
              """

              fastq_list_df[["Read1File", "Read2File"]].to_csv(output_file, header=False, index=False)


          def main():
              # Get args
              args = get_args()

              # Get args dict from args and check args
              args = set_args(args)

              # Create df from args dict
              fastq_list_df = create_fastq_list_from_args_dict(args.fastq_list_rows_list)

              # Add uuid to read columns
              fastq_list_df = add_uuid_to_read_columns(fastq_list_df)

              # Construct output dfs
              fastq_list_df = finalise_output_df(fastq_list_df)

              # Write out csv
              write_fastq_list_to_csv(fastq_list_df, args.output_fastq_list_csv_path)

              # Write out mount paths
              write_mount_paths_to_csv(fastq_list_df, args.output_predefined_mount_points_csv_path)


          if __name__ == "__main__":
              main()


baseCommand: [ "python", "fastq-list.py" ]

arguments:
  # Before the other arguments
  - prefix: "--output-predefined-mount-points-csv"
    valueFrom: "$(get_mount_path_csv())"
    position: -1

inputs:
  fastq_list_rows:
    label: Row of fastq lists
    doc: |
      The row of fastq lists.
      Each row has the following attributes:
        * RGID
        * RGLB
        * RGSM
        * Lane
        * Read1File
        * Read2File (optional)
    type:
      - type: array
        items: ../../../schemas/fastq-list-row/1.0.0/fastq-list-row__1.0.0.yaml#fastq-list-row
        inputBinding:
          prefix: "--fastq-list-row="
          separate: false
          valueFrom: |
            ${
              /*
              Initialise with string sets
              */
              var new_obj = {};
              for (var key in self) {
                /*
                Iterate through each component of a fastq list row.
                If type is string, or int, append.
                If type is object, and class is File, append path
                */
                if (typeof self[key] === "string"){
                  /*
                  Simply append
                  */
                  new_obj[key] = self[key];
                } else if (typeof self[key] === "number"){
                  /*
                  Also, append but as a string
                  */
                  new_obj[key] = self[key];
                } else if (self[key].class === "File") {
                  /*
                  We have a file attribute, append path
                  */
                  new_obj[key] = self[key].basename
                }
              }
              return JSON.stringify(new_obj);
            }
    inputBinding:
      # Makes sure all items are together
      position: 1
  fastq_list_csv_filename:
    label: output file name for the fastq-list-csv
    doc: |
      The output fastq list csv name with the uuid mounts
    type: string?
    default: "fastq_list.csv"
    inputBinding:
      prefix: "--output-fastq-list-csv"

outputs:
  fastq_list_csv_out:
    label: fastq list csv out
    doc: |
      This is the output of the fastq list csv.
      It contains the input names and the uuids for each path
    type: File
    outputBinding:
      glob: "$(inputs.fastq_list_csv_filename)"
  predefined_mount_paths_out:
    label: predefined mount paths
    type: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml#predefined-mount-path[]
    doc: |
      This schema contains the following inputs -
        * file_obj: The actual file object
        * mount_path: The uuid mount path as set in the fastq_list.csv
    outputBinding:
      glob: "predefined_mount_paths.csv"
      loadContents: true
      outputEval: |
        ${
            /*
            Load inputs, initialise output variables
            */
            var output_array = [];
            var lines = self[0].contents.split("\n")

            /*
            Generate output object
            File mount and mount path
            csv ends on new line so we dont look at the last row
            */

            for (var i=0; i < lines.length - 1; i++){
                /*
                Split row and collect corresponding file paths
                */
                var file_obj_1 = inputs.fastq_list_rows[i].read_1;
                var mount_path_1 = lines[i].split(",")[0];
                var file_obj_2 = inputs.fastq_list_rows[i].read_2;
                var mount_path_2 = lines[i].split(",")[1];

                /*
                Append read_1 to output
                */
                output_array.push(
                    {
                      "file_obj": file_obj_1,
                      "mount_path": mount_path_1
                    }
                );

                /*
                If no mount path for read_2 just skip it
                */
                if (mount_path_2 === ""){
                  continue;
                }

                /*
                Append read_2 to the output array
                */
                output_array.push(
                    {
                      "file_obj": file_obj_2,
                      "mount_path": mount_path_2
                    }
                );
            }
            return output_array;
        }

successCodes:
  - 0
