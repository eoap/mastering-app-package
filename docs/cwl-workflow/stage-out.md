Below a `stage-out.cwl` CWL (Common Workflow Language) document for a command-line tool that executes a Python script. 

The document is designed to use a container and execute a Python script named "stage.py":

```yaml linenums="1" hl_lines="50-133"
--8<--
cwl-cli/stage-out.cwl
--8<--
```

The Python script `stage.py` uploads a Spatio-Temporal Asset Catalog (STAC) catalog to an Object Storage S3 bucket. 
This script utilizes the `boto3` library for the S3 operations and customizes the STAC I/O to read from and write to an S3 bucket.

Here's a breakdown of what the script does:

* The script imports necessary libraries and modules, including `os`, `sys`, `pystac`, `botocore`, `boto3`, `shutil`, and more.

* It reads command-line arguments to get the STAC catalog URL, S3 bucket name, and a subfolder path to where the catalog will be uploaded.

* It retrieves the S3 credentials and endpoint URL from environment variables.

* The script copies the STAC catalog (from the given URL) to a temporary directory under "/tmp/catalog."

* A custom STAC I/O class (`CustomStacIO`) is defined. This class extends the `DefaultStacIO` class and uses `boto3` to interact with S3. It has methods for writing STAC text content to S3.

* A connection to S3 is established using `boto3` with the provided S3 credentials and endpoint URL.

* The default STAC I/O class is set to the custom `CustomStacIO`.

* The script iterates through items in the STAC catalog, including their assets. For each asset, it uploads the data to the specified S3 bucket under the given subfolder and updates the asset's href to the S3 location.

* After uploading all assets, it normalizes the catalog's hrefs to point to the S3 location.

* The script then uploads each item in the catalog to S3, updating their hrefs accordingly.

* Finally, it uploads the catalog itself to S3.

* The script prints the S3 URL of the uploaded catalog to the standard output.

This script uploads a STAC catalog and its associated assets to an S3 bucket, making it accessible through the S3 endpoint. 

It uses a custom STAC I/O to facilitate S3 interactions.

The AWS credentials and endpoint URL need to be properly configured in the environment variables for the script to work. A

```bash linenums="1" hl_lines="8-71"
--8<--
scripts/build-stage-container.sh
--8<--

```

To run the stage-out step, one would run:

```bash linenums="1" hl_lines="8-71"
--8<--
scripts/cwl-cli-stage-out.sh
--8<--
```