The CWL tool invokes the installed `stage-out <catalog-directory> <bucket>
<prefix>` command in `localhost/stage-out:latest`. Existing job inputs and
credential environment variable names are preserved.

```yaml linenums="1" title="stage-out.cwl"
--8<--
cwl-cli/stage-out.cwl
--8<--
```

The package copies the catalog into a unique temporary directory, uploads its
assets, rewrites their links to S3, and publishes the catalog and item documents.
It traverses nested catalogs recursively and leaves the input directory intact.
Upload failures propagate; the command prints the resulting catalog URI to stdout.

Set `aws_access_key_id`, `aws_secret_access_key`, `aws_region_name`, and
`aws_endpoint_url` through the CWL job inputs. The tool passes them as environment
variables to boto3.

```python linenums="1" title="stage_out_impl.py"
--8<--
water-bodies/command-line-tools/stage-out/src/stage_out/stage_out_impl.py
--8<--
```

Build the staging images:

```bash
--8<--
scripts/build-stage-container.sh
--8<--
```

Run stage-out:

```bash
--8<--
scripts/cwl-cli-stage-out.sh
--8<--
```
