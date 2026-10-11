### Goal

Run `stac` in the same Hatch environment used by the
[practice notebook](https://github.com/eoap/mastering-app-package/blob/feature/metadata/practice-labs/1-Application_Steps/stac.ipynb).
The notebook is stored at `practice-labs/1-Application_Steps/stac.ipynb`.

### Requirements

Install Python 3.12 or newer, Hatch, and Task. Run the Otsu lab first to create `otsu.tif`. The source STAC item must be reachable.
See [developer tooling](../development.md) for the available tasks.

### Register the notebook kernel

From the checkout root, run:

```bash
task kernel:install TOOL=stac
```

Select **Bash (stac Hatch)** in Jupyter or VS Code. This kernel uses the
package's default Hatch environment. An ordinary Bash kernel can also activate
that environment using the commands below. Run the workspace setup from inside
the checkout so Git can locate its root.

### Configure the workspace

```bash
export WORKSPACE="$(git rev-parse --show-toplevel)"
export RUNTIME=${WORKSPACE}/runs
mkdir -p "${RUNTIME}"
cd "${RUNTIME}"
```

Outputs are written to `runs/` in the current checkout.

### Activate the Hatch environment

```bash
cd "${WORKSPACE}/water-bodies/command-line-tools/stac"
hatch env create default
source "$(hatch env find default)/bin/activate"
cd "${RUNTIME}"

which python
which stac
stac --help
```

Hatch installs the Python project and its dependencies; a separate `pip install`
cell is unnecessary. Activation keeps the console command available after changing
to the output directory.

### Run the step

```bash
stac \
    --item "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A" \
    --rasters otsu.tif
```

Repeat `--item` and `--rasters` for multiple acquisitions in corresponding order. The catalog copies each mask into its item directory and uses relative asset links.

### Expected outcome

The step adds these files under `runs/`:

```text
catalog.json
S2B_10TFK_20210713_0_L2A/S2B_10TFK_20210713_0_L2A.json
S2B_10TFK_20210713_0_L2A/otsu.tif
```

Earlier steps' outputs remain available.

### Inspect the catalog

The processing package and stactools both provide a command named `stac`.
Run the optional inspector in a separate uv environment so it does not replace
the processing command in the Hatch environment:

```bash
uv run --no-project --with 'stactools[validate]==0.5.3' --with 'requests==2.34.2' \
  stac describe "${RUNTIME}/catalog.json"
```

### Finish the session

```bash
deactivate
```

Keep the Hatch environment for subsequent runs. The pip-based scripts under
`scripts/` remain an alternative for manual shell use.
