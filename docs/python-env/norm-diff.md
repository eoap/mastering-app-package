### Goal

Run `norm_diff` in the same Hatch environment used by the
[practice notebook](https://github.com/eoap/mastering-app-package/blob/feature/metadata/practice-labs/1-Application_Steps/normalized-difference.ipynb).
The notebook is stored at `practice-labs/1-Application_Steps/normalized-difference.ipynb`.

### Requirements

Install Python 3.12 or newer, Hatch, and Task. Run the crop lab first to create `crop_green.tif` and `crop_nir.tif`.
See [developer tooling](../development.md) for the available tasks.

### Register the notebook kernel

From the checkout root, run:

```bash
task kernel:install TOOL=norm_diff
```

Select **Bash (norm_diff Hatch)** in Jupyter or VS Code. This kernel uses the
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
cd "${WORKSPACE}/water-bodies/command-line-tools/norm_diff"
hatch env create default
source "$(hatch env find default)/bin/activate"
cd "${RUNTIME}"

which python
which norm_diff
norm_diff --help
```

Hatch installs the Python project and its dependencies; a separate `pip install`
cell is unnecessary. Activation keeps the console command available after changing
to the output directory.

### Run the step

```bash
norm_diff \
    --rasters crop_green.tif \
    --rasters crop_nir.tif
```

Supply exactly two rasters with repeated `--rasters` options. Their dimensions, transforms, and coordinate systems must match.

### Expected outcome

The step adds these files under `runs/`:

```text
norm_diff.tif
```

Earlier steps' outputs remain available.

### Finish the session

```bash
deactivate
```

Keep the Hatch environment for subsequent runs. The pip-based scripts under
`scripts/` remain an alternative for manual shell use.
