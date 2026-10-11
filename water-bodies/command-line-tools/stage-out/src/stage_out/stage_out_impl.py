"""Stage a local STAC catalog and its assets to S3."""

from __future__ import annotations

import os
import posixpath
import shutil
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Any
from urllib.parse import unquote, urlparse

import boto3
import pystac
from loguru import logger
from pystac.stac_io import DefaultStacIO


class S3StacIO(DefaultStacIO):
    """Write STAC documents using the configured S3 client."""

    def __init__(self, client: Any) -> None:
        super().__init__()
        self.client = client

    def write_text(self, dest: Any, txt: str, *args: Any, **kwargs: Any) -> None:
        parsed = urlparse(str(dest))
        if parsed.scheme == "s3":
            self.client.put_object(
                Body=txt.encode("UTF-8"),
                Bucket=parsed.netloc,
                Key=parsed.path.lstrip("/"),
                ContentType="application/geo+json",
            )
        else:
            super().write_text(dest, txt, *args, **kwargs)


def upload_assets(item: pystac.Item, client: Any, bucket: str, subfolder: str) -> None:
    """Upload assets before rewriting their references."""
    if Path(item.id).name != item.id or item.id in {"", ".", ".."}:
        raise ValueError("STAC item id must be a single directory name")
    for asset in item.assets.values():
        parsed = urlparse(asset.href)
        relative = (
            posixpath.basename(parsed.path)
            if parsed.scheme or posixpath.isabs(parsed.path)
            else parsed.path
        )
        relative = posixpath.normpath(relative)
        if relative == ".." or relative.startswith("../"):
            relative = posixpath.basename(relative)
        key = posixpath.normpath(posixpath.join(subfolder, item.id, relative))
        logger.info("Uploading asset to s3://{}/{}", bucket, key)
        absolute = asset.get_absolute_href()
        location = urlparse(absolute)
        if location.scheme not in ("", "file") or location.netloc not in (
            "",
            "localhost",
        ):
            raise ValueError("Stage-out requires local filesystem assets")
        local = Path(unquote(location.path))
        if local.is_dir():
            # An asset may refer to a group inside a store; upload the entire
            # enclosing store so root conventions and sibling overviews survive.
            store = next(
                (
                    part
                    for part in (local, *local.parents)
                    if part.name.endswith(".zarr") and (part / "zarr.json").is_file()
                ),
                local,
            )
            store_key = posixpath.join(subfolder, item.id, store.name)
            files = sorted(path for path in store.rglob("*") if path.is_file())
            if not files:
                raise ValueError(f"Empty directory asset: {store}")
            for path in files:
                client.upload_file(
                    str(path),
                    bucket,
                    posixpath.join(store_key, path.relative_to(store).as_posix()),
                )
            suffix = local.relative_to(store).as_posix()
            key = store_key if suffix == "." else posixpath.join(store_key, suffix)
        else:
            client.upload_file(str(local), bucket, key)
        asset.href = f"s3://{bucket}/{key}"


def upload_catalog(
    catalog: pystac.Catalog, client: Any, bucket: str, subfolder: str
) -> str:
    """Upload assets and publish the rewritten catalog documents."""
    catalog.set_root(catalog)
    items = list(catalog.get_items(recursive=True))
    for item in items:
        upload_assets(item, client, bucket, subfolder)
    destination = f"s3://{bucket}/{subfolder}"
    catalog.normalize_hrefs(destination)
    stac_io = S3StacIO(client)
    catalog.save(catalog_type=pystac.CatalogType.SELF_CONTAINED, stac_io=stac_io)
    logger.info("Published catalog to {}/catalog.json", destination)
    return f"{destination}/catalog.json"


def execute(catalog: Path, bucket: str, subfolder: str) -> str:
    """Copy the input catalog, upload it, and return its S3 URL."""
    client = boto3.client(
        "s3",
        aws_access_key_id=os.environ["aws_access_key_id"],
        aws_secret_access_key=os.environ["aws_secret_access_key"],
        region_name=os.environ["aws_region_name"],
        endpoint_url=os.environ["aws_endpoint_url"],
    )
    with TemporaryDirectory(prefix="stage-out-") as directory:
        copied = Path(directory) / "catalog"
        shutil.copytree(catalog, copied)
        loaded = pystac.read_file(str(copied / "catalog.json"))
        if not isinstance(loaded, pystac.Catalog):
            raise ValueError("The input must contain a STAC catalog or collection")
        return upload_catalog(loaded, client, bucket, subfolder)
