"""Stage-in command-line interface."""

import click

from stage.stage_in_impl import execute

stage_in = click.Command(
    name="stage-in",
    callback=execute,
    help="Download a STAC item and its assets into a self-contained catalog.",
    params=[
        click.Option(["--reference"], required=True, help="STAC item URL or local path."),
        click.Option(["--http-timeout"], type=click.FloatRange(min=1), default=300, show_default=True, help="HTTP transfer timeout in seconds."),
        click.Option(["--asset", "asset_keys"], multiple=True, help="Download only these STAC asset keys; repeat for multiple assets."),
    ],
)
