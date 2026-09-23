"""Normalized difference raster processing."""

from pathlib import Path

import click
import numpy as np
import rasterio
from loguru import logger


def _calculate(rasters: tuple[str | Path, ...]) -> tuple[np.ndarray, dict]:
    if len(rasters) != 2:
        raise ValueError("Exactly two rasters are required")
    with rasterio.open(rasters[0]) as first, rasterio.open(rasters[1]) as second:
        grid1 = (first.shape, first.transform, first.crs)
        grid2 = (second.shape, second.transform, second.crs)
        if grid1 != grid2:
            raise ValueError(
                "Input rasters must have matching dimensions, transform, and CRS"
            )
        a = first.read(1).astype(np.float32)
        b = second.read(1).astype(np.float32)
        metadata = first.meta.copy()
    with np.errstate(divide="ignore", invalid="ignore"):
        result = (a - b) / (a + b)
    return result, metadata


def execute(*, rasters: tuple[str | Path, ...]) -> None:
    """Write the normalized difference to norm_diff.tif."""
    try:
        logger.info("Calculating normalized difference from {}", rasters)
        data, metadata = _calculate(rasters)
        metadata.update(
            driver="COG", dtype="float32", count=1, compress="LZW", blocksize=256
        )
        logger.info("Writing norm_diff.tif")
        with rasterio.open("norm_diff.tif", "w", **metadata) as output:
            output.write(data, 1)
        logger.success("Wrote norm_diff.tif")
    except (ValueError, OSError, rasterio.errors.RasterioError) as exc:
        logger.error("Normalized difference failed: {}", exc)
        raise click.ClickException(str(exc)) from exc
