"""Test stage-in with local STAC assets."""

from datetime import datetime, timezone
from pathlib import Path

import pystac
from click.testing import CliRunner

from stage.stage_in_cli import stage_in


def test_stages_local_item(tmp_path, monkeypatch):
    source = tmp_path / "source"
    source.mkdir()
    asset = source / "data.txt"
    asset.write_text("local asset contents")
    item = pystac.Item(
        "scene",
        geometry=None,
        bbox=None,
        datetime=datetime(2026, 1, 1, tzinfo=timezone.utc),
        properties={},
    )
    item.add_asset("data", pystac.Asset("./data.txt", roles=["data"]))
    item.set_self_href(str(source / "item.json"))
    item.save_object()
    output = tmp_path / "output"
    output.mkdir()
    monkeypatch.chdir(output)
    result = CliRunner().invoke(stage_in, ["--reference", str(source / "item.json")])
    assert result.exit_code == 0, result.output
    assert Path.cwd() == output
    catalog = pystac.Catalog.from_file(str(output / "catalog.json"))
    staged = next(catalog.get_items())
    assert staged.id == "scene"
    local_asset = Path(staged.assets["data"].get_absolute_href())
    assert local_asset.is_relative_to(output / "scene")
    assert local_asset.read_text() == "local asset contents"
    assert not Path(staged.assets["data"].href).is_absolute()


def test_rejects_catalog(tmp_path, monkeypatch):
    catalog = pystac.Catalog("empty", "Empty catalog")
    catalog.set_self_href(str(tmp_path / "source.json"))
    catalog.save_object()
    monkeypatch.chdir(tmp_path)
    result = CliRunner().invoke(stage_in, ["--reference", str(tmp_path / "source.json")])
    assert result.exit_code == 1
    assert "must point to a STAC item" in result.output
    assert not (tmp_path / "catalog.json").exists()


def test_reference_required():
    result = CliRunner().invoke(stage_in, [])
    assert result.exit_code == 2
    assert "--reference" in result.output


def test_failed_download_does_not_publish_catalog(tmp_path, monkeypatch):
    item = pystac.Item("missing", None, None, datetime(2026, 1, 1, tzinfo=timezone.utc), {})
    item.add_asset("data", pystac.Asset(str(tmp_path / "absent.tif")))
    source = tmp_path / "source.json"
    item.save_object(dest_href=str(source))
    monkeypatch.chdir(tmp_path)
    result = CliRunner().invoke(stage_in, ["--reference", str(source)])
    assert result.exit_code == 1
    assert not (tmp_path / "catalog.json").exists()


def test_timeout_is_reported_without_publishing_catalog(tmp_path, monkeypatch):
    from stage import stage_in_impl
    async def timeout(*args, **kwargs):
        raise TimeoutError('transfer deadline exceeded')
    monkeypatch.setattr(stage_in_impl, 'stage_item', timeout)
    monkeypatch.chdir(tmp_path)
    result = CliRunner().invoke(stage_in, ['--reference', 'https://example.invalid/item.json', '--http-timeout', '900'])
    assert result.exit_code == 1
    assert 'transfer deadline exceeded' in result.output
    assert not (tmp_path / 'catalog.json').exists()


def test_stages_only_selected_asset(tmp_path, monkeypatch):
    item = pystac.Item('scene', None, None, datetime(2026, 1, 1, tzinfo=timezone.utc), {})
    for key in ('needed', 'unused'):
        asset = tmp_path / (key + '.txt'); asset.write_text(key)
        item.add_asset(key, pystac.Asset(str(asset)))
    source = tmp_path / 'item.json'; item.save_object(dest_href=str(source))
    output = tmp_path / 'output'; output.mkdir(); monkeypatch.chdir(output)
    result = CliRunner().invoke(stage_in, ['--reference', str(source), '--asset', 'needed'])
    assert result.exit_code == 0, result.output
    staged = next(pystac.Catalog.from_file(str(output / 'catalog.json')).get_items())
    assert set(staged.assets) == {'needed'}
    assert not (output / 'scene/unused.txt').exists()


def test_transfer_environment_and_cli_precedence(tmp_path, monkeypatch):
    from stage import stage_in_impl

    item = pystac.Item('scene', None, None, datetime(2026, 1, 1, tzinfo=timezone.utc), {})
    source = tmp_path / 'item.json'
    item.save_object(dest_href=str(source))
    configs = []

    async def capture_download(*, item, directory, config):
        configs.append(config)
        return item

    monkeypatch.setattr(stage_in_impl.stac_asset, 'download_item', capture_download)
    monkeypatch.setenv('STAGE_IN_HTTP_TIMEOUT', '600')
    monkeypatch.setenv('STAGE_IN_HTTP_MAX_ATTEMPTS', '5')
    monkeypatch.chdir(tmp_path)
    for options, expected_timeout in [([], 600), (['--http-timeout', '900'], 900)]:
        result = CliRunner().invoke(stage_in, ['--reference', str(source), *options])
        assert result.exit_code == 0, result.output
        assert configs[-1].http_client_timeout == expected_timeout
        assert configs[-1].http_max_attempts == 5


def test_invalid_attempts_fail_before_staging(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    for value in ('0', '-1', 'invalid'):
        monkeypatch.setenv('STAGE_IN_HTTP_MAX_ATTEMPTS', value)
        result = CliRunner().invoke(stage_in, ['--reference', 'missing.json'])
        assert result.exit_code == 1
        assert 'STAGE_IN_HTTP_MAX_ATTEMPTS must be a positive integer' in result.output
        assert not (tmp_path / 'catalog.json').exists()
