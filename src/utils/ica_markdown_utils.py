#!/usr/bin/env python

"""
Functions used by GitHub actions to create the ICA section of the markdown file

## ICA Specific
get_ica_section -> Creates and renders the ica section of the markdown document

get_ica_project_section -> Creates and renders an ica project section of the markdown document

get_ica_workflow_runs -> Get the runs that match this workflow

get_ica_run_section -> Creates and renders an ica run section of the markdown document

create_run_graph -> Create a stacked bar plot of the ica task runs for a given run instance
"""
import datetime

import pandas as pd
import json

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.ticker import FuncFormatter
from pathlib import Path

from mdutils import MdUtils
from utils.repo import get_gh_run_graphs_dir, get_run_yaml_path, read_yaml
from utils.miscell import get_raw_url_from_path, get_items_dir_from_cwl_file_path
from os.path import relpath
from datetime import datetime, timedelta

# For typing
from typing import List
from classes.project import Project
from classes.ica_workflow import ICAWorkflow
from classes.ica_workflow_version import ICAWorkflowVersion
from classes.ica_workflow_run import ICAWorkflowRun
from subcommands.github_actions.create_markdown_file import add_toc_line

def get_ica_section(cwl_file_path: Path, projects: List[Project],
                    ica_workflow_objs: List[ICAWorkflow],
                    ica_workflow_version_objs: List[ICAWorkflowVersion],
                    md_file_obj: MdUtils, markdown_path: Path) -> MdUtils:
    """
    Returns the ica section for a md file object
    :param cwl_file_path,
    :param projects,
    :param ica_workflow_objs
    :param ica_workflow_version_objs,
    :param md_file_obj:
    :param markdown_path:
    :return:
    """

    # Create title section
    md_file_obj.new_header(level=2, title=f"ICA", add_table_of_contents="n")

    # Add toc for projects
    md_file_obj.new_header(level=3, title=f"ToC", add_table_of_contents="n")
    for project in projects:
        md_file_obj = add_toc_line(md_file_obj, header_name=f"Project: {project.project_name}",
                                   link_text=project.project_name)
    md_file_obj.new_line("\n")

    # Collect projects list
    for project, ica_workflow, ica_workflow_version in zip(projects, ica_workflow_objs, ica_workflow_version_objs):
        # Create title section for project name
        md_file_obj.new_header(level=3, title=f"Project: {project.project_name}", add_table_of_contents="n")

        # Add workflow id and workflow version
        md_file_obj.new_paragraph(f"> wfl id: {ica_workflow_version.ica_workflow_id}")
        md_file_obj.new_line("\n")
        md_file_obj.new_line(f"**workflow name:** {ica_workflow.ica_workflow_name}")
        md_file_obj.new_line(f"**wfl version name:** {ica_workflow_version.ica_workflow_version_name}")
        md_file_obj.new_line("\n")

        if len(ica_workflow_version.run_instances) == 0:
            continue

        # Create section header
        md_file_obj.new_header(level=4, title="Run Instances", add_table_of_contents="n")

        # Iterate through run instances
        run_objs: List[ICAWorkflowRun] = [get_run_instance_obj_from_id(run_instance_id)
                                          for run_instance_id in ica_workflow_version.run_instances]

        for run_obj in run_objs:
            # Create a run section header
            md_file_obj.new_header(level=5, title=f"Run {run_obj.ica_workflow_run_instance_id}", add_table_of_contents="n")

            # Add the run instance name
            md_file_obj.new_paragraph("\n")
            md_file_obj.new_line(f"> Run Name: {run_obj.ica_workflow_run_name}")

            # Add the run instance metadata
            md_file_obj.new_line("\n")

            md_file_obj.new_line(f"**Start Time:** {datetime.fromtimestamp(run_obj.workflow_start_time)} UTC")
            md_file_obj.new_line(f"**Duration:** {datetime.fromtimestamp(run_obj.workflow_end_time)} UTC")
            md_file_obj.new_line(f"**End Time:** {pd.to_timedelta(run_obj.workflow_duration, unit='seconds')}")
            md_file_obj.new_line("\n")

            md_file_obj.new_header(level=6, title=f"Run Inputs", add_table_of_contents="n")
            md_file_obj.insert_code(json.dumps(run_obj.ica_input, indent=4))
            md_file_obj.new_line("\n")

            md_file_obj.new_header(level=6, title=f"Run Engine Parameters", add_table_of_contents="n")
            md_file_obj.insert_code(json.dumps(run_obj.ica_engine_parameters, indent=4))
            md_file_obj.new_line("\n")

            md_file_obj.new_header(level=6, title=f"Run Outputs", add_table_of_contents="n")
            md_file_obj.insert_code(json.dumps(run_obj.ica_output, indent=4))
            md_file_obj.new_line("\n")

            # Get the run graph
            md_file_obj.new_header(level=6, title=f"Run Resources Usage", add_table_of_contents="n")
            run_graph_path = get_run_graph_path(cwl_file_path, ica_workflow, ica_workflow_version, run_obj)
            md_file_obj.new_line("\n")

            # Create the run graph dir if it doesn't exist
            if not run_graph_path.parent.is_dir():
                run_graph_path.parent.mkdir(parents=True, exist_ok=True)

            # Get relative path and urls for run image
            run_graph_rel_path = relpath(run_graph_path.absolute(), markdown_path.absolute().parent)
            run_graph_raw_path = get_raw_url_from_path(run_graph_path)
            build_ica_run_graph(run_obj, run_graph_path)

            # Add the run instance graph
            md_file_obj.new_line("{}".format(
                    md_file_obj.new_inline_link(
                        link=run_graph_raw_path,
                        text=md_file_obj.new_inline_image(
                            path=run_graph_rel_path,
                            text=run_graph_path.name
                        )
                    )
                ),
                wrap_width=0
            )
            md_file_obj.new_line("\n")

    md_file_obj.new_line("\n")

    return md_file_obj


