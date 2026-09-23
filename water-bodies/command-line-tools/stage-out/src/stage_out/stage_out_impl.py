"""Stage a local STAC catalog and its assets to S3."""

from __future__ import annotations

import os
import posixpath
import shutil
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Any
from urllib.parse import urlparse

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
    for asset in item.assets.values():
        key = posixpath.normpath(posixpath.join(subfolder, item.id, asset.href))
        logger.info("Uploading asset to s3://{}/{}", bucket, key)
        client.upload_file(asset.get_absolute_href(), bucket, key)
        asset.href = f"s3://{bucket}/{key}"


def upload_catalog(
    catalog: pystac.Catalog, client: Any, bucket: str, subfolder: str
) -> str:
    """Upload assets and publish the rewritten catalog documents."""
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
