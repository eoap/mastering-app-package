FROM docker.io/library/python:3.12-slim@sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1 AS builder
WORKDIR /src
COPY pyproject.toml README.md LICENSE.md ./
COPY src/ ./src/
RUN python -m pip wheel --no-cache-dir --no-deps --wheel-dir /dist .

FROM docker.io/library/python:3.12-slim@sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1 AS runtime
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
RUN pip install --no-cache-dir /tmp/wheels/*.whl && \
    stage-out --help && \
    rm -rf /tmp/wheels
USER 2000:2000
WORKDIR /work
ENTRYPOINT []
