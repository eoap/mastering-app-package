from cwltool.main import main
import json
import pystac
from io import StringIO
import argparse

version = "1.4.1"


def get_job_order():

    aoi = "-121.399,39.834,-120.74,40.472"
    epsg = "EPSG:4326"
    stac_items = [
        "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2A_10TFK_20210708_0_L2A",
        "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A",
    ]

    job_order = [
        "--epsg",
        epsg,
        f"--aoi={aoi}",
    ]

    for item in stac_items:
        job_order.extend(["--stac_items", item])

    return job_order


parsed_args = argparse.Namespace(
    podman=True,
    parallel=True,
    outdir="/workspace/runs",
    workflow=f"/workspace/mastering-app-package/app-water-bodies-cloud-native.{version}.cwl#water_bodies",
    job_order=get_job_order(),
)

stream_out = StringIO()
stream_err = StringIO()

res = main(
    args=parsed_args,
    stdout=stream_out,
)

assert res == 0

stdout = json.loads(stream_out.getvalue())

cat = pystac.read_file(
    [
        listing["path"]
        for listing in stdout["stac_catalog"]["listing"]
        if "catalog.json" in listing["path"]
    ][0]
)

cat.describe()
