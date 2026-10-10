#!/usr/bin/env python3
"""Prepare isolated release workflows using digests emitted by the image jobs."""
import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from ruamel.yaml import YAML

WORKFLOWS = (
    'app-water-bodies-cloud-native',
    'app-water-body-cloud-native',
    'app-water-body',
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--digests', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--version', required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='cwl-release-') as staging_directory:
        prepared = Path(staging_directory)
        shutil.copytree('cwl-workflow', prepared, dirs_exist_ok=True)
        yaml = YAML()
        repository = json.loads(Path('codemeta.json').read_text())['codeRepository']
        for name in WORKFLOWS:
            source = Path('cwl-workflow') / f'{name}.cwl'
            document = yaml.load(source.read_text())
            for process in document['$graph']:
                requirements = process.get('requirements', {})
                if isinstance(requirements, list):
                    docker = next((r for r in requirements if r['class'] == 'DockerRequirement'), None)
                else:
                    docker = requirements.get('DockerRequirement')
                if docker is None:
                    continue
                tool = process['id'].removeprefix('#')
                reference = (args.digests / f'{tool}.txt').read_text().strip()
                if not re.fullmatch(r'ghcr\.io/[a-z0-9_./-]+@sha256:[a-f0-9]{64}', reference):
                    raise ValueError(f'Invalid immutable image reference for {tool}: {reference}')
                docker['dockerPull'] = reference
            document['s:softwareVersion'] = args.version
            document['s:codeRepository'] = repository
            target = prepared / source.name
            with target.open('w') as stream:
                yaml.dump(document, stream)
            subprocess.run([
                sys.executable, 'scripts/pack-cwl-release.py', str(target),
                str(args.output / f'{name}.{args.version}.cwl'),
            ], check=True)


if __name__ == '__main__':
    main()
