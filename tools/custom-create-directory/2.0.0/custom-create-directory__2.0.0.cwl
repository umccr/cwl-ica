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
id: custom-create-directory--2.0.0
label: custom-create-directory v(2.0.0)
doc: |
    Create a directory for output v2.0.0, uses the custom-output-dir-entry schema v2.0.0.
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
        dockerPull: ghcr.io/umccr/alpine-pandas:1.2.2

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/custom-output-dir-entry/2.0.0/custom-output-dir-entry__2.0.0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - var set_as_relative_path = function (mount_dir, object_path) {
            /*
            If mount_dir is set to null, were in the listing phase
            In this phase we should make sure we strip the / off the mount
            If mount_dir is set just leave it as is.
            */
            if (mount_dir !== null){
              return object_path;
            } else {
              return object_path.replace(/^\//, "");
            }
        }
      - var get_custom_dir_schema_input_by_key = function (schema_object, key_name, mount_dir, is_mounting) {
          /*
          This key object might not be utilised
          */
          if (schema_object[key_name] === null) {
            return null;
          }

          /*
          Initialise the input type, might be string, directory or file
          Also initialise the return value, this will be a relative path if the
          input is a file or directory, otherwise just a string
          */
          var listing_obj = null;
          var var_type = "string";

          if (key_name === "collection_name" || key_name === "copy_method") {
            /*
            Simply append - collection_name or copy_method
            We use the listing object but this will exist only when this function is called in the inputBinding
            */
            listing_obj = [
                            {"entryname":schema_object[key_name]}
                          ];

          } else if (schema_object[key_name].hasOwnProperty("class") && (schema_object[key_name].class === "File" || schema_object[key_name].class === "Directory")) {
            /*
            We have a file attribute or directory attribute, append path
            */
            var_type = "obj";
            listing_obj = [{
                             "entryname":set_as_relative_path(mount_dir, schema_object[key_name].path),
                             "entry":schema_object[key_name]
                          }];
          } else if (Array.isArray(schema_object[key_name])) {
            /*
            Check the first element of the array, check if it has the "class" attribute and
            if its set to file
            */
            if (schema_object[key_name][0].hasOwnProperty("class") && (schema_object[key_name][0].class === "File")) {
              /*
              We have an array of files or directories
              */
              var_type = "obj";
              listing_obj = schema_object[key_name].map(function (a) {
                return {
                  "entryname":set_as_relative_path(mount_dir, a.path),
                  "entry":a
                };
              });
            } else {
              /*
              We have just an array of strings
              */
              listing_obj = schema_object[key_name].map(function (a) {
                return {
                  "entryname":a
                };
              });
            }
          } else {
            /*
            Dont know what were dealing with here
            */
            return null;
          }

          /*
          Now we return based on if were trying to mount or set the input binding
          */

          if (is_mounting && var_type === "string") {
            /*
            Were in the listing section and weve got "collection_name" or "copy_method" attributes, not relevant!
            */
            return null;
          } else if (is_mounting && var_type === "obj") {
            /*
            Were in the listing section and weve got an object
            */
            return listing_obj;
          } else {
            return listing_obj.map(function(a) {
              return a.entryname;
            });
          }
        }
      # Python scripts
      - var get_python_script_name = function(){
          return "create-output-dir.py";
        }
      - var get_python_script_entry = function(){
          return "#!/usr/bin/env python3" + "\n" +
                  "" + "\n" +
                  "\"\"\"" + "\n" +
                  "Import args" + "\n" +
                  "Collect args and confirm" + "\n" +
                  "Generate csv from args" + "\n" +
                  "Set paths as uuids for each sample row" + "\n" +
                  "\"\"\"" + "\n" +
                  "" + "\n" +
                  "# Imports" + "\n" +
                  "from pathlib import Path" + "\n" +
                  "import argparse" + "\n" +
                  "from argparse import Namespace" + "\n" +
                  "import json" + "\n" +
                  "from typing import List" + "\n" +
                  "import shutil" + "\n" +
                  "import tarfile" + "\n" +
                  "import re" + "\n" +
                  "" + "\n" +
                  "" + "\n" +
                  "# Inputs" + "\n" +
                  "def get_args() -> Namespace:" + "\n" +
                  "    \"\"\"" + "\n" +
                  "    Get arguments for the command" + "\n" +
                  "    \"\"\"" + "\n" +
                  "    parser = argparse.ArgumentParser(description=\"Create fastq list file from inputs\")" + "\n" +
                  "" + "\n" +
                  "    \# Arguments" + "\n" +
                  "    parser.add_argument(\"--output-directory-name\", required=True," + "\n" +
                  "                        help=\"The name of the output directory\")" + "\n" +
                  "    parser.add_argument(\"--custom-output-dir-entry\", action=\"append\", nargs=\"*\", required=True," + "\n" +
                  "                        help=\"Each of the custom output directory entry objects in python\")" + "\n" +
                  "" + "\n" +
                  "    return parser.parse_args()" + "\n" +
                  "" + "\n" +
                  "" + "\n" +
                  "# Check args" + "\n" +
                  "def set_args(args):" + "\n" +
                  "    \"\"\"" + "\n" +
                  "    Check arguments" + "\n" +
                  "    \"\"\"" + "\n" +
                  "" + "\n" +
                  "    \# Create directory for csv path" + "\n" +
                  "    output_directory_name_arg = getattr(args, \"output_directory_name\", None)" + "\n" +
                  "    output_directory_name_path = Path(output_directory_name_arg)" + "\n" +
                  "    output_directory_name_path.mkdir()" + "\n" +
                  "    setattr(args, \"output_directory_name_path\", output_directory_name_path)" + "\n" +
                  "" + "\n" +
                  "    \# Get fastq list rows as list of dicts" + "\n" +
                  "    custom_output_dir_entries_arg = getattr(args, \"custom_output_dir_entry\", [])" + "\n" +
                  "    custom_output_dir_entries = []" + "\n" +
                  "" + "\n" +
                  "    \# Import fastq list row arg" + "\n" +
                  "    for custom_output_dir_entry_arg in custom_output_dir_entries_arg:" + "\n" +
                  "        custom_output_dir_entries.append(json.loads(custom_output_dir_entry_arg[0]))" + "\n" +
                  "    setattr(args, \"custom_output_dir_entries_list\", custom_output_dir_entries)" + "\n" +
                  "" + "\n" +
                  "    return args" + "\n" +
                  "" + "\n" +
                  "" + "\n" +
                  "def add_directory_to_output_directory(directory:str, files_list_str:List[str] = None, output_directory:str = None," + "\n" +
                  "                                      collection_name:str = None, copy_method:str = None):" + "\n" +
                  "    \"\"\"" + "\n" +
                  "    Copy one directory into another" + "\n" +
                  "    :param directory:" + "\n" +
                  "    :param files_list_str:" + "\n" +
                  "    :param output_directory" + "\n" +
                  "    :param collection_name:" + "\n" +
                  "    :param copy_method:" + "\n" +
                  "    :return:" + "\n" +
                  "    \"\"\"" + "\n" +
                  "    \# Check copy method" + "\n" +
                  "    if copy_method == \"sub_dir\":" + "\n" +
                  "        output_directory = Path(output_directory) / Path(collection_name)" + "\n" +
                  "" + "\n" +
                  "    \# Standard copy over" + "\n" +
                  "    if files_list_str is None:" + "\n" +
                  "        shutil.copytree(directory, output_directory, dirs_exist_ok=True)" + "\n" +
                  "        return" + "\n" +
                  "" + "\n" +
                  "    \# Copy over files" + "\n" +
                  "    for file_name in files_list_str:" + "\n" +
                  "        file_path:Path = Path(directory) / Path(file_name)" + "\n" +
                  "        if file_path.is_file():" + "\n" +
                  "            shutil.copy2(file_path, output_directory)" + "\n" +
                  "" + "\n" +
                  "" + "\n" +
                  "def add_file_list_to_output_directory(file_list:List[str], output_directory:str = None, collection_name:str = None," + "\n" +
                  "                                      copy_method:str = None):" + "\n" +
                  "    \"\"\"" + "\n" +
                  "    Copy a list of files in to the output directory" + "\n" +
                  "    :param file_list:" + "\n" +
                  "    :param output_directory:" + "\n" +
                  "    :param collection_name:" + "\n" +
                  "    :param copy_method:" + "\n" +
                  "    :return:" + "\n" +
                  "    \"\"\"" + "\n" +
                  "    \# Check copy method" + "\n" +
                  "    if copy_method == \"sub_dir\":" + "\n" +
                  "        output_directory = Path(output_directory) / Path(collection_name)" + "\n" +
                  "" + "\n" +
                  "    \# Copy over files" + "\n" +
                  "    for file_path in file_list:" + "\n" +
                  "        file_path = Path(file_path)" + "\n" +
                  "        if file_path.is_file():" + "\n" +
                  "            shutil.copy2(file_path, output_directory)" + "\n" +
                  "" + "\n" +
                  "" + "\n" +
                  "def add_tarball_to_output_directory(tarball:str = None, files_list_str:List[str] = None, output_directory:str = None," + "\n" +
                  "                                    collection_name:str = None, copy_method:str = None):" + "\n" +
                  "    \"\"\"" + "\n" +
                  "    By far the most complicated of all, iterate through the tarball and extract the" + "\n" +
                  "    Credit where credit is due:https://stackoverflow.com/questions/8259769/extract-all-files-with-directory-path-in-given-directory" + "\n" +
                  "    :param tarball:" + "\n" +
                  "    :param files_list_str" + "\n" +
                  "    :param output_directory:" + "\n" +
                  "    :param collection_name:" + "\n" +
                  "    :param copy_method:" + "\n" +
                  "    :return:" + "\n" +
                  "    \"\"\"" + "\n" +
                  "" + "\n" +
                  "    \# Mini sub-function for collecting only the right members" + "\n" +
                  "    def get_members(tar:tarfile.TarFile, tar_file_list_str:List[str] = None):" + "\n" +
                  "        for tarinfo in tar.getmembers():" + "\n" +
                  "            \# Check if tar file list is set, only extract what we need" + "\n" +
                  "            if tar_file_list_str is not None:" + "\n" +
                  "                if tarinfo.name not in tar_file_list_str:" + "\n" +
                  "                    continue" + "\n" +
                  "" + "\n" +
                  "            \# Check if the top directory" + "\n" +
                  "            if tarinfo.name == re.sub(\".tar.gz$\", \"\", Path(tarball).name):" + "\n" +
                  "                \# Only continue if it hasn\"t been specified" + "\n" +
                  "                if tar_file_list_str is None:" + "\n" +
                  "                    \# We pull out files individually anyway" + "\n" +
                  "                    continue" + "\n" +
                  "                \# Check if this directory is in the list of extractions" + "\n" +
                  "                if tarinfo.name in tar_file_list_str:" + "\n" +
                  "                    yield tarinfo" + "\n" +
                  "" + "\n" +
                  "            \# Get the new tar name" + "\n" +
                  "            tarinfo.name = str(Path(tarinfo.name).relative_to(Path(re.sub(\".tar.gz$\", \"\", Path(tarball).name))))" + "\n" +
                  "" + "\n" +
                  "            yield tarinfo" + "\n" +
                  "" + "\n" +
                  "    \# Check copy method" + "\n" +
                  "    if copy_method == \"sub_dir\":" + "\n" +
                  "        output_directory = Path(output_directory) / Path(collection_name)" + "\n" +
                  "" + "\n" +
                  "    \# Create the tar file object" + "\n" +
                  "    tar_file_obj:tarfile.TarFile = tarfile.open(tarball)" + "\n" +
                  "" + "\n" +
                  "    \# Extract all" + "\n" +
                  "    tar_file_obj.extractall(output_directory, get_members(tar_file_obj, files_list_str))" + "\n" +
                  "" + "\n" +
                  "" + "\n" +
                  "def main():" + "\n" +
                  "    \# Get args" + "\n" +
                  "    args = get_args()" + "\n" +
                  "" + "\n" +
                  "    \# Get args dict from args and check args" + "\n" +
                  "    args = set_args(args)" + "\n" +
                  "" + "\n" +
                  "    \# Iterate through entries list and appropriately place items in the output directory" + "\n" +
                  "    for custom_output_dir in args.custom_output_dir_entries_list:" + "\n" +
                  "        \# Manually go through the logic based on the attributes of the output directory" + "\n" +
                  "        \# Type 1:dir and files_list_str" + "\n" +
                  "        if custom_output_dir.get(\"dir\") is not None:" + "\n" +
                  "            add_directory_to_output_directory(custom_output_dir.get(\"dir\")," + "\n" +
                  "                                              custom_output_dir.get(\"files_list_str\", None)," + "\n" +
                  "                                              args.output_directory_name," + "\n" +
                  "                                              custom_output_dir.get(\"collection_name\", None)," + "\n" +
                  "                                              custom_output_dir.get(\"copy_method\", None))" + "\n" +
                  "        \# Type 2:array of files" + "\n" +
                  "        elif custom_output_dir.get(\"file_list\") is not None:" + "\n" +
                  "            add_file_list_to_output_directory(custom_output_dir.get(\"file_list\")," + "\n" +
                  "                                              args.output_directory_name," + "\n" +
                  "                                              custom_output_dir.get(\"collection_name\")," + "\n" +
                  "                                              custom_output_dir.get(\"copy_method\", None))" + "\n" +
                  "        \# Type 3:A compressed tarball" + "\n" +
                  "        elif custom_output_dir.get(\"tarball\") is not None:" + "\n" +
                  "            add_tarball_to_output_directory(custom_output_dir.get(\"tarball\")," + "\n" +
                  "                                            custom_output_dir.get(\"files_list_str\", None)," + "\n" +
                  "                                            args.output_directory_name," + "\n" +
                  "                                            custom_output_dir.get(\"collection_name\")," + "\n" +
                  "                                            custom_output_dir.get(\"copy_method\"))" + "\n" +
                  "" + "\n" +
                  "" + "\n" +
                  "if __name__ == \"__main__\":" + "\n" +
                  "    main()" + "\n";
          }
  InitialWorkDirRequirement:
    listing: |
      ${
        var e = [
                  {
                    "entryname": get_python_script_name(),
                    "entry": get_python_script_entry()
                  }
                ];

        /*
        Iterate through array of schema entries
        */
        for (var schema_obj_iter=0; schema_obj_iter < inputs.custom_output_dir_entry_list.length; schema_obj_iter++ ){
          /*
          For each key in the schema object
          */
          var listing_for_schema = [];
          var schema_obj = inputs.custom_output_dir_entry_list[schema_obj_iter];
          for (var key_name in schema_obj){
            var entry_items = get_custom_dir_schema_input_by_key(schema_obj, key_name, null, true);
            if (entry_items !== null){
              listing_for_schema = listing_for_schema.concat(entry_items);
            }
          }

          /*
          Concatenate schema list to listing
          */
          e = e.concat(listing_for_schema);
        }

        /*
        Return listing array
        */
        return e;
      }
    # listing: |
    #      - entryname: create-output-dir.py
    #        entry: |
    #          #!/usr/bin/env python3
    #
    #          """
    #          Import args
    #          Collect args and confirm
    #          Generate csv from args
    #          Set paths as uuids for each sample row
    #          """
    #
    #          # Imports
    #          from pathlib import Path
    #          import argparse
    #          from argparse import Namespace
    #          import json
    #          from typing import List
    #          import shutil
    #          import tarfile
    #          import re
    #
    #          # Inputs
    #          def get_args() -> Namespace:
    #              """
    #              Get arguments for the command
    #              """
    #              parser = argparse.ArgumentParser(description="Create fastq list file from inputs")
    #
    #              # Arguments
    #              parser.add_argument("--output-directory-name", required=True,
    #                                  help="The name of the output directory")
    #              parser.add_argument("--custom-output-dir-entry", action="append", nargs='*', required=True,
    #                                  help="Each of the custom output directory entry objects in python")
    #
    #              return parser.parse_args()
    #
    #
    #          # Check args
    #          def set_args(args):
    #              """
    #              Check arguments
    #              """
    #
    #              # Create directory for csv path
    #              output_directory_name_arg = getattr(args, "output_directory_name", None)
    #              output_directory_name_path = Path(output_directory_name_arg)
    #              output_directory_name_path.mkdir()
    #              setattr(args, "output_directory_name_path", output_directory_name_path)
    #
    #              # Get fastq list rows as list of dicts
    #              custom_output_dir_entries_arg = getattr(args, "custom_output_dir_entry", [])
    #              custom_output_dir_entries = []
    #
    #              # Import fastq list row arg
    #              for custom_output_dir_entry_arg in custom_output_dir_entries_arg:
    #                  custom_output_dir_entries.append(json.loads(custom_output_dir_entry_arg[0]))
    #              setattr(args, "custom_output_dir_entries_list", custom_output_dir_entries)
    #
    #              return args
    #
    #          def add_directory_to_output_directory(directory: str, files_list_str: List[str]=None, output_directory: str=None, collection_name: str=None, copy_method: str=None):
    #              """
    #              Copy one directory into another
    #              :param directory:
    #              :param files_list_str:
    #              :param output_directory
    #              :param collection_name:
    #              :param copy_method:
    #              :return:
    #              """
    #              # Check copy method
    #              if copy_method == "sub_dir":
    #                  output_directory = Path(output_directory) / Path(collection_name)
    #
    #              # Standard copy over
    #              if files_list_str is None:
    #                  shutil.copytree(directory, output_directory, dirs_exist_ok=True)
    #                  return
    #
    #              # Copy over files
    #              for file_name in files_list_str:
    #                  file_path: Path = Path(directory) / Path(file_name)
    #                  if file_path.is_file():
    #                      shutil.copy2(file_path, output_directory)
    #
    #
    #          def add_file_list_to_output_directory(file_list: List[str], output_directory: str=None, collection_name: str=None, copy_method: str=None):
    #              """
    #              Copy a list of files in to the output directory
    #              :param file_list:
    #              :param output_directory:
    #              :param collection_name:
    #              :param copy_method:
    #              :return:
    #              """
    #              # Check copy method
    #              if copy_method == "sub_dir":
    #                  output_directory = Path(output_directory) / Path(collection_name)
    #
    #              # Copy over files
    #              for file_path in file_list:
    #                  file_path = Path(file_path)
    #                  if file_path.is_file():
    #                      shutil.copy2(file_path, output_directory)
    #
    #
    #          def add_tarball_to_output_directory(tarball: str=None, files_list_str: List[str]=None, output_directory: str=None, collection_name: str=None, copy_method: str=None):
    #              """
    #              By far the most complicated of all, iterate through the tarball and extract the
    #              Credit where credit is due: https://stackoverflow.com/questions/8259769/extract-all-files-with-directory-path-in-given-directory
    #              :param tarball:
    #              :param files_list_str
    #              :param output_directory:
    #              :param collection_name:
    #              :param copy_method:
    #              :return:
    #              """
    #              # Mini sub-function for collecting only the right members
    #              def get_members(tar: tarfile.TarFile, tar_file_list_str: List[str]=None):
    #                  for tarinfo in tar.getmembers():
    #                      # Check if tar file list is set, only extract what we need
    #                      if tar_file_list_str is not None:
    #                          if tarinfo.name not in tar_file_list_str:
    #                              continue
    #
    #                      # Check if the top directory
    #                      if tarinfo.name == re.sub(".tar.gz$", "", Path(tarball).name):
    #                          # Only continue if it hasn't been specified
    #                          if tar_file_list_str is None:
    #                              # We pull out files individually anyway
    #                              continue
    #                          # Check if this directory is in the list of extractions
    #                          if tarinfo.name in tar_file_list_str:
    #                              yield tarinfo
    #
    #                      # Get the new tar name
    #                      tarinfo.name = str(Path(tarinfo.name).relative_to(Path(re.sub(".tar.gz$", "", Path(tarball).name))))
    #
    #                      yield tarinfo
    #
    #              # Check copy method
    #              if copy_method == "sub_dir":
    #                  output_directory = Path(output_directory) / Path(collection_name)
    #
    #              # Create the tar file object
    #              tar_file_obj: tarfile.TarFile = tarfile.open(tarball)
    #
    #              # Extract all
    #              tar_file_obj.extractall(output_directory, get_members(tar_file_obj, files_list_str))
    #
    #
    #          def main():
    #              # Get args
    #              args = get_args()
    #
    #              # Get args dict from args and check args
    #              args = set_args(args)
    #
    #              # Iterate through entries list and appropriately place items in the output directory
    #              for custom_output_dir in args.custom_output_dir_entries_list:
    #                  # Manually go through the logic based on the attributes of the output directory
    #                  # Type 1: dir and files_list_str
    #                  if custom_output_dir.get("dir") is not None:
    #                      add_directory_to_output_directory(custom_output_dir.get("dir"),
    #                                                        custom_output_dir.get("files_list_str", None),
    #                                                        args.output_directory_name,
    #                                                        custom_output_dir.get("collection_name", None),
    #                                                        custom_output_dir.get("copy_method", None))
    #                  # Type 2: array of files
    #                  elif custom_output_dir.get("file_list") is not None:
    #                      add_file_list_to_output_directory(custom_output_dir.get("file_list"),
    #                                                        args.output_directory_name,
    #                                                        custom_output_dir.get("collection_name"),
    #                                                        custom_output_dir.get("copy_method", None))
    #                  # Type 3: A compressed tarball
    #                  elif custom_output_dir.get("tarball") is not None:
    #                      add_tarball_to_output_directory(custom_output_dir.get("tarball"),
    #                                                      custom_output_dir.get("files_list_str", None),
    #                                                      args.output_directory_name,
    #                                                      custom_output_dir.get("collection_name"),
    #                                                      custom_output_dir.get("copy_method"))
    #
    #
    #          if __name__ == "__main__":
    #              main()



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
      prefix: "--output-directory-name"
  custom_output_dir_entry_list:
    label: Custom output dir entry list
    doc: |
      The list of file entries
    type:
      - type: array
        items: ../../../schemas/custom-output-dir-entry/2.0.0/custom-output-dir-entry__2.0.0.yaml#custom-output-dir-entry
        inputBinding:
          prefix: "--custom-output-dir-entry="
          position: 2
          separate: false
          valueFrom: |
            ${
              /*
              Initialise with string sets
              */
              var new_obj = {};
              for (var key_name in self) {
                  /*
                  Check value is defined
                  */
                  if (self[key_name] === null){
                    continue;
                  }

                  /*
                  Get new key output object by using get_custom_dir_schema_input_by_key function
                  */
                  var new_json_element = get_custom_dir_schema_input_by_key(self, key_name, runtime.outdir, false);
                  if (Array.isArray(self[key_name])){
                    new_obj[key_name] = new_json_element;
                  } else {
                    new_obj[key_name] = new_json_element[0];
                  }
              }
              return JSON.stringify(new_obj);
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
