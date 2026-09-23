"""Download a STAC item and package its assets in a local catalog."""

import asyncio
from pathlib import Path

import click
import pystac
import stac_asset
from loguru import logger


async def stage_item(reference: str) -> pystac.Catalog:
    """Stage an item's assets under its ID and write catalog.json."""
    logger.info("Reading input STAC item")
    item = pystac.read_file(reference)
    if not isinstance(item, pystac.Item):
        raise ValueError("Reference must point to a STAC item")
    directory = Path(item.id)
    if directory.name != item.id or item.id in {"", ".", ".."}:
        raise ValueError("STAC item id must be a single directory name")
    directory.mkdir(exist_ok=True)
    logger.info("Downloading assets for {} into {}", item.id, directory.resolve())
    item = await stac_asset.download_item(item=item, directory=directory.resolve(), config=stac_asset.Config(warn=True))
    catalog = pystac.Catalog(
        id="catalog",
        description=f"catalog with staged {item.id}",
        title=f"catalog with staged {item.id}",
    )
    catalog.add_item(item)
    catalog.normalize_hrefs("./")
    catalog.save(catalog_type=pystac.CatalogType.SELF_CONTAINED)
    logger.success("Wrote catalog.json for {}", item.id)
    return catalog


def execute(*, reference: str) -> None:
    """Synchronous callback for the stage-in console command."""
    try:
        asyncio.run(stage_item(reference))
    except (ValueError, OSError, pystac.STACError) as exc:
        logger.error("Stage-in failed: {}", exc)
        raise click.ClickException(str(exc)) from exc
