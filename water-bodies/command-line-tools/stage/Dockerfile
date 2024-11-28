FROM python:3.11

RUN apt update && apt install -y yq

RUN pip install --no-cache-dir --upgrade pip stac-asset boto3==1.35.36 pystac loguru click pyyaml
