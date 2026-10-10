"""Verify the installed staging console entry point."""
from importlib.metadata import distribution
from click.testing import CliRunner


def test_stage_in_cli():
    entry = next(e for e in distribution('stage').entry_points if e.name == 'stage-in')
    result = CliRunner().invoke(entry.load(), ['--help'])
    assert result.exit_code == 0, result.output
    assert '--reference' in result.output
