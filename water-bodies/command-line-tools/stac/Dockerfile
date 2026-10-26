FROM docker.io/library/python:3.12.15-slim-bookworm@sha256:6a0e06f5ba0b373d051aabd3fffb9b873f27f9a2a3a14bcbe37dee6f0e3bbc70 AS builder

# Refresh the OS trust store before downloading Python packages.
RUN apt-get update && apt-get install -y --only-upgrade ca-certificates && \
    update-ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY pyproject.toml README.md LICENSE.md ./
COPY src/ ./src/
RUN python -m pip install --no-cache-dir --upgrade "pip @ https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/pip-26.2.2-py3-none-any.whl#sha256=fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70" && \
    python -m pip install --no-cache-dir --upgrade "certifi>=2026.10.19" && \
    python -m pip wheel --no-cache-dir --no-deps --wheel-dir /dist .

FROM docker.io/library/python:3.12.15-slim-bookworm@sha256:6a0e06f5ba0b373d051aabd3fffb9b873f27f9a2a3a14bcbe37dee6f0e3bbc70 AS runtime

# Refresh the OS trust store before downloading Python packages.
RUN apt-get update && apt-get install -y --only-upgrade ca-certificates && \
    update-ca-certificates && rm -rf /var/lib/apt/lists/*
RUN apt-get update && \
    apt-get install -y --no-install-recommends libexpat1 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --gid 2000 neo && \
    useradd --uid 2000 --gid 2000 --create-home neo && \
    python -m venv /app/venv && \
    mkdir -p /work && chown 2000:2000 /work
ENV VIRTUAL_ENV=/app/venv
ENV PATH="/app/venv/bin:$PATH"
COPY --from=builder /dist/ /tmp/wheels/
RUN pip install --no-cache-dir --upgrade "pip @ https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/pip-26.2.2-py3-none-any.whl#sha256=fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70" && \
    pip install --no-cache-dir --upgrade "certifi>=2026.10.19" && \
    pip install --no-cache-dir /tmp/wheels/*.whl && \
    stac --help && \
    rm -rf /tmp/wheels
USER 2000:2000
WORKDIR /work
ENTRYPOINT []
