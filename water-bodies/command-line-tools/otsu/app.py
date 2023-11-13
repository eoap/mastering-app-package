"""Command line tool to apply the Otsu threshold to a raster"""
import click
import rasterio
import numpy as np
from skimage.filters import threshold_otsu
from loguru import logger


def threshold(data):
    """Returns the Otsu threshold of a numpy array"""
    return data > threshold_otsu(data[np.isfinite(data)])


@click.command(
    short_help="Otsu threshoold",
    help="Applies the Otsu threshold",
)
@click.argument("raster", nargs=1)
def otsu(raster):
    """Applies the Otsu threshold"""

    with rasterio.open(raster) as ds:
        array = ds.read(1)
        out_meta = ds.meta.copy()

    out_meta.update(
        {
            "dtype": "uint8",
            "driver": "COG",
            "tiled": True,
            "compress": "lzw",
            "blockxsize": 256,
            "blockysize": 256,
        }
    )

    logger.info(f"Applying the Otsu threshold to {raster}")

    with rasterio.open("otsu.tif", "w", **out_meta) as dst_dataset:
        logger.info(f"Write otsu.tif")
        dst_dataset.write(threshold(array), indexes=1)

    logger.info("Done!")


if __name__ == "__main__":
    otsu()
