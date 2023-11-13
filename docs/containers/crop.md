### Goal 

Run the `crop` step in the container image tagged and built in the previous step.

### How to run a step in a container

We'll use `podman` container engine (`docker` is also fine).

The command to run the `crop` step in the container is:

```bash linenums="1" hl_lines="4-5 11 15-22"
--8<--
scripts/podman-crop-green.sh
--8<--
```

Let's break down what this command does:

* `podman run`: This is the command to run a container.
* `-i`: This flag makes the container interactive, allowing you to interact with it via the terminal.
* `--userns=keep-id`: It instructs `podman` to keep the user namespace ID.
`--mount=type=bind,source=/workspace/runs,target=/runs`: This option mounts a directory from the host system to the container. In this case, it mounts the `/workspace/runs` directory on the host to the /runs directory inside the container.
* `--workdir=/runs`: Sets the working directory inside the container to `/runs`.
* `--read-only=true`: Makes the file system inside the container read-only, meaning you can't write or modify files inside the container.
* `--user=1001:100`: Specifies the user and group IDs to be used within the container.
* `--rm`: This flag tells podman to remove the container after it has finished running.
* `--env=HOME=/runs`: Sets the `HOME` environment variable inside the container to `/runs`.
* `--env=PYTHONPATH=/app`: Sets the `PYTHONPATH` environment variable inside the container to `/app`.
* `localhost/crop:latest`: This is the name of the container image that you want to run. It's pulling the image from the local container registry with the name "crop" and the "latest" tag.
* `python -m app`: This is the command to run inside the container. It runs a Python module named "app."
* `--aoi "-121.399,39.834,-120.74,40.472"`: This provides command-line arguments to the Python module. It specifies the area of interest (AOI) as a bounding box.
* `--band green`: Specifies the band to be extracted from the Sentinel-2 acquisition. In this case, it's the "green" band.
* `--epsg "EPSG:4326"``: Specifies the EPSG code, which defines the coordinate system used for the `aoi` command-line argument.
* `--input-item ...`: Specifies the input STAC item URL. This particular URL points to a Sentinel-2 image hosted on AWS Earth Search.

### Steps

Clean-up the `/workspace/runs` folder: 

```
rm -fr /workspace/runs/*
```

Run the command to run the `crop` step with the `green` band in the container with:

```
sh ${WORKSPACE}/scripts/podman-crop-green.sh
```

Run the command to run the `crop` step with the `nir` band in the container with:

```
sh -x ${WORKSPACE}/scripts/podman-crop-nir.sh
```

### Expected outcome

The folder `/workspace/runs` contains: 

```
(base) jovyan@coder-mrossi:~/runs$ tree .
.
├── crop_green.tif
└── crop_nir.tif

0 directories, 2 files
```

