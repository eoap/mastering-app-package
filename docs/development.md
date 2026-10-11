# Developer tooling

Install Python 3.12 or newer, [Task](https://taskfile.dev), Hatch, and uv.
Run tasks from the checkout root. `task --list` shows all commands.

Select a package with `TOOL=crop`, `norm_diff`, `otsu`, `stac`, `stage-in`, or
`stage-out`. Hatch creates isolated environments and installs the selected package.

| Command | Purpose |
| --- | --- |
| `task code:test TOOL=crop` | Run one package's tests |
| `task code:test:all` | Run all six package suites and the processing chain |
| `task code:check TOOL=crop` | Check Ruff lint rules |
| `task code:lint TOOL=crop` | Check formatting |
| `task code:format TOOL=crop` | Apply formatting |
| `task code:typecheck TOOL=crop` | Run mypy |
| `task code:security TOOL=crop` | Run Bandit |
| `task cwl:validate` | Validate all tracked CWL documents |
| `task docs:serve` | Preview documentation |
| `task docs:build` | Build documentation |

Checks report existing diagnostics and return a failing status when they find
issues. `code:format` modifies files; lint checks do not. Pass tool arguments after
`--`, for example `task code:test TOOL=crop -- -q`.

## Generate a CLI preview

`task code:bootstrap:crop` runs cwl2click against the scatter workflow and writes
to `runs/generated-cli`. Equivalent aliases exist for `norm_diff`, `otsu`, and
`stac`. Review the preview and reconcile it with the current implementation and
CWL bindings before copying files into a package. Imported named enums currently
generate as string options, so retain the existing CLI choices when reconciling
the preview. Repeated generation replaces
the preview. Override `WORKFLOW` or `GENERATED_DIR` when needed.

The staging tools use handwritten CLI interfaces. Their CWL documents preserve
existing job inputs; the processing workflow does not contain staging tool IDs.

## Hatch notebook environments

Run `task kernel:crop` or `task kernel:install TOOL=otsu` to register a Bash kernel
for a package's default Hatch environment. Select **Bash (crop Hatch)** (or the
corresponding package) in Jupyter or VS Code. The interpreter, PATH, and
VIRTUAL_ENV refer to the Hatch environment, so commands remain available when
the notebook changes directories. Application-step notebooks also show manual
activation for an ordinary Bash kernel.

Kernel registration writes to the user Jupyter data directory. To install under
a different prefix, use `task kernel:crop -- --prefix /path/to/prefix`. Re-register
a kernel if its Hatch environment is removed or recreated at another location.

## Documentation preview

`task docs:serve` uses the same pinned dependencies as the documentation deployment
in `scripts/requirements-docs.txt`. The site groups pages under Home, Build, Run,
Publish, and Reference tabs. Images open in a zoomable viewer with alt-text
captions; Mermaid diagrams retain their normal interaction. Both light and dark
themes use the EOAP palette. `task docs:build` verifies the site locally.
