#!/usr/bin/env python3
"""Check cwl2oci output and make the entrypoint portable within the OCI artifact."""
import json
import sys
from pathlib import Path
from urllib.parse import urlsplit

path = Path(sys.argv[1])
filename, version = sys.argv[2:]
document = json.loads(path.read_text())
annotations = document['$manifest']
required = (
    'org.opencontainers.image.title', 'org.opencontainers.image.description',
    'org.opencontainers.image.version', 'org.opencontainers.image.licenses',
    'org.opencontainers.image.source', 'org.opencontainers.image.revision',
    'org.cwl.entrypoint', 'org.cwl.spec', 'org.cwl.type',
)
for key in required:
    if not isinstance(annotations.get(key), str) or not annotations[key]:
        raise ValueError(f'Missing or invalid annotation: {key}')
if annotations['org.opencontainers.image.version'] != version:
    raise ValueError('OCI version does not match release version')
entrypoint = annotations['org.cwl.entrypoint']
if entrypoint != 'main' and urlsplit(entrypoint).fragment != 'main':
    raise ValueError('Expected packed workflow entrypoint #main')
if annotations['org.cwl.type'] != 'Workflow':
    raise ValueError('Expected a Workflow artifact')
# Runtime versions return either 'main' or a resolved URI. Use the artifact filename.
annotations['org.cwl.entrypoint'] = f'{filename}#main'
path.write_text(json.dumps(document, indent=2) + '\n')
