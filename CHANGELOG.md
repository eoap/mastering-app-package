# Changelog

## Unreleased

### Changed

- Pinned pip dependencies in the crop, normalized-difference, Otsu, and STAC
  application-step notebooks for ESAGEP-2379.
- Set notebook dependencies to `rasterio==1.5.2`, `click==8.5.0`,
  `pystac==1.15.2`, `loguru==0.7.3`, `pyproj==3.8.0`, `shapely==2.1.2`,
  `scikit-image==0.26.0`, `rio_stac==0.12.0`, `stactools[validate]==0.5.3`,
  and `requests==2.34.2`, where used.

### Requirements

- Notebooks using Rasterio 1.5.2 or PyProj 3.8.0 now require Python 3.12 or later.
