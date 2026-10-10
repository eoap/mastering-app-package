"""Exercise the unchanged generated CLI with real local STAC and raster inputs."""

import json
from datetime import datetime, timezone

import numpy as np
import pystac
import pytest
import rasterio
from click.testing import CliRunner
from rasterio.transform import from_origin

from crop.cli import crop
from crop.crop_impl import _needs_signing


@pytest.fixture
def source(tmp_path):
    pixels = np.arange(100, dtype="float32").reshape(10, 10)
    with rasterio.open(
        tmp_path / "source.tif",
        "w",
        driver="GTiff",
        width=10,
        height=10,
        count=1,
        dtype="float32",
        crs="EPSG:4326",
        transform=from_origin(0, 10, 1, 1),
        nodata=-9999,
    ) as dst:
        dst.write(pixels, 1)
    item = pystac.Item(
        "source",
        geometry={
            "type": "Polygon",
            "coordinates": [[[0, 0], [10, 0], [10, 10], [0, 10], [0, 0]]],
        },
        bbox=[0, 0, 10, 10],
        datetime=datetime.now(timezone.utc),
        properties={},
    )
    item.add_asset(
        "green",
        pystac.Asset(
            "./source.tif",
            roles=["data"],
            extra_fields={"eo:bands": [{"common_name": "green"}]},
        ),
    )
    item.set_self_href(str(tmp_path / "item.json"))
    item.save_object()
    return item, pixels


@pytest.mark.parametrize("geojson", [False, True])
def test_cli_crops_local_asset(source, tmp_path, monkeypatch, geojson):
    item, pixels = source
    monkeypatch.chdir(tmp_path)
    aoi = (
        json.dumps(
            {
                "type": "Polygon",
                "coordinates": [[[2, 4], [5, 4], [5, 8], [2, 8], [2, 4]]],
            }
        )
        if geojson
        else "2,4,5,8"
    )
    result = CliRunner().invoke(
        crop,
        [
            "--input-item",
            item.get_self_href(),
            "--aoi",
            aoi,
            "--epsg",
            "4326",
            "--band",
            "green",
        ],
    )
    assert result.exit_code == 0, result.output
    with rasterio.open(tmp_path / "crop_green.tif") as output:
        np.testing.assert_array_equal(output.read(1), pixels[2:6, 2:5])
        assert output.transform == from_origin(2, 8, 1, 1)
        assert output.dtypes == ("float32",)
        assert output.nodata == -9999
        assert output.tags(ns="IMAGE_STRUCTURE")["LAYOUT"] == "COG"


def test_catalog_input(source, tmp_path, monkeypatch):
    item, _ = source
    catalog = pystac.Catalog("staged", "Staged input")
    catalog.add_item(item)
    catalog.set_self_href(str(tmp_path / "catalog.json"))
    catalog.save_object()
    monkeypatch.chdir(tmp_path)
    result = CliRunner().invoke(
        crop,
        [
            "--input-item",
            str(tmp_path),
            "--aoi",
            "2,4,5,8",
            "--epsg",
            "4326",
            "--band",
            "green",
        ],
    )
    assert result.exit_code == 0, result.output
    assert (tmp_path / "crop_green.tif").exists()


def test_missing_band_reports_error(source, tmp_path, monkeypatch):
    item, _ = source
    monkeypatch.chdir(tmp_path)
    result = CliRunner().invoke(
        crop,
        [
            "--input-item",
            item.get_self_href(),
            "--aoi",
            "2,4,5,8",
            "--epsg",
            "4326",
            "--band",
            "nir",
        ],
    )
    assert result.exit_code == 1
    assert "Common band name nir not found" in result.output
    assert not (tmp_path / "crop_nir.tif").exists()


@pytest.mark.parametrize(
    "href, expected",
    [
        ("https://example.blob.core.windows.net/a.tif", True),
        ("https://example.blob.core.windows.net/a.tif?se=tomorrow", False),
        ("https://ai4edatasetspublicassets.blob.core.windows.net/a.tif", False),
        ("https://example.org/a.tif", False),
        ("./source.tif", False),
    ],
)
def test_signing_detection(href, expected):
    assert _needs_signing(href) is expected
