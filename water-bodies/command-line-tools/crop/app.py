import os
import time
import click
import pystac
import rasterio
from rasterio.mask import mask
from pyproj import Transformer
from shapely import box
from loguru import logger


def aoi2box(aoi):
    """Converts an area of interest expressed as a bounding box to a list of floats"""
    return [float(c) for c in aoi.split(",")]


def get_asset(item, common_name):
    """Returns the asset of a STAC Item defined with its common band name"""
    for _, asset in item.get_assets().items():
        if not "data" in asset.to_dict()["roles"]:
            continue

        eo_asset = pystac.extensions.eo.AssetEOExtension(asset)
        if not eo_asset.bands:
            continue
        for b in eo_asset.bands:
            if (
                "common_name" in b.properties.keys()
                and b.properties["common_name"] == common_name
            ):
                return asset


@click.command(
    short_help="Crop",
    help="Crops a STAC Item asset defined with its common band name",
)
@click.option(
    "--input-item",
    "item_url",
    help="STAC Item URL or staged STAC catalog",
    required=True,
)
@click.option(
    "--aoi",
    "aoi",
    help="Area of interest expressed as a bounding box",
    required=True,
)
@click.option(
    "--epsg",
    "epsg",
    help="EPSG code",
    required=True,
)
@click.option(
    "--band",
    "band",
    help="Common band name",
    required=True,
)
def crop(item_url, aoi, band, epsg):

    if os.path.isdir(item_url):
        catalog = pystac.read_file(os.path.join(item_url, "catalog.json"))
        item = next(catalog.get_items())
    else:
        item = pystac.read_file(item_url)

    logger.info(f"Read {item.id} from {item.get_self_href()}")

    asset = get_asset(item, band)
    logger.info(f"Read asset {band} from {asset.get_absolute_href()}")

    if not asset:
        msg = f"Common band name {band} not found in the assets"
        logger.error(msg)
        raise ValueError(msg)

    bbox = aoi2box(aoi)

    for attempt in range(3):
        try:
            # Bound remote COG requests so a stalled connection cannot hang a lab.
            with rasterio.Env(
                GDAL_HTTP_CONNECTTIMEOUT=10,
                GDAL_HTTP_TIMEOUT=60,
                GDAL_HTTP_MAX_RETRY=2,
                GDAL_HTTP_RETRY_DELAY=1,
                GDAL_HTTP_RETRY_CODES="ALL",
                GDAL_HTTP_MULTIRANGE="SERIAL",
                CPL_VSIL_CURL_NON_CACHED=f"/vsicurl/{asset.get_absolute_href()}",
            ), rasterio.open(asset.get_absolute_href()) as src:

                transformer = Transformer.from_crs(epsg, src.crs, always_xy=True)

                minx, miny = transformer.transform(bbox[0], bbox[1])
                maxx, maxy = transformer.transform(bbox[2], bbox[3])

                transformed_bbox = box(minx, miny, maxx, maxy)

                logger.info(f"Crop {asset.get_absolute_href()}")

                out_image, out_transform = rasterio.mask.mask(
                    src, [transformed_bbox], crop=True
                )
                out_meta = src.meta.copy()

                out_meta.update(
                    {
                        "height": out_image.shape[1],
                        "width": out_image.shape[2],
                        "transform": out_transform,
                        "dtype": "uint16",
                        "driver": "COG",
                        "tiled": True,
                        "compress": "lzw",
                        "blockxsize": 256,
                        "blockysize": 256,
                    }
                )

                with rasterio.open(f"crop_{band}.tif", "w", **out_meta) as dst_dataset:
                    logger.info(f"Write crop_{band}.tif")
                    dst_dataset.write(out_image)
            break
        except rasterio.errors.RasterioIOError:
            if attempt == 2 or not asset.get_absolute_href().startswith(("http://", "https://")):
                raise
            logger.warning("Remote raster read failed; retrying crop ({}/3)", attempt + 2)
            time.sleep(1)

    logger.info("Done!")


if __name__ == "__main__":
    crop()
