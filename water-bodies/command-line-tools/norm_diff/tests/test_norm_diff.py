"""Exercise raster processing with local fixtures."""

import numpy as np
import pytest
import rasterio
from click.testing import CliRunner
from rasterio.transform import from_origin

from norm_diff.cli import norm_diff


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


@pytest.mark.parametrize("option", [False, True])
def test_normalized_difference(raster_factory, tmp_path, monkeypatch, option):
    a = raster_factory("a.tif", [[3, 0], [1, 4]])
    b = raster_factory("b.tif", [[1, 0], [3, 4]])
    monkeypatch.chdir(tmp_path)
    result = CliRunner().invoke(norm_diff, (["--rasters"] if option else []) + [a, b])
    assert result.exit_code == 0, result.output
    with rasterio.open("norm_diff.tif") as output:
        np.testing.assert_allclose(output.read(1), [[0.5, np.nan], [-0.5, 0]], equal_nan=True)
        assert output.tags(ns="IMAGE_STRUCTURE")["LAYOUT"] == "COG"
        assert output.count == 1


def test_mismatched_grid(raster_factory, tmp_path, monkeypatch):
    a = raster_factory("a.tif", [[1, 2]])
    b = raster_factory("b.tif", [[1], [2]])
    monkeypatch.chdir(tmp_path)
    result = CliRunner().invoke(norm_diff, [a, b])
    assert result.exit_code == 1
    assert "matching dimensions" in result.output
    assert not (tmp_path / "norm_diff.tif").exists()


def test_missing_rasters():
    result = CliRunner().invoke(norm_diff, [])
    assert result.exit_code == 1
    assert "Exactly two" in result.output