def get_run_graph_path(cwl_file_path: Path, ica_workflow: ICAWorkflow, ica_workflow_version: ICAWorkflowVersion, ica_workflow_run: ICAWorkflowRun) -> Path:
    """
    Get the run graph path from the ica workflow version name and version name
    :param cwl_file_path:
    :param ica_workflow: ICAWorkflow
    :param ica_workflow_version:
    :param ica_workflow_run:
    :return:
    """

    return get_gh_run_graphs_dir() / \
           get_items_dir_from_cwl_file_path(cwl_file_path).name / \
           ica_workflow.name / \
           ica_workflow_version.name / \
           (ica_workflow_run.ica_workflow_run_name + "__" + ica_workflow_run.ica_workflow_run_instance_id + ".svg")


def get_run_instance_obj_from_id(run_instance_id: str) -> ICAWorkflowRun:
    """
    Get the run instance id
    :param run_instance_id:
    :return: run obj: ICAWorkflowRun
    """
    # Get run objects
    run_objs: List[ICAWorkflowRun] = [ICAWorkflowRun.from_dict(run_dict)
                                      for run_dict in read_yaml(get_run_yaml_path())["runs"]]

    for run_obj in run_objs:
        if run_obj.ica_workflow_run_instance_id == run_instance_id:
            return run_obj


