"""Command-line interface for normalized difference."""

import click

from norm_diff.norm_diff_impl import execute


@click.command(help="Calculate normalized difference from two ordered rasters.")
@click.argument("rasters", nargs=-1, type=click.Path(exists=True, dir_okay=False))
@click.option(
    "--rasters",
    "raster_pair",
    nargs=2,
    type=click.Path(exists=True, dir_okay=False),
    help="Two rasters, in numerator order (first minus second).",
)
def norm_diff(rasters: tuple[str, ...], raster_pair: tuple[str, ...] | None) -> None:
    if rasters and raster_pair:
        raise click.UsageError("Use positional rasters or --rasters, not both")
    execute(rasters=rasters or raster_pair or ())
