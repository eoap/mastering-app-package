# stac

Writes `catalog.json` and an item directory containing each mask. Repeat both options for multiple pairs in corresponding order. Inputs may be STAC item URLs, local item files, or staged catalog directories. Item IDs must be unique directory names.

## Hatch setup

From the repository root:

```bash
cd water-bodies/command-line-tools/stac
hatch env create default
source "$(hatch env find default)/bin/activate"
```

Python 3.12 or newer and Hatch are required. Run the command from the directory where outputs should be written:

```bash
stac --item source-item.json --rasters otsu.tif
```

Run `deactivate` when finished. Progress and failures are logged by Loguru for the local processing tools.

## Checks and tests

From this package directory:

```bash
hatch run test:test
```

The Ruff complexity limit is 4. Tests use local fixtures rather than remote imagery.

## Container

From the repository root:

```bash
podman build -t localhost/stac:latest water-bodies/command-line-tools/stac
```

The Dockerfile builds a wheel with Hatchling through pip and installs it in a non-root runtime environment.
Invoke the installed console command explicitly, for example `podman run --rm localhost/stac:latest stac --help`.

## License

See [LICENSE.md](LICENSE.md).

## CLI source

`src/stac/cli.py` defines the console interface. Processing logic lives in `stac_impl.py`. Update the CLI and CWL bindings together when changing arguments.
