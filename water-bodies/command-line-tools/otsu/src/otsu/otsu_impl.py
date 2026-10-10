"""Otsu water mask processing."""

from pathlib import Path

import click
import numpy as np
import rasterio
from loguru import logger
from skimage.filters import threshold_otsu


def threshold(data: np.ndarray) -> np.ndarray:
    """Threshold finite raster values; mark nonfinite pixels as non-water."""
    finite = np.isfinite(data)
    if not finite.any():
        raise ValueError("Raster has no finite values for Otsu thresholding")
    cutoff = threshold_otsu(data[finite])
    logger.info("Otsu threshold: {}", cutoff)
    return (finite & (data > cutoff)).astype(np.uint8)


def execute(*, raster: str | Path) -> None:
    """Write an unsigned-byte binary mask to otsu.tif."""
    try:
        logger.info("Reading {}", raster)
        with rasterio.open(raster) as source:
            data = source.read(1)
            metadata = source.meta.copy()
        result = threshold(data)
        metadata.update(
            driver="COG",
            dtype="uint8",
            count=1,
            nodata=None,
            compress="LZW",
            blocksize=256,
        )
        logger.info("Writing otsu.tif")
        with rasterio.open("otsu.tif", "w", **metadata) as output:
            output.write(result, 1)
        logger.success("Wrote otsu.tif")
    except (ValueError, OSError, rasterio.errors.RasterioError) as exc:
        logger.error("Otsu thresholding failed: {}", exc)
        raise click.ClickException(str(exc)) from exc
