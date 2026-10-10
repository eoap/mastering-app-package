# Publish a FAIR application package

A reusable application package needs a clear description, identifiable software
and containers, instructions for running it, and a way to credit its authors.
This tutorial turns the water-bodies workflow into a citable research object
using [Transpiler-Mate](https://github.com/transpiler-mate) plugins.

The exercise generates files locally. The final, optional exercise publishes a
record to **Zenodo Sandbox**. Keep sandbox identifiers separate from production
release metadata.

## What you will produce

| Result | Purpose | Generator |
| --- | --- | --- |
| Packed CWL | Executable workflow with embedded tool and schema definitions | Release CI / cwltool |
| OCI annotations and immutable registry reference | Describe and retrieve a specific workflow artifact | cwl2oci / ORAS |
| CFF, BibTeX, RIS and CSL-JSON citations | Credit the workflow's authors and identify its version | cwl2citation |
| Workflow RO-Crate ZIP | Package the workflow, metadata and supporting files | cwl2rocrate |
| Sandbox record and DOI | Practise depositing and identifying the package | invenio-publish |

These outputs support FAIR practices; generating them does not automatically
make the workflow discoverable in a catalog or preserve every dependency.

## Prepare the environment

Run from the repository root, with Python 3.12 available:

```bash
python3.12 -m venv .venv-fair
source .venv-fair/bin/activate
python -m pip install -r scripts/requirements-cwl-fair.txt
mkdir -p runs/fair
```

The pinned plugins share the `transpiler-mate` executable. The RO-Crate plugin's
package name is `cwl2ro-crate`, but its command is `cwl2rocrate`.

## Check the metadata before generating artifacts

The workflow's document-level `s:` fields describe the application. Its selected
process defines the executable interface. Inspect both:

```bash
sed -n '1,38p' cwl-workflow/app-water-bodies-cloud-native.cwl
cat codemeta.json
```

Check the following before a real publication:

- Replace Jane Doe and John Doe training examples with the actual authors and
  affiliations. Preserve their intended order in citations.
- Match the license in `LICENSE.md`, CodeMeta and CWL. This repository uses
  `CC-BY-SA-4.0`; the SPDX URL in CodeMeta and the CWL license identifier must agree.
- Give the package a meaningful name, description, source repository and help URL.
- Distinguish creation dates from release dates. Do not present `dateCreated`
  as the publication date of a new version.
- Use a new release version and check that the generated artifacts describe it.

`codemeta.json` currently supplies the release version to CI. Source workflows
can retain their individual development versions; the release preparation job
sets the version and repository on copies before packing. Generate release
citations and crates from those final copies, so all published outputs agree.
The current `1.1.0` CodeMeta version is already released and must be bumped for
a new publication through CI.

The [release tutorial](../release/ci.md) explains that process. Keep generated
CodeMeta separate from the CI input: the
[cwl2codemeta plugin](https://github.com/transpiler-mate/cwl2codemeta) converts CWL
metadata to CodeMeta 3.0, while this repository's root file uses CodeMeta 2.0.
Switching the authoritative metadata source requires an explicit migration.

## Select and pack the workflow

For a local practice run, pack the checked-out scattering workflow:

```bash
python scripts/pack-cwl-release.py \
  cwl-workflow/app-water-bodies-cloud-native.cwl \
  runs/fair/workflow.cwl
export FAIR_WORKFLOW="$(pwd)/runs/fair/workflow.cwl"
cwltool --validate "${FAIR_WORKFLOW}#main"
```

The source entrypoint is `#water-bodies`; the packing script selects it and
renames it to `#main`. It also preserves package metadata and embeds imported
schema definitions.

For a release exercise, substitute the verified packed CWL downloaded from
GitHub or pulled from GHCR for `FAIR_WORKFLOW`. The local practice file still
contains development image references. Release files use immutable image
references recorded by CI.

A container or workflow reference ending in `@sha256:...` identifies registry
content. Retention and access still depend on the registry. A source commit,
a workflow artifact digest, a Software Heritage identifier and a DOI identify
different objects; record the relationships between them.

## Generate citations

Generate citations from the selected workflow's document-level metadata:

```bash
transpiler-mate cwl2citation \
  --code-repository https://github.com/eoap/mastering-app-package.git \
  --output runs/fair/citations \
  "${FAIR_WORKFLOW}#main"
```

Inspect `CITATION.cff`, `citation.bib`, `citation.ris`, `citation.csl.json` and
`citation.txt` under `runs/fair/citations`. Check the authors, title and version.
CFF and CSL-JSON are schema-validated by the plugin. An absent DOI remains absent;
this command does not register one.

The plugin rejects existing output files. Use a fresh destination for another
run. For a real repository release, review the generated `CITATION.cff` before
placing it at the repository root; this local exercise leaves it under `runs/`.
See the [citation plugin documentation](https://github.com/transpiler-mate/cwl2citation)
for release dates, citation styles and individual output formats.

## Package a Workflow RO-Crate

Include the generated citation and a runnable input example with the workflow:

```bash
transpiler-mate cwl2rocrate \
  --output runs/fair/workflow-crate \
  --zip \
  --attach runs/fair/citations/CITATION.cff \
  --attach cwl-workflow/typed-cloud-native-inputs.yaml \
  "${FAIR_WORKFLOW}#main"
```

Inspect `runs/fair/workflow-crate/ro-crate-metadata.json`, its packed
`workflow.cwl`, and the files under `attachments/`. The ZIP is written beside
the directory as `runs/fair/workflow-crate.zip`.

The plugin validates the crate against the bundled REQUIRED-level profiles.
Validation can need network access for JSON-LD contexts. Use a new output
location when repeating the exercise.

A Workflow RO-Crate describes and packages the workflow. It does not execute it
or download referenced container images and external STAC assets. The input
example can reference external data whose availability must be considered
separately. See the [RO-Crate plugin documentation](https://github.com/transpiler-mate/cwl2ro-crate)
for attachment and validation details.

## Optional: publish to Zenodo Sandbox

This step creates and **publishes** a sandbox record. Review the workflow's
metadata and attachments first. Obtain a token from your own
[Zenodo Sandbox](https://sandbox.zenodo.org/) account; production Zenodo tokens
and records are separate.

Read the token without putting it into shell history:

```bash
read -rsp 'Zenodo Sandbox token: ' INVENIO_TOKEN
printf '\n'
export INVENIO_TOKEN
transpiler-mate invenio-publish \
  --base-url https://sandbox.zenodo.org/ \
  --auth-token "$INVENIO_TOKEN" \
  --attach "$FAIR_WORKFLOW" \
  --attach runs/fair/workflow-crate.zip \
  --attach runs/fair/citations/CITATION.cff \
  "${FAIR_WORKFLOW}#main"
unset INVENIO_TOKEN
```

Without a DOI in `s:identifier`, the plugin creates a record, reserves a DOI,
uploads attachments and publishes. With an existing DOI there, it creates and
publishes a new version. Review the resulting record and its download links.
See [invenio-publish](https://github.com/transpiler-mate/invenio-publish) for the
metadata contract and versioning workflow.

Keep the returned sandbox DOI in your practice notes. For a production deposit,
record the real identifier in the corresponding release metadata and maintain
a distinction between an individual version's DOI and a concept DOI.
`cwl2citation --doi <doi>` can generate a fresh citation set after publication.
The deposit already uploaded above contains the original citation files;
regenerating local citations does not update that record automatically.

Schema.org's identity-link property is case-sensitive: use `s:sameAs`, not
`s:sameas`. The citation and publication plugins use `s:identifier` for DOI
handling. Keep these fields consistent when both are present. Generating
[DataCite metadata](https://github.com/transpiler-mate/cwl2datacite) is another
export operation; it does not itself register a DOI.

## Connect the exercise to release CI

The current [CI workflow](../release/ci.md) already publishes packed CWL,
`cwl2oci` annotations, OCI manifests and immutable artifact references. Citation
and RO-Crate generation in this exercise remain local; CI does not yet generate
or deposit them.

A future release job can generate citations and a Workflow RO-Crate from the
same verified packed CWL, then attach those outputs to the GitHub release.
Zenodo publication should be a separately configured publication step with
explicit credentials and a policy for identifying new versions.

## Continue with discovery and execution provenance

| Extension | Exercise | What it establishes |
| --- | --- | --- |
| [cwl2ogcrecords](https://github.com/transpiler-mate/cwl2ogcrecords) | Generate a record and ingest it into an OGC API – Records catalog | Searchable application metadata once cataloged |
| [cwl2ogc](https://github.com/transpiler-mate/cwl2ogc) | Generate process descriptors and JSON Schemas | A machine-readable interface for OGC API – Processes integration |
| [cwl2inputs](https://github.com/transpiler-mate/cwl2inputs) | Generate and complete an input template | A starting point for running the workflow |
| [cwl2sbom](https://github.com/transpiler-mate/cwl2sbom) | Inventory digest-pinned release images for an explicit platform | Declared container dependencies, image SBOMs and coverage information |

SBOM generation complements CI vulnerability scanning. It does not publish or
sign its output, and it does not inventory all possible runtime downloads or
host tools. Retain the coverage report with the SBOMs.

To describe an actual execution, capture CWLProv using your normal runner and
input settings, then convert that execution directory:

```bash
cwltool --provenance runs/fair/execution.provenance \
  "${FAIR_WORKFLOW}#main" cwl-workflow/typed-cloud-native-inputs.yaml
transpiler-mate cwl2rocrate \
  --run runs/fair/execution.provenance \
  --output runs/fair/run-crate --zip \
  "${FAIR_WORKFLOW}#main"
```

Run this advanced exercise only after configuring the container runtime and
input data as described in the workflow labs. Use the exact workflow that was
executed. The plugin checks the CWLProv bag and workflow match; it does not
execute the workflow or invent execution records. Recorded data may make the
result much larger than a Workflow RO-Crate.

Source preservation remains a separate activity. Archive the source repository
with [Software Heritage](https://www.softwareheritage.org/) and record its SWHID
alongside the release commit, workflow digest and publication identifier.

Deactivate the tutorial environment when finished:

```bash
deactivate
```
