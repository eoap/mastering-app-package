"""Download a STAC item and package its assets in a local catalog."""

import asyncio
import os
from pathlib import Path

import click
import pystac
import stac_asset
from loguru import logger
from stac_asset.errors import AssetOverwriteError, DownloadError


def _positive_env_int(name: str, default: int) -> int:
    """Read a positive integer setting, reporting invalid values clearly."""
    raw = os.environ.get(name, str(default))
    try:
        value = int(raw)
    except ValueError as exc:
        raise ValueError(f"{name} must be a positive integer, got {raw!r}") from exc
    if value <= 0:
        raise ValueError(f"{name} must be a positive integer, got {raw!r}")
    return value


async def stage_item(reference: str, *, http_timeout: float | None = None, asset_keys: tuple[str, ...] = ()) -> pystac.Catalog:
    """Stage an item's assets under its ID and write catalog.json."""
    # Timeout is in seconds; attempts includes the initial download attempt.
    timeout = http_timeout if http_timeout is not None else _positive_env_int("STAGE_IN_HTTP_TIMEOUT", 300)
    attempts = _positive_env_int("STAGE_IN_HTTP_MAX_ATTEMPTS", 3)
    config = stac_asset.Config(
        http_client_timeout=timeout,
        http_max_attempts=attempts,
    )
    logger.info("Stage-in HTTP timeout: {} seconds; max attempts: {}", timeout, attempts)
    logger.info("Reading input STAC item")
    item = pystac.read_file(reference)
    if not isinstance(item, pystac.Item):
        raise ValueError("Reference must point to a STAC item")
    if asset_keys:
        missing = set(asset_keys) - item.assets.keys()
        if missing: raise ValueError(f"Unknown STAC asset keys: {sorted(missing)}")
        item.assets = {key: item.assets[key] for key in asset_keys}
    directory = Path(item.id)
    if directory.name != item.id or item.id in {"", ".", ".."}:
        raise ValueError("STAC item id must be a single directory name")
    directory.mkdir(exist_ok=True)
    logger.info("Downloading assets for {} into {}", item.id, directory.resolve())
    item = await stac_asset.download_item(
        item=item, directory=directory.resolve(), config=config
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


def execute(*, reference: str, http_timeout: float | None = None, asset_keys: tuple[str, ...] = ()) -> None:
    """Synchronous callback for the stage-in console command."""
    try:
        asyncio.run(stage_item(reference, http_timeout=http_timeout, asset_keys=asset_keys))
    except (TimeoutError, ValueError, OSError, pystac.STACError, DownloadError, AssetOverwriteError) as exc:
        logger.error("Stage-in failed: {}", exc)
        raise click.ClickException(str(exc)) from exc
