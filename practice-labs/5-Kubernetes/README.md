# Run a published application package on Kubernetes

Chapter 5 uses a published packed CWL application and registry-hosted container
images pinned by digest. It runs on any Kubernetes cluster configured for
Calrissian; building images locally or loading them into Minikube is not required.

Prepare Calrissian, its service account and RBAC, a shared RWX PVC mounted at
`/calrissian`, and the node-selector file expected by the notebooks. Nodes need
registry and STAC-data access. Adjust the namespace, PVC, service-account names,
and Calrissian runner image in `k8s-job.yaml` for your deployment. The example
runner command is `/opt/calrissian-venv/bin/calrissian`.

Notebook 1 downloads the selected release's CWL and matching typed scatter
parameters, validates them, then runs Calrissian directly and through a Job.
Notebook 2 benchmarks that same workflow and `/calrissian/params.yaml`.

The default release version is `2.0.0`, once published. Before the final release,
select an already published candidate in notebook 1's Bash environment:

```bash
export APPLICATION_PACKAGE_VERSION=2.0.0-rc.<run-number>.<run-attempt>
```

Use the actual candidate tag from GitHub Releases. The preparation helper fails
explicitly if the selected release is unavailable. It does not fall back to
local images, an older release, or a different input contract.

## Test before releasing

1. Publish a candidate using the release workflow on `develop`, with
   `channel=candidate`. It produces a GitHub prerelease and digest-pinned images
   and CWL under a unique `2.0.0-rc.<run-number>.<run-attempt>` version.
2. Confirm the images are accessible to the target cluster. GHCR package
   visibility and credentials must allow its nodes to pull them.
3. Set that candidate version, execute both notebooks and the Job, and verify
   results, logs, usage reports, and benchmark outputs.
4. Record the candidate tag, source commit, cluster, image digests and results.
   Resolve failures and publish a fresh candidate before retesting.
5. Merge the tested changes into the release branch only after this validation.
   CI then builds and publishes the stable `2.0.0` artifacts from that branch.

Stable publication rebuilds the images; it does not promote candidate digests.
Run a smoke test against the stable release before presenting it as the lab's
validated default. Any source changes after candidate testing require another
candidate test.

The previous local Minikube runs established developer validation only; they
are not evidence that nodes can pull the published images. Local image loading
can remain an optional development technique outside this lab's default path.
