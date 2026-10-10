# otsu

Writes `otsu.tif` as a uint8 COG with 0 for non-water and 1 for water. The threshold is computed from finite values; nonfinite pixels are marked 0. An input with no finite values is rejected.

## Hatch setup

From the repository root:

```bash
cd water-bodies/command-line-tools/otsu
hatch env create default
source "$(hatch env find default)/bin/activate"
```

Python 3.12 or newer and Hatch are required. Run the command from the directory where outputs should be written:

```bash
otsu --raster norm_diff.tif
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
podman build -t localhost:otsu:latest water-bodies/command-line-tools/otsu
```

The Dockerfile builds a wheel with Hatchling through pip and installs it in a non-root runtime environment.
Invoke the installed console command explicitly, for example `podman run --rm localhost/otsu:latest otsu --help`.

## License

See [LICENSE.md](LICENSE.md).

## CLI source

`src/otsu/cli.py` defines the console interface. Processing logic lives in `otsu_impl.py`. Update the CLI and CWL bindings together when changing arguments.
