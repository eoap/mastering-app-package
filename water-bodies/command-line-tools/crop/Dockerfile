FROM docker.io/library/python:3.12-slim@sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1

# System deps needed by rasterio wheels
RUN apt-get update && \
    apt-get install -y --no-install-recommends libexpat1 && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "rasterio==1.5.2" "click==8.5.0" "pystac==1.15.2" "loguru==0.7.3" "pyproj==3.8.0" "shapely==2.1.2" && \
    python -c "import rasterio"

ADD app.py /app/app.py

ENTRYPOINT []