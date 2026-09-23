import json
from datetime import datetime, timezone
from unittest.mock import Mock

import pystac
import pytest
from click.testing import CliRunner

from stage_out.cli import stage_out
from stage_out.stage_out_impl import execute


@pytest.fixture
def catalog_directory(tmp_path):
    catalog = pystac.Catalog(id="catalog", description="Test catalog")
    item = pystac.Item(
        id="water",
        geometry=None,
        bbox=None,
        datetime=datetime(2026, 1, 1, tzinfo=timezone.utc),
        properties={},
    )
    item.add_asset("mask", pystac.Asset(href="mask.tif"))
    catalog.add_item(item)
    catalog.normalize_hrefs(str(tmp_path))
    catalog.save(catalog_type=pystac.CatalogType.SELF_CONTAINED)
    (tmp_path / "water" / "mask.tif").write_bytes(b"raster data")
    return tmp_path


@pytest.fixture
def client(monkeypatch):
    for name in (
        "aws_access_key_id",
        "aws_secret_access_key",
        "aws_region_name",
        "aws_endpoint_url",
    ):
        monkeypatch.setenv(name, "test")
    client = Mock()
    monkeypatch.setattr(
        "stage_out.stage_out_impl.boto3.client", lambda *a, **kw: client
    )
    return client


def test_upload_preserves_input_and_publishes_links(catalog_directory, client):
    original = (catalog_directory / "water" / "water.json").read_bytes()
    result = execute(catalog_directory, "bucket", "results/run")
    assert result == "s3://bucket/results/run/catalog.json"
    assert client.upload_file.call_args.args[1:] == (
        "bucket",
        "results/run/water/mask.tif",
    )
    documents = {
        call.kwargs["Key"]: json.loads(call.kwargs["Body"])
        for call in client.put_object.call_args_list
    }
    assert (
        documents["results/run/water/water.json"]["assets"]["mask"]["href"]
        == "s3://bucket/results/run/water/mask.tif"
    )
    assert "results/run/catalog.json" in documents
    assert (catalog_directory / "water" / "water.json").read_bytes() == original


def test_cli(catalog_directory, client):
    result = CliRunner().invoke(stage_out, [str(catalog_directory), "bucket", "run"])
    assert result.exit_code == 0, result.output
    assert result.stdout.strip() == "s3://bucket/run/catalog.json"


def test_upload_failure_propagates(catalog_directory, client):
    client.upload_file.side_effect = OSError("Upload failed")
    with pytest.raises(OSError, match="Upload failed"):
        execute(catalog_directory, "bucket", "run")
    client.put_object.assert_not_called()
