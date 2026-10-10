# Changelog

## Unreleased

### Fixed

- Chapter 5 downloads published CWL and matching inputs with registry-hosted,
  digest-pinned images instead of requiring Minikube-local builds.
- Added prerelease candidate publication for cluster testing before a stable release.

## [2.0.0] - 2026-10-10

### Breaking changes

- Workflow inputs now use EOAP schemas: AOIs are GeoJSON Polygon objects,
  cloud-native item references are URI records, and CRS and band values use
  shared named enums. Existing string and bounding-box jobs must be migrated.
- Processing tools are Python packages with console commands. Container and
  workflow invocations use `crop`, `norm-diff`, `otsu`, and `stac`, replacing
  direct `app.py` execution and the previous command bindings.
- Modern processing and staging packages require Python 3.12 or later.

### Added

- Packaged stage-in and stage-out commands, tests, wheels, and portable
  multistage container images running as a non-root user.
- Taskfile commands for testing, validation, packaging previews, and docs;
  Hatch environments and dedicated Bash kernels for application-step notebooks.
- Generated workflow documentation and locally rendered SVG diagrams.
- FAIR exercises for citations, Workflow RO-Crates, optional Zenodo Sandbox
  publication, and execution provenance.
- Release CI gates for package tests and fixable HIGH/CRITICAL vulnerabilities;
  digest-pinned packed CWL artifacts, cwl2oci annotations, and verified ORAS
  publication to GHCR before GitHub release publication.

### Changed

- Updated notebooks and guides for packaged commands, typed inputs, current
  Calrissian jobs, benchmarking, and CLI execution from Python.
- Redesigned documentation navigation with code copying, diagram support,
  image zoom, and pinned documentation dependencies.
- Aligned CodeMeta and CWL licensing with the repository's CC-BY-SA-4.0 license.
- Pinned processing dependencies, including Rasterio 1.5.2, Click 8.5.0,
  PySTAC 1.15.2, Loguru 0.7.3, Shapely 2.1.2, scikit-image 0.26.0,
  and rio-stac 0.12.0, as applicable to each package.

### Fixed

- EOAP metadata validation findings and stale documentation and notebook links.
- Crop geometry masking, bounded remote raster reads, and processing memory
  requirements for normalization and Otsu.
- Stage-in failure handling and stage-out catalog copying and upload paths.
- Checked-out typed CWL packing and validation in the Kubernetes practice lab.

### Migration

- Start from `cwl-workflow/typed-cloud-native-inputs.yaml` for a single-item
  cloud-native job. For scattering, use `stac_items` as a list of URI records
  instead of the single `item` field. Supply `aoi` as a GeoJSON Polygon,
  `epsg: "4326"`, and `bands: [green, nir]`.
- Install the Python packages or use the rebuilt images, and update direct
  invocations to the console commands shown in the application-step labs.
- Install Hatch notebook kernels using the Taskfile instructions in
  `docs/development.md`.
- Historical released CWL examples remain available with their original
  interfaces and image references; they are separate from the 2.0.0 artifacts.
- Retrieve a released workflow by its OCI digest and execute its packed
  `#main` entrypoint. Local source workflows select `#water-bodies`.
