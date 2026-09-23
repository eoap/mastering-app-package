# stage

Stage a STAC item and its assets into the current directory. The `stage-in` command writes `catalog.json` and an item directory containing the downloaded assets, matching the output of `cwl-cli/stage-in.cwl`. The upstream `stac-asset` command remains available.

## Hatch setup

From the repository root:

```bash
cd water-bodies/command-line-tools/stage
hatch env create default
source "$(hatch env find default)/bin/activate"
```

Python 3.10 or newer and Hatch are required. Run the command from the directory where outputs should be written:

```bash
stage-in --reference /path/to/item.json
# Remote STAC item URLs are also accepted.
stage-in --help
```

Run `deactivate` when finished. Progress and failures are logged by Loguru for the local processing tools.

## Checks and tests

From this package directory:

```bash
hatch check
hatch run test:test
```

The Ruff complexity limit is 4. Tests use local fixtures rather than remote imagery.

## Container

From the repository root:

```bash
podman build -t localhost:stage:latest water-bodies/command-line-tools/stage
```

The Dockerfile builds a wheel with Hatch and installs it in a non-root runtime environment.

## License

See [LICENSE.txt](LICENSE.txt).
