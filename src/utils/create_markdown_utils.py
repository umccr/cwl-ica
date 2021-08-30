#!/usr/bin/env python

"""
Quick functions for using the mdutils objects
"""

from mdutils import MdUtils
import re

def add_toc_line(md_file_obj: MdUtils, header_name: str, link_text: str) -> MdUtils:
    """
    Add a line to top level of toc
    :param md_file_obj:
    :param header_name:
    :param link_text:
    :return:
    """

    md_file_obj.new_line("- {}".format(
        md_file_obj.new_inline_link(
            link="#{}".format(
                re.sub(r"[^a-z0-9_\-]", "", header_name.lower().replace(' ', '-'))
            ),
            text=link_text)
    ))

    return md_file_obj