import json
from datetime import UTC, datetime
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
        datetime=datetime(2026, 1, 1, tzinfo=UTC),
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
    for document in documents.values():
        for link in document["links"]:
            assert not link["href"].startswith("/tmp/")
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


def test_absolute_asset_keeps_destination_prefix(catalog_directory, client):
    item_path = catalog_directory / "water" / "water.json"
    data = json.loads(item_path.read_text())
    data["assets"]["mask"]["href"] = str(catalog_directory / "water" / "mask.tif")
    item_path.write_text(json.dumps(data))
    execute(catalog_directory, "bucket", "results/run")
    assert client.upload_file.call_args.args[1:] == (
        "bucket",
        "results/run/water/mask.tif",
    )


def test_cli_reports_upload_failure(catalog_directory, client):
    client.upload_file.side_effect = OSError("Upload failed")
    result = CliRunner().invoke(stage_out, [str(catalog_directory), "bucket", "run"])
    assert result.exit_code == 1
    assert "Error: Upload failed" in result.output
    client.put_object.assert_not_called()


@pytest.mark.parametrize("root_marker", ["zarr.json", ".zgroup"])
def test_zarr_group_uploads_complete_store(catalog_directory, client, root_marker):
    store = catalog_directory / "water" / "output.zarr"
    for relative in (
        root_marker,
        "measurements/zarr.json",
        "measurements/ndwi/c/0/0/0",
        "overviews/0/zarr.json",
    ):
        path = store / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(b"data")
    item_path = catalog_directory / "water" / "water.json"
    original = json.loads(item_path.read_text())
    original["assets"] = {"measurements": {"href": "output.zarr/measurements"}}
    item_path.write_text(json.dumps(original))
    execute(catalog_directory, "bucket", "run")
    keys = {call.args[2] for call in client.upload_file.call_args_list}
    assert f"run/water/output.zarr/{root_marker}" in keys
    assert "run/water/output.zarr/overviews/0/zarr.json" in keys
    assert "run/water/output.zarr/measurements/ndwi/c/0/0/0" in keys
    documents = {
        call.kwargs["Key"]: json.loads(call.kwargs["Body"])
        for call in client.put_object.call_args_list
    }
    assert (
        documents["run/water/water.json"]["assets"]["measurements"]["href"]
        == "s3://bucket/run/water/output.zarr/measurements"
    )
    assert json.loads(item_path.read_text()) == original


def test_directory_root_uploads_all_files(catalog_directory, client):
    store = catalog_directory / "water" / "output.zarr"
    store.mkdir()
    (store / "zarr.json").write_text("{}")
    (store / "chunk").write_bytes(b"data")
    path = catalog_directory / "water" / "water.json"
    data = json.loads(path.read_text())
    data["assets"] = {"measurements": {"href": "output.zarr"}}
    path.write_text(json.dumps(data))
    execute(catalog_directory, "bucket", "run")
    assert {call.args[2] for call in client.upload_file.call_args_list} == {
        "run/water/output.zarr/zarr.json",
        "run/water/output.zarr/chunk",
    }


def test_empty_directory_does_not_publish(catalog_directory, client):
    (catalog_directory / "water" / "empty.zarr").mkdir()
    path = catalog_directory / "water" / "water.json"
    data = json.loads(path.read_text())
    data["assets"] = {"measurements": {"href": "empty.zarr"}}
    path.write_text(json.dumps(data))
    with pytest.raises(ValueError, match="Empty directory"):
        execute(catalog_directory, "bucket", "run")
    client.put_object.assert_not_called()
