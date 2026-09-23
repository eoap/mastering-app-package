"""Command-line entry point for staging results to S3."""

from pathlib import Path

import click

from stage_out.stage_out_impl import execute


@click.command()
@click.argument(
    "catalog", type=click.Path(exists=True, file_okay=False, path_type=Path)
)
@click.argument("bucket")
@click.argument("subfolder")
def stage_out(catalog: Path, bucket: str, subfolder: str) -> None:
    """Upload CATALOG and its assets to BUCKET under SUBFOLDER.

    Credentials and endpoint settings come from the aws_access_key_id,
    aws_secret_access_key, aws_region_name and aws_endpoint_url environment variables.
    """
    click.echo(execute(catalog, bucket, subfolder))
