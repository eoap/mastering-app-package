#!/usr/bin/env python3
"""Register a Bash kernel using the active Hatch environment's interpreter."""
import argparse
import json
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

from jupyter_client.kernelspec import KernelSpecManager

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('tool', choices=['crop', 'norm_diff', 'otsu', 'stac', 'stage-in', 'stage-out'])
parser.add_argument('--prefix', type=Path, help='Install under this prefix instead of the user Jupyter directory')
args = parser.parse_args()
spec = {
    'argv': [sys.executable, '-m', 'bash_kernel', '-f', '{connection_file}'],
    'display_name': f'Bash ({args.tool} Hatch)',
    'language': 'bash',
    'env': {'PATH': str(Path(sys.executable).parent) + ':${PATH}', 'VIRTUAL_ENV': sys.prefix},
}
with TemporaryDirectory() as directory:
    Path(directory, 'kernel.json').write_text(json.dumps(spec), encoding='utf-8')
    installed = KernelSpecManager().install_kernel_spec(
        directory, kernel_name='bash-' + args.tool,
        user=args.prefix is None, prefix=str(args.prefix) if args.prefix else None,
    )
print(f"Installed {spec['display_name']}: {installed}")
