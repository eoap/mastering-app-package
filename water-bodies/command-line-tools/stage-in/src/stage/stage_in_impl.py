"""Download a STAC item and package its assets in a local catalog."""

import asyncio
from pathlib import Path

import click
import pystac
import stac_asset
from loguru import logger
from stac_asset.errors import AssetOverwriteError, DownloadError


async def stage_item(
    reference: str, *, http_timeout: float = 300, asset_keys: tuple[str, ...] = ()
) -> pystac.Catalog:
    """Stage an item's assets under its ID and write catalog.json."""
    logger.info("Reading input STAC item")
    item = pystac.read_file(reference)
    if not isinstance(item, pystac.Item):
        raise ValueError("Reference must point to a STAC item")
    if asset_keys:
        missing = set(asset_keys) - item.assets.keys()
        if missing:
            raise ValueError(f"Unknown STAC asset keys: {sorted(missing)}")
        item.assets = {key: item.assets[key] for key in asset_keys}
    directory = Path(item.id)
    if directory.name != item.id or item.id in {"", ".", ".."}:
        raise ValueError("STAC item id must be a single directory name")
    directory.mkdir(exist_ok=True)
    logger.info("Downloading assets for {} into {}", item.id, directory.resolve())
    item = await stac_asset.download_item(
        item=item,
        directory=directory.resolve(),
        config=stac_asset.Config(http_client_timeout=http_timeout, http_max_attempts=3),
    )
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


def execute(*, reference: str, http_timeout: float = 300, asset_keys: tuple[str, ...] = ()) -> None:
    """Synchronous callback for the stage-in console command."""
    try:
        asyncio.run(stage_item(reference, http_timeout=http_timeout, asset_keys=asset_keys))
    except (
        TimeoutError,
        ValueError,
        OSError,
        pystac.STACError,
        DownloadError,
        AssetOverwriteError,
    ) as exc:
        logger.error("Stage-in failed: {}", exc)
        raise click.ClickException(str(exc)) from exc
