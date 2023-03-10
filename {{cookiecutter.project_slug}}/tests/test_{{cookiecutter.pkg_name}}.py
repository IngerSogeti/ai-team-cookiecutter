#!/usr/bin/env python
"""Tests for `{{ cookiecutter.pkg_name }}` package."""

import pytest
{% if cookiecutter.command_line_interface|lower == 'click' -%}
from click.testing import CliRunner
{%- endif %}
from requests import Response
{% if cookiecutter.command_line_interface|lower == 'click' -%}

from {{ cookiecutter.pkg_name }} import cli
{%- endif %}


@pytest.fixture()
def response() -> Response:
    """Sample pytest fixture.

    See more at: http://doc.pytest.org/en/latest/fixture.html
    """
    import requests

    return requests.get('https://github.com/audreyr/cookiecutter-pypackage')


def test_content(response: Response) -> None:
    """Sample pytest test function with the pytest fixture as an argument."""
    del response
    return None
{%- if cookiecutter.command_line_interface|lower == 'click' %}


def test_command_line_interface() -> None:
    """Test the CLI."""
    runner = CliRunner()

    result = runner.invoke(cli.main)

    assert result.exit_code == 0
    assert '{{ cookiecutter.project_slug }}' in result.output
    help_result = runner.invoke(cli.main, ['--help'])
    assert help_result.exit_code == 0
    assert '--help  Show this message and exit.' in help_result.output
{%- endif %}
