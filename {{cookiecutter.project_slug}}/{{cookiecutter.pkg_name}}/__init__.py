"""Top-level package for {{ cookiecutter.project_name }}."""

__author__ = """{{ cookiecutter.full_name }}"""
__email__ = '{{ cookiecutter.email }}'
{%- if cookiecutter.use_bump2version == 'True' %}
# Do not edit the version manually, let `make bump` do it.
{%- endif %}
__version__ = '{{ cookiecutter.version }}'

import platform
import sys
from textwrap import dedent


def version_info() -> str:
    """Display the version of the program, python and the platform."""
    return dedent(
        f"""\
        ------------------------------------------------------------------
             {{cookiecutter.pkg_name}}: {__version__}
             Python: {sys.version.split(" ", maxsplit=1)[0]}
             Platform: {platform.platform()}
        ------------------------------------------------------------------"""
    )
