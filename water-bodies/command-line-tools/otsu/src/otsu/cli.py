"""Command-line interface for Otsu thresholding."""

import click

from otsu.otsu_impl import execute

otsu = click.Command(
    name="otsu",
    callback=execute,
    help="Apply Otsu thresholding to a raster.",
    params=[click.Argument(["raster"], type=click.Path(exists=True, dir_okay=False))],
)
