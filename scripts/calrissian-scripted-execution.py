import logging
import os
import sys
from pathlib import Path
from calrissian.report import initialize_reporter, write_report, CPUParser, MemoryParser
from calrissian.executor import ThreadPoolJobExecutor
from calrissian.main import (
    install_tees,
    add_arguments,
    install_signal_handler,
    flush_tees,
    activate_logging,
)
from calrissian.report import initialize_reporter, write_report, CPUParser, MemoryParser
from calrissian.context import CalrissianLoadingContext, CalrissianRuntimeContext
from cwltool.main import main as cwlmain
from cwltool.argparser import arg_parser
from calrissian.version import version
from calrissian.k8s import delete_pods
import pystac
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


# Iterate through the stac_items and add the argument for each URL
for item in stac_items:
    job_order.extend(["--stac_items", item])

parsed_args = argparse.Namespace(
    outdir="/calrissian/output/",
    tmp_outdir_prefix="/calrissian/tmp/",
    max_ram="8G",
    max_cores="16",
    workflow="/workspace/mastering-app-package-/app-water-bodies-cloud-native.1.4.1.cwl#water_bodies",
    job_order=get_job_order(),
)
out = "/tmp/log.out"
err = "/tmp/log.err"

max_ram_megabytes = MemoryParser.parse_to_megabytes(max_ram)
max_cores = CPUParser.parse(max_cores)
executor = ThreadPoolJobExecutor(max_ram_megabytes, max_cores)
install_tees(out, err)

initialize_reporter(max_ram_megabytes, max_cores)

runtime_context = CalrissianRuntimeContext(vars(parsed_args))
runtime_context.select_resources = executor.select_resources

install_signal_handler()
try:

    result = cwlmain(
        args=parsed_args,
        executor=executor,
        loadingContext=CalrissianLoadingContext(),
        runtimeContext=runtime_context,
    )
finally:
    delete_pods()
    if hasattr(parsed_args, "usage_report"):
        write_report(parsed_args.usage_report)
    flush_tees()

import json

with open(out) as f:
    results = json.load(f)

cat = pystac.read_file(
    [
        listing["path"]
        for listing in results["stac_catalog"]["listing"]
        if "catalog.json" in listing["path"]
    ][0]
)

cat.describe()
