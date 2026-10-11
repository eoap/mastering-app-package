"""Stage-in command-line interface."""

import click

from stage.stage_in_impl import execute

stage_in = click.Command(
    name="stage-in",
    callback=execute,
    help="Download a STAC item and its assets into a self-contained catalog.",
    params=[click.Option(["--reference"], required=True, help="STAC item URL or local path.")],
)
