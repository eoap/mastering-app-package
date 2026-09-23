"""Exercise raster processing with local fixtures."""

import numpy as np
import pytest
import rasterio
from click.testing import CliRunner
from rasterio.transform import from_origin

from otsu.cli import otsu


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


def test_binary_mask(raster_factory, tmp_path, monkeypatch):
    raster = raster_factory("input.tif", [[0, 0, np.nan], [10, 10, np.inf]])
    monkeypatch.chdir(tmp_path)
    result = CliRunner().invoke(otsu, [raster])
    assert result.exit_code == 0, result.output
    with rasterio.open("otsu.tif") as output:
        np.testing.assert_array_equal(output.read(1), [[0, 0, 0], [1, 1, 0]])
        assert output.dtypes == ("uint8",)
        assert output.nodata is None
        assert output.tags(ns="IMAGE_STRUCTURE")["LAYOUT"] == "COG"


def test_no_finite_values(raster_factory, tmp_path, monkeypatch):
    raster = raster_factory("invalid.tif", [[np.nan, np.inf]])
    monkeypatch.chdir(tmp_path)
    result = CliRunner().invoke(otsu, [raster])
    assert result.exit_code == 1
    assert "no finite values" in result.output
    assert not (tmp_path / "otsu.tif").exists()
