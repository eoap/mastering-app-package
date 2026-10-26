FROM docker.io/library/python:3.11.17-slim-bookworm@sha256:f06d01d4ba3f8ad5af45a3ec87df19c1d317d8e8961edc0fabda61811af6f7cf

# Refresh the OS trust store before downloading Python packages.
RUN apt-get update && apt-get install -y --only-upgrade ca-certificates && \
    sed -i '/^[#!]*mozilla\/emSign_ECC_Root_CA_-_G3\.crt$/s/^[#!]*/!/' /etc/ca-certificates.conf && \
    update-ca-certificates && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade "pip @ https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/pip-26.2.2-py3-none-any.whl#sha256=fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70" && \
    pip install --no-cache-dir --upgrade "certifi>=2026.10.19" && \
    pip install --no-cache-dir --upgrade pip "stac-asset==0.4.7" "boto3==1.40.18" "loguru==0.7.3"
