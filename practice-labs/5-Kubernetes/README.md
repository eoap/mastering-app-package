# Test the checked-out CWL on Minikube

These notebooks use the current checkout, including `feature/metadata`, rather
than downloading an older released application package. No new CWL release is
needed for local validation. Notebook 1 packs the typed workflow and rewrites
its container tags to `localhost/<tool>:metadata`; notebook 2 benchmarks that
same package through the Calrissian CLI and its JSON usage report.

With the editor deployed by `dev-platform-eoap/mastering-app-package`, run from
that deployment module directory:

```bash
task labs LAB='[1-4]*' MINIKUBE_PROFILE=eoap-mastering-app-package-docker
task labs:kubernetes-images MINIKUBE_PROFILE=eoap-mastering-app-package-docker
task labs LAB=5-Kubernetes MINIKUBE_PROFILE=eoap-mastering-app-package-docker
```

Chapter 2 builds the four tool images using Podman inside the editor. The image
loading task copies those images into the Minikube node; the `metadata` tag
avoids Kubernetes' default pull behavior for `latest`. Run the loading task
again after rebuilding an image. Notebook 1 runs both the installed Calrissian
command and a Kubernetes Job using the same local PDE image as the editor.
The local Job example uses `eoepca/pde-code-server:amd64`; change its image when
using a different PDE build. Each notebook uses the checked-out typed scatter
parameters. The Job is recreated on repeat runs, and the benchmark stores each
run's parameters, outputs, tool logs, and usage report under `/calrissian/benchmark-*`.
The Job retains its status for an hour, and the notebook reports a failed Job
instead of waiting only for success. Retry the lab explicitly after a transient
network failure.

Published deployments still need accessible, versioned container images and a
published or otherwise distributed application package. This local test path
does not publish images, a CWL release, or the working branch.

Validation on 10 October 2026 passed all 18 practice notebooks on profile
`eoap-mastering-app-package-docker`, including the direct Calrissian run,
Kubernetes Job, both benchmark executions, Gantt chart, and report tables.
The packaged-tool snapshot was `b5275c0` with fixes `ffc625f` and `de098fb`.
The concurrent Hatch notebooks and environments were also copied into the
editor: all four chapter 1 notebooks and `task code:test:all` (29 tests) passed.
The Hatch changes remain WIP. A separate stage-out CWL roundtrip passed against
SeaweedFS, checking uploaded catalog, item, and asset content before cleanup.

Otsu needed 1024 MiB rather than 512 MiB; normalized difference retains 2048 MiB.
Remote raster reads needed bounded retries. Successful chapter 5 notebooks are
in `/workspace/lab-results/20261010T192341432327Z/`, copied to the host at
`/tmp/mastering-metadata-packaged-kubernetes`.
