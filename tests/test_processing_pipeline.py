"""Exercise the installed processing commands with local, synthetic STAC data."""
import datetime
import json
import subprocess

import numpy as np
import pystac
import rasterio
from rasterio.transform import from_origin


def test_processing_pipeline(tmp_path):
    polygon = {'type': 'Polygon', 'coordinates': [[[1, 1], [9, 1], [1, 9], [1, 1]]]}
    item = pystac.Item('synthetic', polygon, [1, 1, 9, 9],
                       datetime.datetime(2024, 1, 1, tzinfo=datetime.timezone.utc), {})
    for band, pixels in [('green', np.full((10, 10), 100, dtype='uint16')),
                         ('nir', np.tile(np.arange(10, dtype='uint16') * 30 + 10, (10, 1)))]:
        path = tmp_path / f'{band}.tif'
        with rasterio.open(path, 'w', driver='GTiff', width=10, height=10,
                           count=1, dtype='uint16', crs='EPSG:4326',
                           transform=from_origin(0, 10, 1, 1), nodata=0) as dst:
            dst.write(pixels, 1)
        item.add_asset(band, pystac.Asset(str(path), roles=["data"], extra_fields={
            'eo:bands': [{'name': band, 'common_name': band}]}))
    item_path = tmp_path / 'source.json'
    item.save_object(dest_href=str(item_path))
    def run(*args):
        subprocess.run(args, cwd=tmp_path, check=True, capture_output=True, text=True)
    for band in ['green', 'nir']:
        run('crop', '--input-item', str(item_path), '--aoi', json.dumps(polygon),
            '--epsg', '4326', '--band', band)
    with rasterio.open(tmp_path / 'crop_green.tif') as src:
        assert src.shape == (8, 8)
        assert np.any(src.read(1) == 0), 'Polygon must mask pixels inside its bounding box'
        assert np.any(src.read(1) == 100)
    run('norm_diff', '--rasters', 'crop_green.tif', '--rasters', 'crop_nir.tif')
    run('otsu', '--raster', 'norm_diff.tif')
    run('stac', '--item', str(item_path), '--rasters', 'otsu.tif')
    catalog = pystac.read_file(str(tmp_path / 'catalog.json'))
    output = next(catalog.get_items(recursive=True))
    assert output.id == 'synthetic'
    assert (tmp_path / 'synthetic' / 'otsu.tif').is_file()
    assert output.assets['data'].href.lstrip('./') == 'otsu.tif'
    with rasterio.open(output.assets['data'].get_absolute_href()) as src:
        assert src.crs.to_epsg() == 4326
        assert set(np.unique(src.read(1))) <= {0, 1, 255}