def build_ica_run_graph(workflow_run_obj: ICAWorkflowRun, graph_path: Path):
    """
    Build a stack plot from ICA by collecting the task run ids of a workflow run object and displaying the graph
    :return:
    """

    # Collate tasks
    cpu_dfs = []
    cpu_capacity_dfs = []
    memory_dfs = []
    memory_capacity_dfs = []

    # Task period range
    tasks_period_range = pd.timedelta_range(start=0,
                                            end=datetime.fromtimestamp(workflow_run_obj.workflow_end_time) -
                                                datetime.fromtimestamp(workflow_run_obj.workflow_start_time),
                                            freq="T")

    for task_run_obj in workflow_run_obj.ica_task_objs:
        # Get task name
        task_name = task_run_obj.task_name

        # Get task data frame
        task_df: pd.DataFrame = task_run_obj.task_metrics.copy()

        # Skip if no data
        if task_df.shape[0] == 0:
            continue

        # Convert timestamp to datetime object
        task_df['timestamp_dt'] = task_df['timestamp'].apply(datetime.fromtimestamp)
        task_df["timedelta_dt"] = task_df["timestamp_dt"] - datetime.fromtimestamp(workflow_run_obj.workflow_start_time)

        # Add capacity vals to the dataframe
        task_df["cpu_capacity"] = task_run_obj.task_cpus
        task_df["memory_capacity"] = task_run_obj.task_memory

        # Resample on new frequency and take the average value for cpu and mem
        task_df = task_df.resample('T', on="timedelta_dt").mean()

        # Reindex on the new period range -
        # We allow ourselves to fill 1 space forward
        task_df = task_df.reindex(tasks_period_range, method="ffill", limit=1)

        # Fill missing data with pad
        # We then also allow ourselves to fill backwards one space
        task_df = task_df.fillna(method="pad", limit=1)

        # Add the task name
        task_df["task_name"] = task_name

        # Also reset and rename the index, then put back to index
        task_df = task_df.reset_index().rename(columns={"index": "timedelta_dt"}).set_index("timedelta_dt")

        # Append cpus dfs and mem dfs with the task name
        cpu_dfs.append(task_df[["cpu", "task_name"]])
        cpu_capacity_dfs.append(task_df[["cpu_capacity", "task_name"]])

        memory_dfs.append(task_df[["memory", "task_name"]])
        memory_capacity_dfs.append(task_df[["memory_capacity", "task_name"]])

    # Now do a length-wise concat for cpu dfs and mem dfs we will then pivot with a sum in each collision
    cpu_df: pd.DataFrame = pivot_short_on_time_index(pd.concat(cpu_dfs, axis="rows"), metric="cpu")
    memory_df: pd.DataFrame = pivot_short_on_time_index(pd.concat(memory_dfs, axis="rows"), metric="memory")
    cpu_capacity_df: pd.DataFrame = pivot_short_on_time_index(pd.concat(cpu_capacity_dfs, axis="rows"), metric="cpu_capacity")
    memory_capacity_df: pd.DataFrame = pivot_short_on_time_index(pd.concat(memory_capacity_dfs, axis="rows"), metric="memory_capacity")

    # Get the labels for the legent
    stack_labels = cpu_df.columns.tolist()

    # Get colours for plots
    my_rbg = get_colours()

    # Get figure and subplots
    fig, ax = plt.subplots(1, 2)
    fig.suptitle(f'Resources Used for {workflow_run_obj.ica_workflow_run_name}')
    fig.set_size_inches(40, 20)

    plt.figtext(x=0.5, y=0.04, s="(Shaded=CPU / Mem Usage, Unshaded=Allocated but unused)",
                horizontalalignment='center')

    # Plot cpus and memory on stacked area chart

    # First plot the capacity dfs in solid
    ax[0].stackplot(cpu_capacity_df.reset_index()['timedelta_dt'].apply(lambda x: x.total_seconds()),
                    cpu_capacity_df.fillna(0).transpose(),
                    colors=my_rbg, labels=stack_labels)

    # Then plot the cpu usage over the top on the same plot
    ax[0].stackplot(cpu_df.reset_index()['timedelta_dt'].apply(lambda x: x.total_seconds()),
                    cpu_df.fillna(0).transpose(),
                    colors=my_rbg, alpha=0.5,
                    hatch='//')

    # Do the same for memory

    # First plot the capacity memory dfs in solid
    ax[1].stackplot(memory_capacity_df.reset_index()['timedelta_dt'].apply(lambda x: x.total_seconds()),
                    memory_capacity_df.fillna(0).transpose(),
                    colors=my_rbg, labels=stack_labels)

    # Then plot the memory usage over the top on the same plot
    ax[1].stackplot(memory_df.reset_index()['timedelta_dt'].apply(lambda x: x.total_seconds()),
                    memory_df.fillna(0).transpose(),
                    colors=my_rbg, alpha=0.5,
                    hatch='//')

    # Set titles
    ax[0].set_title("CPU Resources Over Time")
    ax[1].set_title("Memory Resources overtime")

    # Remove xlabel
    ax[0].set_xlabel('Time (HH:MM)', fontsize=10)
    ax[1].set_xlabel('Time (HH:MM)', fontsize=10)

    # Set the x and y limits
    ax[0].set_xlim(left=0)
    ax[1].set_xlim(left=0)
    ax[0].set_ylim(bottom=0)
    ax[1].set_ylim(bottom=0)

    # Set legend for axis 1
    leg_labels = []
    leg_handles = []
    handles, labels = ax[0].get_legend_handles_labels()
    for handle, label in zip(handles, labels):
        if label in stack_labels:
            leg_labels.append(label)
            leg_handles.append(handle)

    ax[0].legend(leg_handles, leg_labels)

    # Set legend for axis 2
    leg_labels = []
    leg_handles = []
    handles, labels = ax[1].get_legend_handles_labels()
    for handle, label in zip(handles, labels):
        if label in stack_labels:
            leg_labels.append(label)
            leg_handles.append(handle)

    # Add legend to right plot
    ax[1].legend(leg_handles, leg_labels)

    # Set the time values as human friendly
    ax[0].xaxis.set_major_formatter(FuncFormatter(convert_seconds_to_hh_mm_formatter))
    ax[1].xaxis.set_major_formatter(FuncFormatter(convert_seconds_to_hh_mm_formatter))

    # Set the axis labels
    ax[0].set_ylabel("CPUs")
    ax[1].set_ylabel("Memory (GB)")

    # Squish everything up nicely
    #fig.tight_layout()

    # Give the top title a bit of room
    fig.subplots_adjust(top=0.9)

    # Save figure to graph path
    fig.savefig(graph_path)

    # Close the plot (save displaying it)
    plt.close('all')


