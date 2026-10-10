# norm_diff

Writes `norm_diff.tif` as a float32 COG using `(first - second) / (first + second)`. Inputs must share a raster grid. Zero denominators retain NumPy NaN/infinity behavior.

## Hatch setup

From the repository root:

```bash
cd water-bodies/command-line-tools/norm_diff
hatch env create default
source "$(hatch env find default)/bin/activate"
```

Python 3.12 or newer and Hatch are required. Run the command from the directory where outputs should be written:

```bash
norm_diff --rasters green.tif --rasters nir.tif
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
podman build -t localhost:norm-diff:latest water-bodies/command-line-tools/norm_diff
```

The Dockerfile builds a wheel with Hatchling through pip and installs it in a non-root runtime environment.
Invoke the installed console command explicitly, for example `podman run --rm localhost/norm-diff:latest norm_diff --help`.

## License

See [LICENSE.md](LICENSE.md).

## CLI source

`src/norm_diff/cli.py` defines the console interface. Processing logic lives in `norm_diff_impl.py`. Update the CLI and CWL bindings together when changing arguments.
