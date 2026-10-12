#!/usr/bin/env python3
"""Embed local module schemas and rename the workflow entrypoint explicitly."""
import json
import subprocess
import sys
from pathlib import Path
from ruamel.yaml import YAML
source, destination = map(Path, sys.argv[1:])
yaml = YAML(typ='safe')
document = yaml.load(source.read_text())
def embed(value):
    if isinstance(value, dict):
        reference = value.get('$import')
        if reference and not reference.startswith(('http://', 'https://')):
            schemas = yaml.load((source.parent / reference).read_text())
            for schema in schemas: schema['name'] = '#' + schema['name'].removeprefix('#')
            return schemas
        return {key:embed(child) for key, child in value.items()}
    if isinstance(value, list):
        result=[]
        for child in value:
            if isinstance(child, dict) and '$import' in child and not child['$import'].startswith(('http://','https://')):
                result.extend(embed(child))
            else: result.append(embed(child))
        return result
    if isinstance(value, str) and value.startswith('eoap-types.yaml#'): return '#' + value.split('#',1)[1]
    return value
document = embed(document)
for process in document['$graph']:
    if process['id'].removeprefix('#') == 'water-bodies': process['id'] = '#main'
destination.write_text(json.dumps(document,indent=2)+'\n')
subprocess.run(['cwltool','--validate',str(destination)+'#main'],check=True)
