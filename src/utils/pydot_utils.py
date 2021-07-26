#!/usr/bin/env python

"""
Functions to assist with building the cwl graph in the markdown report

build_cwl_dot -> Runs the cwltool --print-dot and writes to tmp file

edit_cwl_dot -> reads in the dot file and updates inputs / steps and outputs
             -> Updates links by setting urls in each

build_cwl_svg -> takes in a dot file and generates an svg file through the graphviz binary
"""
import subprocess

from pydot import graph_from_dot_file, Dot

from utils.subprocess_handler import run_subprocess_proc
from utils.logging import get_logger
from tempfile import NamedTemporaryFile
from pathlib import Path
from classes.cwl import CWL
from utils.miscell import get_name_version_tuple_from_cwl_file_path, get_items_dir_from_cwl_file_path, \
    get_blob_url_to_markdown_file_from_cwl_path

logger = get_logger()


def build_cwl_dot(cwl_item: CWL, dot_out_path: Path):
    """
    Run cwltool --print-dot and write to file
    :return:
    """

    # First pack the cwl file (adds consistency in the dot object)
    cwl_packed_temp_file = NamedTemporaryFile()
    cwl_item.run_cwltool_pack(cwl_packed_temp_file)

    with open(str(dot_out_path), 'w') as write_h:
        build_returncode, _, build_stderr = run_subprocess_proc(["cwltool", "--print-dot", cwl_packed_temp_file.name],
                                                                stdout=write_h, stderr=subprocess.PIPE)


def edit_cwl_dot(cwl_item, cwl_obj, dot_path: Path):
    """
    Edit inputs / outputs:
      set 'tool tip' to be the doc string for each input and output

    Edit steps:
      Set the url of each node to be the markdown file of said tool / workflow
      Set the tool tip of each node to be the documentation of said step
      Colour node light purple if step is a workflow
    :return:
    """
    # Use pydot to open the dot object
    dot_obj: Dot = graph_from_dot_file(dot_path)[0]

    # Set tool tip on inputs and outputs
    for graph in dot_obj.get_subgraph_list():
        for node in graph.get_nodes():
            # Check inputs
            for i_o in cwl_obj.inputs + cwl_obj.outputs:
                if Path(i_o.id.rsplit("#", 1)[-1]).name == Path(node.get_name().strip('"').rsplit("#", 1)[-1]).name:
                    # Set tooltip as input doc
                    node.set_tooltip(i_o.doc)
                    break

    # Iterate through graph nodes and cwl steps
    for node in dot_obj.get_nodes():
        for step in cwl_obj.steps:
            if Path(step.id.rsplit("#", 1)[-1]).name == Path(node.get_name().strip('"').rsplit("#", 1)[-1]).name:
                # Colour node if workflow or expression?
                # Get step cwl object
                step_path = get_step_path_from_step_obj(step, cwl_item.cwl_file_path)
                # Get items dir from step path
                items_dir = get_items_dir_from_cwl_file_path(step_path)
                # Get step url from step path
                step_name, step_version = get_name_version_tuple_from_cwl_file_path(step_path, items_dir)
                # Get the path to the markdown file
                node.set_URL(get_blob_url_to_markdown_file_from_cwl_path(step_path))
                # Set the tool tip as the step doc
                node.set_tooltip(step.doc)
                # Get CWL step object
                step_cwl_obj = CWL(step_path, step_name, step_version)
                # Get step cwl object
                if step_cwl_obj.cwl_obj.class_ == "CommandLineTool":
                    continue
                elif step_cwl_obj.cwl_obj.class_ == "Workflow":
                    node.set_fillcolor("orchid2")
                elif step_cwl_obj.cwl_obj.class_ == "ExpressionTool":
                    node.set_fillcolor("orange2")

    dot_obj.write_dot(str(dot_path))


def get_step_path_from_step_obj(cwl_step_object, cwl_file_path) -> Path:
    """
    # Get the absolute path to the step
    step_object:
    :return:
    """
    step_cwl_path = cwl_file_path.parent.absolute().joinpath(Path(cwl_step_object.run)).resolve()

    return step_cwl_path


def build_cwl_svg(dot_file, output_file_path, ratio_value):
    """
    Build the svg file from the edited dot file to the path specified using graphviz
    We calculate the svg size by estimating the inputs / outputs to get the length
    :return:
    """
    dot_return_code, dot_stdout, dot_stderr = run_subprocess_proc(["dot",
                                                                   f"-Gratio={ratio_value}",
                                                                   "-Tsvg",
                                                                   f"-o{output_file_path}",
                                                                   f"{dot_file}"],
                                                                  capture_output=True)

