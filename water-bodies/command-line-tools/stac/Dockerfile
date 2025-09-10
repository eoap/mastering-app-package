FROM docker.io/library/python:3.11-slim@sha256:91e9d01cf4bd56be7128c603506b6fe367ef7506f9f2ad8f3a908aeec8941bb9

# System deps needed by rasterio wheels
RUN apt-get update && \
    apt-get install -y --no-install-recommends libexpat1 && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "pystac==1.13.0" "rio-stac==0.11.2" "loguru==0.7.3" "click==8.2.1" && \
    python -c "import rio_stac"

ADD app.py /app/app.py

ENTRYPOINT []