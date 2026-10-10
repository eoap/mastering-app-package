# Stage in

Stage a STAC item and its assets into the current directory. The `stage-in` command writes `catalog.json` and an item directory containing the downloaded assets, matching the output of `cwl-cli/stage-in.cwl`.

## Hatch setup

From the repository root:

```bash
cd water-bodies/command-line-tools/stage-in
hatch env create default
source "$(hatch env find default)/bin/activate"
```

Python 3.12 or newer and Hatch are required. Run the command from the directory where outputs should be written:

```bash
stage-in --reference /path/to/item.json
# Remote STAC item URLs are also accepted.
stage-in --help
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
podman build -t localhost/stage-in:latest water-bodies/command-line-tools/stage-in
```

The Dockerfile builds a wheel with Hatchling through pip and installs it in a non-root runtime environment.

## License

See [LICENSE.md](LICENSE.md).

Alternatively, install with `python -m pip install -e .` in a Python 3.12 or newer virtual environment. The container runs as UID/GID 2000, with `stage-in` installed in `/app/venv/bin`.

Failed asset downloads fail the command before catalog publication. HTTP requests have a 60-second timeout and up to three attempts.

## Developer tasks and notebook kernel

From the repository root, run `task code:test TOOL=stage-in` to test this package,
or `task kernel:install TOOL=stage-in` to register **Bash (stage-in Hatch)**.
See [developer tooling](../../../docs/development.md) for checks and CLI previews.
