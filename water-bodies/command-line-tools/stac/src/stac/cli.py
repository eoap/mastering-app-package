"""Command-line interface for STAC catalog creation."""

import click

from stac.stac_impl import execute

stac = click.Command(
    name="stac",
    callback=execute,
    help="Create a STAC catalog of water body masks.",
    params=[
        click.Option(["--input-item", "item_urls"], required=True, multiple=True),
        click.Option(
            ["--water-body", "water_bodies"],
            required=True,
            multiple=True,
            type=click.Path(exists=True, dir_okay=False),
        ),
    ],
)
