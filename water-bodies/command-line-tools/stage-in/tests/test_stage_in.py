"""Test stage-in with local STAC assets."""

from datetime import datetime, timezone
from pathlib import Path

import pystac
from click.testing import CliRunner

from stage.stage_in_cli import stage_in


def test_stages_local_item(tmp_path, monkeypatch):
    source = tmp_path / "source"
    source.mkdir()
    asset = source / "data.txt"
    asset.write_text("local asset contents")
    item = pystac.Item(
        "scene",
        geometry=None,
        bbox=None,
        datetime=datetime(2026, 1, 1, tzinfo=timezone.utc),
        properties={},
    )
    item.add_asset("data", pystac.Asset("./data.txt", roles=["data"]))
    item.set_self_href(str(source / "item.json"))
    item.save_object()
    output = tmp_path / "output"
    output.mkdir()
    monkeypatch.chdir(output)
    result = CliRunner().invoke(stage_in, ["--reference", str(source / "item.json")])
    assert result.exit_code == 0, result.output
    assert Path.cwd() == output
    catalog = pystac.Catalog.from_file(str(output / "catalog.json"))
    staged = next(catalog.get_items())
    assert staged.id == "scene"
    local_asset = Path(staged.assets["data"].get_absolute_href())
    assert local_asset.is_relative_to(output / "scene")
    assert local_asset.read_text() == "local asset contents"
    assert not Path(staged.assets["data"].href).is_absolute()


def test_rejects_catalog(tmp_path, monkeypatch):
    catalog = pystac.Catalog("empty", "Empty catalog")
    catalog.set_self_href(str(tmp_path / "source.json"))
    catalog.save_object()
    monkeypatch.chdir(tmp_path)
    result = CliRunner().invoke(stage_in, ["--reference", str(tmp_path / "source.json")])
    assert result.exit_code == 1
    assert "must point to a STAC item" in result.output
    assert not (tmp_path / "catalog.json").exists()


def test_reference_required():
    result = CliRunner().invoke(stage_in, [])
    assert result.exit_code == 2
    assert "--reference" in result.output
