#!/usr/bin/env bash
# Download an already published package and its matching inputs for any cluster.
set -euo pipefail
version=${APPLICATION_PACKAGE_VERSION:-2.0.0}
repository=${APPLICATION_PACKAGE_REPOSITORY:-eoap/mastering-app-package}
destination=${CALRISSIAN_DIRECTORY:-/calrissian}
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]
[[ "$repository" =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ ]]
mkdir -p "$destination"
staging=$(mktemp -d "$destination/.package-XXXXXX")
trap 'rm -rf "$staging"' EXIT
base="https://github.com/$repository/releases/download/$version"
curl --fail --location --retry 3 --output "$staging/workflow.cwl" \
  "$base/app-water-bodies-cloud-native.$version.cwl"
curl --fail --location --retry 3 --output "$staging/params.yaml" \
  "$base/typed-scatter-inputs.yaml"
python - "$staging/workflow.cwl" "$version" <<'PY'
import json
import re
import sys
from pathlib import Path
package = json.loads(Path(sys.argv[1]).read_text())
if package.get('s:softwareVersion') != sys.argv[2]:
    raise ValueError('Downloaded package version does not match selected release')
if not any(p.get('id') in ('main', '#main') and p.get('class') == 'Workflow' for p in package['$graph']):
    raise ValueError('Expected a packed Workflow at #main')
images = []
def collect(value):
    if isinstance(value, dict):
        if 'dockerPull' in value:
            images.append(value['dockerPull'])
        for child in value.values():
            collect(child)
    elif isinstance(value, list):
        for child in value:
            collect(child)
collect(package)
if not images:
    raise ValueError('Package has no container references')
for image in images:
    if not isinstance(image, str) or not re.fullmatch(r'[^/]+/.+@sha256:[a-f0-9]{64}', image):
        raise ValueError(f'Expected a registry-hosted image pinned by digest: {image}')
    if image.split('/')[0].split(':')[0] in {'localhost', '127.0.0.1'}:
        raise ValueError(f'Local images cannot be used in the portable lab: {image}')
print('Published package uses digest-pinned registry images')
PY
cwltool --validate "$staging/workflow.cwl#main" "$staging/params.yaml"
cp "$staging/workflow.cwl" "$destination/app-water-bodies-cloud-native.cwl"
cp "$staging/params.yaml" "$destination/params.yaml"
printf 'Prepared %s from %s\n' "$version" "$repository"
