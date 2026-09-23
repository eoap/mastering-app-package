"""Exercise raster processing with local fixtures."""

from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import pystac
import pytest
import rasterio
from click.testing import CliRunner
from rasterio.transform import from_origin

from stac.cli import stac


@pytest.fixture
def raster_factory(tmp_path):
    def write(name, data):
        path = tmp_path / name
        data = np.asarray(data, dtype="float32")
        with rasterio.open(
            path,
            "w",
            driver="GTiff",
            width=data.shape[1],
            height=data.shape[0],
            count=1,
            dtype="float32",
            crs="EPSG:4326",
            transform=from_origin(0, 2, 1, 1),
        ) as dst:
            dst.write(data, 1)
        return str(path)

    return write


@pytest.mark.parametrize("staged", [False, True])
def test_catalog(raster_factory, tmp_path, monkeypatch, staged):
    raster = raster_factory("mask.tif", [[0, 1], [1, 0]])
    source = pystac.Item(
        "scene",
        geometry=None,
        bbox=None,
        datetime=datetime(2026, 1, 1, tzinfo=timezone.utc),
        properties={},
    )
    source.set_self_href(str(tmp_path / "source.json"))
    source.save_object()
    location = source.get_self_href()
    if staged:
        catalog = pystac.Catalog("source", "Source catalog")
        catalog.add_item(source)
        catalog.set_self_href(str(tmp_path / "catalog.json"))
        catalog.save_object()
        location = str(tmp_path)
    work = tmp_path / "output"
    work.mkdir()
    monkeypatch.chdir(work)
    result = CliRunner().invoke(stac, ["--input-item", location, "--water-body", raster])
    assert result.exit_code == 0, result.output
    catalog = pystac.Catalog.from_file("catalog.json")
    item = next(catalog.get_items())
    assert item.id == "scene"
    assert item.datetime == source.datetime
    assert Path(item.assets["data"].get_absolute_href()).is_file()
    assert Path(item.assets["data"].href) == Path("mask.tif")


def test_mismatched_counts(raster_factory):
    raster = raster_factory("mask.tif", [[0, 1]])
    result = CliRunner().invoke(stac, ["--input-item", "a", "--input-item", "b", "--water-body", raster])
    assert result.exit_code == 1
    assert "same nonzero number" in result.output
