"""Kubernetes labs select a published package without relying on local images."""
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]


@pytest.mark.parametrize('case', ['published', 'local_image', 'wrong_version', 'missing_release'])
def test_downloaded_package_is_checked_before_installation(tmp_path, case):
    version = '2.0.0-rc.10.1'
    image = 'ghcr.io/eoap/mastering-app-package/crop@sha256:' + 'a' * 64
    if case == 'local_image':
        image = 'localhost/crop:metadata'
    package = {
        's:softwareVersion': '1.1.0' if case == 'wrong_version' else version,
        '$graph': [
            {'id': '#main', 'class': 'Workflow'},
            {'id': '#crop', 'class': 'CommandLineTool', 'requirements': {
                'DockerRequirement': {'dockerPull': image}}},
        ],
    }
    fixture = tmp_path / 'fixture.json'
    fixture.write_text(json.dumps(package))
    commands = tmp_path / 'bin'
    commands.mkdir()
    curl = commands / 'curl'
    curl.write_text(f'#!{sys.executable}\n' + '''import os, pathlib, sys
if os.environ['CASE'] == 'missing_release':
    sys.exit(22)
destination = pathlib.Path(sys.argv[sys.argv.index('--output') + 1])
if destination.name == 'workflow.cwl':
    destination.write_text(pathlib.Path(os.environ['FIXTURE']).read_text())
else:
    destination.write_text('stac_items: []\\n')
pathlib.Path(os.environ['URL_LOG']).open('a').write(sys.argv[-1] + '\\n')
''')
    curl.chmod(0o755)
    validator = commands / 'cwltool'
    validator.write_text('#!/usr/bin/env bash\nexit 0\n')
    validator.chmod(0o755)
    destination = tmp_path / 'calrissian'
    destination.mkdir()
    target = destination / 'app-water-bodies-cloud-native.cwl'
    target.write_text('previous package')
    result = subprocess.run(['bash', str(ROOT / 'scripts/prepare-kubernetes-lab.sh')],
        env={**os.environ, 'PATH': f'{commands}:{os.environ["PATH"]}',
             'APPLICATION_PACKAGE_VERSION': version, 'CALRISSIAN_DIRECTORY': str(destination),
             'FIXTURE': str(fixture), 'CASE': case, 'URL_LOG': str(tmp_path / 'urls')},
        text=True, capture_output=True)
    if case == 'published':
        assert result.returncode == 0, result.stderr
        assert json.loads(target.read_text()) == package
        assert (destination / 'params.yaml').exists()
        assert all(f'/releases/download/{version}/' in url
                   for url in (tmp_path / 'urls').read_text().splitlines())
    else:
        assert result.returncode != 0
        assert target.read_text() == 'previous package'
        assert not (destination / 'params.yaml').exists()
    assert not list(destination.glob('.package-*'))
