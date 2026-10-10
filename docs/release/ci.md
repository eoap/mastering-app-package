
## Application Package Software Configuration Management

The SCM has the task of tracking and controlling changes in the software as a part of the larger cross-disciplinary field of configuration management. 

SCM practices include revision control and the establishment of baselines.

The Application Package code is hosted on a repository publicly accessible (Github, Bitbucket, a GitLab instance, an institutional software forge, etc.) using one of the version control systems supported by (Subversion, Mercurial and Git)

The Application Package code include, at the top level of the source code tree, the following files:

* README containing a description of the software (name, purpose, pointers to website, documentation, development platform, contact, and support information, …)
* AUTHORS, a list of all the persons to be credited for the software.
* LICENSE, the project license terms. For Open Source Licenses, the standard SPDX license names are used. For large software projects and developers, the REUSE (https://reuse.software/) process and tools can be an option to look at.
* codemeta.json, a linked data metadata file that helps index the source code in the Software Heritage archive and provides an easy way to link to other related research outputs.

The codemeta.json includes metadata information to support the Continuous Integration phase and it is shown below:

```json linenums="1" title="codemeta.json"
--8<--
codemeta.json
--8<--
```

## Application Package Continuous Integration

A typical Continuous Integration scenario for an Application Package includes the release of the CWL document(s) and publishing the container images to a container registry.

This is depicted below: 

``` mermaid
graph TB
SCM[(software repository)] --> T(Test packages and validate CWL)
T --> V(Check new release version)
V --> B(Build images)
B --> S(Scan images)
S --> CR[(Push images to GHCR)]
CR --> P(Update metadata and image digests)
P --> C(Pack and validate CWL)
C --> A(Generate annotations with cwl2oci)
A --> O[(Publish CWL with ORAS)]
O --> R(Pull by digest and verify)
R --> G(Publish GitHub release and assets)
```

Below an example of a GitHub CI configuration implementing the scenario:

```yaml linenums="1" title=".github/workflows/build.yaml"
--8<--
.github/workflows/build.yaml
--8<--
```

The processing test workflow installs and tests the six Python packages, runs
a synthetic processing chain, validates the CWL, and builds wheels and images.
Release image digests are written to mandatory `requirements.DockerRequirement`
entries. `scripts/pack-cwl-release.py` selects the workflow explicitly, embeds
the schema imports, preserves package metadata, and validates the downloaded
artifact as a standalone CWL file.

The release workflow calls the processing test workflow before publishing anything.
Set a new version in `codemeta.json`; an existing GitHub release or tag is rejected.
The workflow runs on changes to release inputs on `main` or `master`, or manually
with `workflow_dispatch`. Concurrent releases are serialized.

Each image is built and scanned with Trivy before it is pushed. Fixable HIGH and
CRITICAL vulnerabilities block publication; the JSON report is retained as a run
artifact, including on scan failure. Unfixed vulnerabilities do not block this
gate. The image jobs record immutable GHCR references for the packaging job,
which updates mandatory Docker requirements and release metadata in isolated
copies of the workflows. Repository source files are not rewritten.

After packing and validation, pinned `transpiler-mate-runtime` and `cwl2oci`
generate the OCI annotations from each final CWL document's `#main` entrypoint.
The generated `$manifest` structure is passed directly to ORAS. The entrypoint
annotation is normalized from the runtime's process identifier to the artifact filename
plus `#main`; source and revision identify the repository and release commit.
These annotations describe the CWL artifacts; they are not Docker image labels.

ORAS publishes the three workflows at
`ghcr.io/<owner>/<repository>/cwl/<workflow>:<version>`, using the project's
`application/cwl` artifact and layer media type. Existing image and CWL tags are
rejected rather than replaced. Each artifact is pulled by digest, compared with
the packed file, checked against the generated annotations, and validated again. `oci-artifacts.txt` records immutable
references. CWL files, annotation JSON files, OCI manifests, and that inventory are attached to
a GitHub draft release, which is published only after every verification and
asset upload succeeds. A failed upload leaves a draft for inspection.

The workflow uses `GITHUB_TOKEN` with `packages: write` only for registry jobs
and `contents: write` only for release creation. GHCR must allow the repository's
token to publish these packages. A failure after image or OCI publication can
leave registry artifacts without a GitHub release; inspect the failed run and
use a new version for the next release. Registry publication is not transactional.
