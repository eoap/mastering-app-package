"""Package water masks into a self-contained STAC catalog."""

import shutil
from pathlib import Path

import click
import pystac
import rasterio
from loguru import logger
from rio_stac.stac import create_stac_item


def _read_item(location: str) -> pystac.Item:
    path = Path(location)
    obj = pystac.read_file(str(path / "catalog.json") if path.is_dir() else location)
    if isinstance(obj, pystac.Catalog):
        obj = next(obj.get_items(recursive=True), None)
    if not isinstance(obj, pystac.Item):
        raise ValueError("Input must contain a STAC item")
    return obj


def _add_item(catalog: pystac.Catalog, item: pystac.Item, raster: str | Path) -> None:
    directory = Path(item.id)
    if directory.name != item.id or item.id in {"", ".", ".."}:
        raise ValueError("STAC item id must be a single directory name")
    directory.mkdir(exist_ok=True)
    destination = directory / Path(raster).name
    if Path(raster).resolve() != destination.resolve():
        shutil.copy(raster, destination)
    logger.info("Adding water mask for item {}", item.id)
    output = create_stac_item(
        source=str(destination),
        input_datetime=item.datetime,
        id=item.id,
        asset_roles=["data", "visual"],
        asset_href=destination.name,
        asset_name="data",
        with_proj=True,
        with_raster=True,
    )
    catalog.add_item(output)


def _create_catalog(
    item_urls: tuple[str, ...], water_bodies: tuple[str | Path, ...]
) -> None:
    if not item_urls or len(item_urls) != len(water_bodies):
        raise ValueError(
            "Provide the same nonzero number of STAC items and water body rasters"
        )
    items = [_read_item(url) for url in item_urls]
    if len({item.id for item in items}) != len(items):
        raise ValueError("STAC item ids must be unique")
    catalog = pystac.Catalog(id="catalog", description="water-bodies")
    for item, raster in zip(items, water_bodies, strict=True):
        _add_item(catalog, item, raster)
    catalog.normalize_and_save(
        root_href="./", catalog_type=pystac.CatalogType.SELF_CONTAINED
    )


def execute(*, item: tuple[str, ...], rasters: tuple[Path, ...]) -> None:
    """Create catalog.json and one item directory per water mask."""
    try:
        logger.info("Creating catalog for {} water masks", len(rasters))
        _create_catalog(item, rasters)
        logger.success("Wrote catalog.json")
    except (
        ValueError,
        OSError,
        pystac.STACError,
        rasterio.errors.RasterioError,
    ) as exc:
        logger.error("STAC catalog creation failed: {}", exc)
        raise click.ClickException(str(exc)) from exc
