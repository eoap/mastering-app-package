### Goal 

Create a container and run the `otsu` step in the container image tagged `localhost/otsu:latest`.

### Lab

This step has a dedicated lab available at /workspace/mastering-app-package/practice-labs/Containers/otsu.ipynb

### Container

Each step has its own recipe to build the container image.

The `otsu` step container image recipe is:

```dockerfile linenums="1" title="otsu/Dockerfile"
--8<--
water-bodies/command-line-tools/otsu/Dockerfile
--8<--
```

Build the container image with:

```bash linenums="1" title="terminal"
--8<--
scripts/build_container_otsu.sh
--8<--
```

### Run the container

The command to run the `otsu` step in the container is:

```bash linenums="1" hl_lines="5-7 13 17"
--8<--
scripts/podman-otsu.sh
--8<--
```

### Step

Run the command to run the `otsu` step with:

```
sh -x ${WORKSPACE}/scripts/podman-otsu.sh
```

### Expected outcome

The folder `/workspace/mastering-app-package/runs` contains: 

```
(base) jovyan@coder-mrossi:~/runs$ tree .
.
├── crop_green.tif
├── crop_nir.tif
├── norm_diff.tif
└── otsu.tif

0 directories, 4 files
```