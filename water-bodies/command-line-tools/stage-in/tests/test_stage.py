"""Verify the dependency-provided staging CLI remains available."""

from importlib.metadata import distribution

from click.testing import CliRunner


def test_stac_asset_cli():
    entry = next(e for e in distribution("stac-asset").entry_points if e.name == "stac-asset")
    result = CliRunner().invoke(entry.load(), ["--help"])
    assert result.exit_code == 0, result.output
    assert "download" in result.output
