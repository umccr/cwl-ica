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
id: custom-create-directory--2.0.1
label: custom-create-directory v(2.0.1)
doc: |
    Create a directory for output v2.0.1, uses the custom-output-dir-entry schema v2.0.1.
    Can be of type - tarball, directory, filelist.
    One can select a list of files from each directory, tarball to extract.
    One can also select 'top_dir' or 'sub_dir' to determine if files go in the top directory or a sub directory.  

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: standard
    ilmn-tes:resources/size: xlarge
    coresMin: 4
    ramMin: 14000
  DockerRequirement:
    dockerPull: umccr/alpine-pandas:1.2.2

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/custom-output-dir-entry/2.0.1/custom-output-dir-entry__2.0.1.yaml
  InlineJavascriptRequirement:
    expressionLib:
      # Python script name
      - var get_python_script_name = function(){
          return "create-output-dir.py";
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: create-output-dir.py
        entry: |
          #!/usr/bin/env python3

          """
          Import args
          Collect args and confirm
          Generate csv from args
          Set paths as uuids for each sample row
          """

          # Imports
          from pathlib import Path
          from urllib.parse import urlparse
          import argparse
          from argparse import Namespace
          import json
          from typing import List
          import shutil
          import tarfile
          import re

          # Inputs
          def get_args() -> Namespace:
              """
              Get arguments for the command
              """
              parser = argparse.ArgumentParser(description="Create fastq list file from inputs")

              # Arguments
              parser.add_argument("--output-directory-name", required=True,
                                  help="The name of the output directory")
              parser.add_argument("--custom-output-dir-entry", action="append", nargs='*', required=True,
                                  help="Each of the custom output directory entry objects in python")

              return parser.parse_args()


          # Check args
          def set_args(args):
              """
              Check arguments
              """

              # Create directory for csv path
              output_directory_name_arg = getattr(args, "output_directory_name", None)
              output_directory_name_path = Path(output_directory_name_arg)
              output_directory_name_path.mkdir()
              setattr(args, "output_directory_name_path", output_directory_name_path)

              # Get fastq list rows as list of dicts
              custom_output_dir_entries_arg = getattr(args, "custom_output_dir_entry", [])
              custom_output_dir_entries = []

              # Import fastq list row arg
              for custom_output_dir_entry_arg in custom_output_dir_entries_arg:
                  custom_output_dir_entries.append(json.loads(custom_output_dir_entry_arg[0]))
              setattr(args, "custom_output_dir_entries_list", custom_output_dir_entries)
          
              return args

          def add_directory_to_output_directory(directory: str, files_list_str: List[str]=None, output_directory: str=None, collection_name: str=None, copy_method: str=None):
              """
              Copy one directory into another
              :param directory:
              :param files_list_str:
              :param output_directory
              :param collection_name:
              :param copy_method:
              :return:
              """
              # Check copy method
              if copy_method == "sub_dir":
                  output_directory = Path(output_directory) / Path(collection_name)
                  output_directory.mkdir(exist_ok=True)

              # Standard copy over
              if files_list_str is None:
                  shutil.copytree(directory, output_directory, dirs_exist_ok=True)
                  return

              # Copy over files
              for file_name in files_list_str:
                  file_path: Path = Path(directory) / Path(file_name)
                  if file_path.is_file():
                      shutil.copy2(file_path, output_directory)


          def add_file_list_to_output_directory(file_list: List[str], output_directory: str=None, collection_name: str=None, copy_method: str=None):
              """
              Copy a list of files in to the output directory
              :param file_list:
              :param output_directory:
              :param collection_name:
              :param copy_method:
              :return:
              """
              # Check copy method
              if copy_method == "sub_dir":
                  output_directory = Path(output_directory) / Path(collection_name)
                  output_directory.mkdir(exist_ok=True)

              # Copy over files
              for file_path in file_list:
                  file_path = Path(file_path)
                  if file_path.is_file():
                      shutil.copy2(file_path, output_directory)


          def add_tarball_to_output_directory(tarball: str=None, files_list_str: List[str]=None, output_directory: str=None, collection_name: str=None, copy_method: str=None):
              """
              By far the most complicated of all, iterate through the tarball and extract the
              Credit where credit is due: https://stackoverflow.com/questions/8259769/extract-all-files-with-directory-path-in-given-directory
              :param tarball:
              :param files_list_str
              :param output_directory:
              :param collection_name:
              :param copy_method:
              :return:
              """
              # Mini sub-function for collecting only the right members
              def get_members(tar: tarfile.TarFile, tar_file_list_str: List[str]=None):
                  for tarinfo in tar.getmembers():
                      # Check if tar file list is set, only extract what we need
                      if tar_file_list_str is not None:
                          if tarinfo.name not in tar_file_list_str:
                              continue

                      # Check if the top directory
                      if tarinfo.name == re.sub(".tar.gz$", "", Path(tarball).name):
                          # Only continue if it hasn't been specified
                          if tar_file_list_str is None:
                              # We pull out files individually anyway
                              continue
                          # Check if this directory is in the list of extractions
                          if tarinfo.name in tar_file_list_str:
                              yield tarinfo

                      # Get the new tar name
                      tarinfo.name = str(Path(tarinfo.name).relative_to(Path(re.sub(".tar.gz$", "", Path(tarball).name))))

                      yield tarinfo

              # Check copy method
              if copy_method == "sub_dir":
                  output_directory = Path(output_directory) / Path(collection_name)
                  output_directory.mkdir(exist_ok=True)

              # Create the tar file object
              tar_file_obj: tarfile.TarFile = tarfile.open(tarball)

              # Extract all
              tar_file_obj.extractall(output_directory, get_members(tar_file_obj, files_list_str))


          def main():
              # Get args
              args = get_args()

              # Get args dict from args and check args
              args = set_args(args)

              # Iterate through entries list and appropriately place items in the output directory
              for custom_output_dir in args.custom_output_dir_entries_list:
                  # Manually go through the logic based on the attributes of the output directorybv
                  # Type 1: dir and files_list_str
                  if custom_output_dir.get("dir") is not None:
                      directory_location = custom_output_dir.get("dir").get("path")
                      add_directory_to_output_directory(directory_location,
                                                        custom_output_dir.get("files_list_str", None),
                                                        args.output_directory_name,
                                                        custom_output_dir.get("collection_name", None),
                                                        custom_output_dir.get("copy_method", None))
                  # Type 2: array of files
                  elif custom_output_dir.get("file_list") is not None:
                      file_list = [file_item.get("path") for file_item in custom_output_dir.get("file_list")]
                      add_file_list_to_output_directory(file_list,
                                                        args.output_directory_name,
                                                        custom_output_dir.get("collection_name"),
                                                        custom_output_dir.get("copy_method", None))
                  # Type 3: A compressed tarball
                  elif custom_output_dir.get("tarball") is not None:
                      tarball_location = custom_output_dir.get("tarball").get("path")
                      add_tarball_to_output_directory(tarball_location,
                                                      custom_output_dir.get("files_list_str", None),
                                                      args.output_directory_name,
                                                      custom_output_dir.get("collection_name"),
                                                      custom_output_dir.get("copy_method"))


          if __name__ == "__main__":
              main()



baseCommand: [ "python" ]

arguments:
  - position: -1
    valueFrom: "$(get_python_script_name())"

inputs:
  output_directory_name:
    label: output directory name
    doc: |
      The name of the output directory
    type: string
    inputBinding:
      position: 100
      prefix: "--output-directory-name"
  custom_output_dir_entry_list:
    label: Custom output dir entry list
    doc: |
      The list of file entries
    type:
      - type: array
        items: ../../../schemas/custom-output-dir-entry/2.0.1/custom-output-dir-entry__2.0.1.yaml#custom-output-dir-entry
        inputBinding:
          prefix: "--custom-output-dir-entry="
          position: 2
          separate: false
          valueFrom: |
            ${
              /*
              Initialise with string sets
              */
              if (self["dir"] !== null){
                /*
                We have a directory - retain just the path attribute for each
                */
                self["dir"] = {"path": self["dir"]["path"]};
              } else if (self["file_list"] !== null){
                /*
                We have list of files - retain just the path attribute for each
                */
                var new_file_list = [];
                for (var file_iter=0; file_iter < self["file_list"].length; file_iter++){
                  new_file_list.push({"path": self["file_list"][file_iter]["path"]});
                }
                self["file_list"] = new_file_list;
              } else if (self["tarball"] !== null){
                self["tarball"] = {"path": self["tarball"]["path"]};
              }
              return JSON.stringify(self);
            }

outputs:
  output_directory:
    label: output directory
    doc: |
      The output directory
    type: Directory
    outputBinding:
      glob: "$(inputs.output_directory_name)"


successCodes:
  - 0
