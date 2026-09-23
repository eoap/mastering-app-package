"""Crop a STAC spectral-band asset to an area of interest."""

from __future__ import annotations

import json
from pathlib import Path
from urllib.parse import parse_qs, urlparse

import click
import planetary_computer
import pystac
import rasterio
from loguru import logger
from rasterio.mask import mask
from rasterio.warp import transform_geom
from shapely.geometry import Polygon, box, mapping, shape


def _read_item(location: str) -> pystac.Item:
    path = Path(location)
    source = str(path / "catalog.json") if path.is_dir() else location
    logger.info("Reading input STAC document")
    obj = pystac.read_file(source)
    if isinstance(obj, pystac.Item):
        logger.info("Loaded STAC item {}", obj.id)
        return obj
    if isinstance(obj, pystac.Catalog):
        item = next(obj.get_items(recursive=True), None)
        if item is not None:
            logger.info("Selected first item {} from catalog {}", item.id, obj.id)
            return item
    raise ValueError("Input must be a STAC item or a catalog containing an item")


def _needs_signing(href: str) -> bool:
    parsed = urlparse(href)
    host = (parsed.hostname or "").lower()
    return (
        host.endswith(".blob.core.windows.net")
        and host != "ai4edatasetspublicassets.blob.core.windows.net"
        and not {"st", "se", "sp"}.intersection(parse_qs(parsed.query))
    )


def _bbox_geometry(aoi: str) -> Polygon:
    """Parse and validate a comma-separated bounding box."""
    bounds = [float(value) for value in aoi.split(",")]
    if len(bounds) != 4:
        raise ValueError("AOI must be a GeoJSON polygon or xmin,ymin,xmax,ymax")
    if bounds[0] >= bounds[2] or bounds[1] >= bounds[3]:
        raise ValueError("AOI minimum coordinates must be smaller than maxima")
    return box(bounds[0], bounds[1], bounds[2], bounds[3])


def _geometry(aoi: str) -> dict:
    geometry = (
        shape(json.loads(aoi)) if aoi.lstrip().startswith("{") else _bbox_geometry(aoi)
    )
    if geometry.geom_type not in {"Polygon", "MultiPolygon"}:
        raise ValueError("AOI must be a polygon")
    if geometry.is_empty or not geometry.is_valid:
        raise ValueError("AOI must be a nonempty, valid polygon")
    return mapping(geometry)


def _asset(item: pystac.Item, common_name: str) -> pystac.Asset:
    for key, asset in item.assets.items():
        if "data" not in (asset.roles or []):
            continue
        bands = asset.extra_fields.get("eo:bands", [])
        bands = bands or asset.extra_fields.get("bands", [])
        if any(band.get("common_name") == common_name for band in bands):
            logger.info("Selected asset {} for band {}", key, common_name)
            return asset
    raise ValueError(f"Common band name {common_name} not found in the assets")


def _asset_href(item: pystac.Item, band: str) -> str:
    """Sign cloud assets when needed and resolve the selected band's location."""
    if any(_needs_signing(asset.href) for asset in item.assets.values()):
        logger.info("Signing Planetary Computer asset URLs")
        planetary_computer.sign_inplace(item)
    asset = _asset(item, band)
    href = asset.get_absolute_href()
    if href is None:
        raise ValueError("Selected asset has no resolvable href")
    return href


def execute(*, input_item: str, aoi: str, epsg: str, band: str) -> None:
    """Read the CLI inputs and write ``crop_<band>.tif`` in the working directory."""
    try:
        logger.info("Starting crop for band {}", band)
        if band not in {"green", "nir", "nir08"}:
            raise ValueError("Band must be one of green, nir, nir08")
        geometry = _geometry(aoi)
        logger.info("Parsed {} AOI in {}", geometry["type"], epsg)
        item = _read_item(input_item)
        href = _asset_href(item, band)
        logger.info("Opening raster for item {}, band {}", item.id, band)
        with rasterio.open(href) as src:
            if src.crs is None:
                raise ValueError("Selected raster has no coordinate reference system")
            logger.info(
                "Source raster: {} x {} pixels, {} band(s), CRS {}",
                src.width,
                src.height,
                src.count,
                src.crs,
            )
            logger.info("Transforming AOI from {} to {}", epsg, src.crs)
            projected = transform_geom(epsg, src.crs, geometry)
            logger.info("Cropping raster to the AOI")
            pixels, transform = mask(src, [projected], crop=True)
            logger.info(
                "Cropped raster: {} x {} pixels", pixels.shape[2], pixels.shape[1]
            )
            metadata = src.meta.copy()
            metadata.update(
                driver="COG",
                height=pixels.shape[1],
                width=pixels.shape[2],
                transform=transform,
                compress="LZW",
                blocksize=256,
            )
            output = Path(f"crop_{band}.tif")
            logger.info("Writing LZW-compressed COG to {}", output.resolve())
            with rasterio.open(output, "w", **metadata) as dst:
                dst.write(pixels)
        logger.success("Crop complete: {}", output.resolve())
    except (
        ValueError,
        OSError,
        pystac.STACError,
        rasterio.errors.RasterioError,
    ) as exc:
        logger.error("Crop failed: {}", exc)
        raise click.ClickException(str(exc)) from exc
