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

Validation on 10 October 2026 passed all 18 practice notebooks on the Docker
Minikube profile, including the direct Calrissian run, Kubernetes Job, benchmark
workflows, Gantt chart, and report tables. The tested tool snapshot was
`3292d39` plus the fixes in `361275e`, with the notebook changes documented here;
concurrent tool-packaging edits were not copied into that deployment. Remote
raster reads needed bounded retries, and an earlier Job attempt failed during
a transient external DNS outage. Final successful notebook outputs are in
`/workspace/lab-results/20261010T180151267666Z/` (Calrissian) and
`/workspace/lab-results/20261010T180519884005Z/` (benchmark).
