# Stage out

Upload a local STAC catalog and its assets to S3. The input directory is copied
to a temporary directory before links are rewritten; the original stays intact.

From this directory:

```bash
hatch run stage-out --help
hatch run stage-out /path/to/catalog bucket-name results/run-1
```

Set `aws_access_key_id`, `aws_secret_access_key`, `aws_region_name`, and
`aws_endpoint_url` in the environment. Credentials are never command-line arguments.
The command prints the uploaded catalog's S3 URL to stdout and logs to stderr.

```bash
hatch run test:test
hatch build
podman build -t localhost/stage-out:latest .
```

`cwl-cli/stage-out.cwl` invokes this command with the same positional arguments
and environment settings. Build the image before running that CWL tool.

Python 3.12 or newer is required. Alternatively, install with `python -m pip install -e .` in a virtual environment. The multistage image installs a Hatchling-built wheel in `/app/venv` and runs as UID/GID 2000. Licensed under [CC-BY-SA-4.0](LICENSE.md).
