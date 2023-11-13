FROM docker.io/python:3.10-slim

RUN pip install --no-cache-dir pystac rio_stac loguru click && \
    python -c "import rio_stac"

ADD app.py /app/app.py

ENTRYPOINT []