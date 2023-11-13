FROM docker.io/python:3.10-slim

RUN pip install --no-cache-dir rasterio scikit-image click loguru && \
    python -c "import rasterio"

ADD app.py /app/app.py

ENTRYPOINT []