def convert_seconds_to_hh_mm_formatter(td_float: float, pos):
    hours_per_day = 24
    seconds_per_hour = 3600
    minutes_per_hour = 60
    seconds_per_minute = 60
    td = timedelta(seconds=td_float)
    return "%s:%s" % (
        str(( td.days * hours_per_day ) + ( td.seconds // seconds_per_hour )).zfill(2),
        str(( td.seconds // seconds_per_minute ) % minutes_per_hour).zfill(2)
    )


def pivot_short_on_time_index(long_table, metric):
    """
    Pivot a long table to short whilst keeping the time period index in place
    :param long_table: pd.DataFrame
    :param metric: str - one of cpu, memory, cpu_capacity, memory_capacity
    :return:
    """
    # Assums a long table with the timedelta_dt as the index
    pivot_table = long_table.reset_index().pivot_table(index="timedelta_dt",
                                                       values=metric,
                                                       columns="task_name", aggfunc=np.sum)

    # Flatten multi-hierarchy index
    pivot_table.columns = pivot_table.columns.tolist()

    # Return pivot table
    return pivot_table


def colours_to_rgb(red, blue, green):
    return '#%s%s%s' % (int_to_hex(red), int_to_hex(blue), int_to_hex(green))


def int_to_hex(my_int):
    return format(int(255*my_int), '02x')


def get_colours():
    """
    Get the colours
    :return:
    """

    colours = plt.cm.tab20.colors
    # Flip each pair of the tab 20
    colours = [*sum(zip(colours[1::2], colours[0::2]), ())]

    return [colours_to_rgb(*colour) for colour in colours]