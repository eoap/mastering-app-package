FROM docker.io/python:3.9.18-slim-bullseye

RUN apt update && apt install -y yq

RUN pip install --no-cache-dir --upgrade pip stac-asset boto3==1.35.36 pystac loguru click pyyaml
