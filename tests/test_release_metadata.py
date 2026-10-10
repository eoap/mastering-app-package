"""Release metadata must remain portable and match the published version."""
import json
import subprocess
import sys
from pathlib import Path

import pytest

CHECKER = Path(__file__).resolve().parents[1] / 'scripts/check-oci-annotations.py'


@pytest.mark.parametrize('entrypoint', ['main', '#main', 'file:///runner/work/release.cwl#main'])
def test_annotation_entrypoint_is_portable(tmp_path, entrypoint):
    annotations = {key: 'value' for key in (
        'org.opencontainers.image.title', 'org.opencontainers.image.description',
        'org.opencontainers.image.licenses', 'org.opencontainers.image.source',
        'org.opencontainers.image.revision', 'org.cwl.spec',
    )}
    annotations.update({
        'org.opencontainers.image.version': '2.0.0',
        'org.cwl.entrypoint': entrypoint,
        'org.cwl.type': 'Workflow',
    })
    path = tmp_path / 'annotations.json'
    path.write_text(json.dumps({'$manifest': annotations}))
    subprocess.run([sys.executable, str(CHECKER), str(path), 'workflow.cwl', '2.0.0'], check=True)
    actual = json.loads(path.read_text())['$manifest']
    assert actual == {**annotations, 'org.cwl.entrypoint': 'workflow.cwl#main'}
    # A version mismatch must prevent publishing the artifact.
    result = subprocess.run(
        [sys.executable, str(CHECKER), str(path), 'workflow.cwl', '3.0.0'],
        capture_output=True, text=True,
    )
    assert result.returncode != 0
    assert 'version does not match' in result.stderr


def test_incomplete_annotations_are_rejected(tmp_path):
    path = tmp_path / 'annotations.json'
    path.write_text(json.dumps({'$manifest': {'org.cwl.entrypoint': 'main'}}))
    result = subprocess.run(
        [sys.executable, str(CHECKER), str(path), 'workflow.cwl', '2.0.0'],
        capture_output=True, text=True,
    )
    assert result.returncode != 0
    assert 'Missing or invalid annotation' in result.stderr
