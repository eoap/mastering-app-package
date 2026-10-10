#!/usr/bin/env python3
"""Pack a workflow and preserve its package metadata in the release artifact."""
import json
import subprocess
import sys
from pathlib import Path

from ruamel.yaml import YAML

source, destination = map(Path, sys.argv[1:])
packed = json.loads(subprocess.check_output([
    'cwltool', '--pack', f'{source}#water-bodies'], text=True))
metadata = YAML(typ='safe').load(source.read_text())
for key, value in metadata.items():
    if key not in {'$graph', 'cwlVersion'}:
        packed[key] = value
# Packing renames the selected entrypoint to #main and embeds local schema imports.
destination.write_text(json.dumps(packed, indent=2) + '\n')
subprocess.run(['cwltool', '--validate', str(destination)], check=True)
