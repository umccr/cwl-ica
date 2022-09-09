cwlVersion: v1.1
class: ExpressionTool

# Extensions
$namespaces:
    s: https://schema.org/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
    class: s:Person
    s:name: Alexis Lucattini
    s:email: Alexis.Lucattini@umccr.org
    s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema--1.2.2--0
label: create-predefined-mount-paths-and-umccrise-row-from-umccrise-schema v(1.2.2--0)
doc: |
    Create the predefined mount paths and the umccrise row json str from the umccrise schema.

    The predefined mount paths have the following attributes:
      * file_obj | dir_obj
      * mount_path

requirements:
  SchemaDefRequirement:
    types:
      - $import: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml
      - $import: ../../../schemas/umccrise-input/1.2.2--0/umccrise-input__1.2.2--0.yaml
  InlineJavascriptRequirement:
    expressionLib:
      - var get_uuid = function(){
          /*
          From https://www.w3resource.com/javascript-exercises/javascript-math-exercise-23.php
          */
          var dt = new Date().getTime();
          var uuid = "xxxxxxxx-xxxx-xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c=="x" ? r :(r&0x3|0x8)).toString(16);
          });
          return uuid;
        }
      - var get_predefined_mount_paths_from_schema_object = function(schema_obj, key_name){
          /*
          Get the predefined mount paths
          If were handing the bam or vcf we also need to make sure were returning a predefined mount path for the
          secondary files attribute
          */

          /*
          Initialise variables
          */
          var uuid = get_uuid();
          var mount_paths = [];

          /*
          If directory, simple just append
          */
          if (schema_obj[key_name].class === "Directory"){
            mount_paths.push({
              "file_obj":schema_obj[key_name],
              "mount_path":"inputs" + "/" + uuid + "/" + schema_obj[key_name].basename
            });
            return mount_paths;
          }

          /*
          Things get a little more complicated when dealing with files (since we want to flatten and treat
          secondary files like other files)
          */

          /*
          First do a deep copy the object
          */
          var main_file = JSON.parse(JSON.stringify(schema_obj[key_name]));

          /*
          And drop the secondary files from the main file object
          */
          main_file["secondaryFiles"] = [];

          /*
          And add to mount paths
          */
          mount_paths.push({
            "file_obj":main_file,
            "mount_path":"inputs" + "/" + uuid + "/" + main_file.basename
          });

          /*
          THEN add any secondary files that might be present from the original object
          */
          if (schema_obj[key_name].secondaryFiles !== null){
            for (var secondary_file_iter=0; secondary_file_iter < schema_obj[key_name].secondaryFiles.length; secondary_file_iter++){
              mount_paths.push({
                "file_obj":schema_obj[key_name].secondaryFiles[secondary_file_iter],
                "mount_path":"inputs" + "/" + uuid + "/" + schema_obj[key_name].secondaryFiles[secondary_file_iter].basename
              });
            }
          }

          /*
          Now we can return the array of mount paths
          */
          return mount_paths;
        }

inputs:
  umccrise_input_rows:
    label: umccrise input rows
    doc: |
      Array of umccrise input schemas
    type: ../../../schemas/umccrise-input/1.2.2--0/umccrise-input__1.2.2--0.yaml#umccrise-input[]

outputs:
  predefined_mount_paths:
    label: predefined mount paths
    doc: |
      Array of predefined mount paths to be mounted on the umccrise TES task
    type: ../../../schemas/predefined-mount-path/1.0.0/predefined-mount-path__1.0.0.yaml#predefined-mount-path[]
  umccrise_input_rows_as_json_str:
    label: umccrise input rows as json str
    doc: |
      Array of jsonised strings ready to create the umccrise tsv
    type: string[]


expression: |
  ${
    /*
    Initialise output variables
    */
    var predefined_mount_paths = [];
    var umccrise_input_rows_as_json_str = [];

    /*
    Iterate through umccrise input rows
    */
    for (var umccrise_input_row_iter=0; umccrise_input_row_iter < inputs.umccrise_input_rows.length; umccrise_input_row_iter++){
      /*
      Iterate through umccrise input row, append to array of predefined mount paths, append to json strings
      */
      var umccrise_input_row = inputs.umccrise_input_rows[umccrise_input_row_iter];

      /*
      Initialise this string as a json row
      */
      var umccrise_input_row_as_json_str = {};

      for (var key_name in umccrise_input_row){
        /*
        Some keys are optional, check if not null
        */
        if (umccrise_input_row[key_name] === null){
          continue;
        }

        /*
        Initialise umccrise element since we cannot push a dict with a new key name - see
        https://stackoverflow.com/questions/11508463/javascript-set-object-key-by-variable
        */
        var umccrise_input_row_element = {}

        /*
        Check if just a string add to row and then
        */
        if (umccrise_input_row[key_name].class !== "File" && umccrise_input_row[key_name].class !== "Directory"){
          umccrise_input_row_as_json_str[key_name] = umccrise_input_row[key_name]
          continue;
        }

        /*
        Add input json strs
        */
        var key_predefined_mount_paths = get_predefined_mount_paths_from_schema_object(umccrise_input_row, key_name);

        /*
        Append to full list
        */
        predefined_mount_paths = predefined_mount_paths.concat(key_predefined_mount_paths);

        /*
        Just get the mount path of the first item (secondaryFiles are included afterwards)
        */
        umccrise_input_row_as_json_str[key_name] = key_predefined_mount_paths[0]["mount_path"]
      }

      /*
      Append input row
      */
      umccrise_input_rows_as_json_str.push(JSON.stringify(umccrise_input_row_as_json_str));
    }

    /*
    Now return the outputs as a dict
    */
    return {
              "predefined_mount_paths": predefined_mount_paths,
              "umccrise_input_rows_as_json_str": umccrise_input_rows_as_json_str
           };
  }
