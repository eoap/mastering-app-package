FROM docker.io/rockylinux/rockylinux:10.1-minimal@sha256:cfa2812ec7151c2be393cfe46e50cf59426373d12f03f4ffbdd56becb8195a65 AS builder
RUN microdnf -y update && \
    microdnf -y install curl tar git python3 python3-pip python3-setuptools gcc gcc-c++ make sqlite-devel zlib-devel glibc-devel libstdc++-devel && \
    microdnf clean all
RUN test "$(uname -m)" = x86_64 && \
    curl -fsSL https://github.com/pypa/hatch/releases/download/hatch-v1.14.0/hatch-x86_64-unknown-linux-gnu.tar.gz -o /tmp/hatch.tar.gz && \
    echo "33af9b6f72cf11db6bc96070901cb9d32adbe316534bbf41d345cdd0d84b3459  /tmp/hatch.tar.gz" | sha256sum -c - && \
    tar -xzf /tmp/hatch.tar.gz -C /tmp && \
    install -m 0755 /tmp/hatch /usr/local/bin/hatch && \
    rm -rf /tmp/hatch*
WORKDIR /src
COPY . /src
RUN rm -rf dist && hatch build -t wheel

FROM docker.io/rockylinux/rockylinux:10.1-minimal@sha256:cfa2812ec7151c2be393cfe46e50cf59426373d12f03f4ffbdd56becb8195a65 AS runtime
RUN microdnf -y update && \
    microdnf -y install python3 python3-pip git jq libstdc++ sqlite-libs zlib libgomp expat && \
    microdnf clean all
ENV HOME=/home/neo
RUN /usr/sbin/groupadd -g 2000 neo && \
    /usr/sbin/useradd -u 2000 -g 2000 -m -d ${HOME} -s /sbin/nologin neo && \
    mkdir -p /app /work && chown -R 2000:2000 /app /work ${HOME}
USER neo
WORKDIR /app
ENV VIRTUAL_ENV=/app/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}:/usr/bin"
RUN python3 -c 'import sys; assert sys.version_info[:2] == (3, 12)' && python3 -m venv /app/venv
COPY --chown=2000:2000 requirements/runtime.txt /app/requirements.txt
RUN pip install --no-cache-dir --require-hashes -r /app/requirements.txt
COPY --from=builder --chown=2000:2000 /src/dist/*.whl /app/dist/
RUN pip install --no-cache-dir --no-deps /app/dist/*.whl && \
    pip check && python -m pip uninstall --yes pip && otsu --help && \
    rm -rf /app/requirements.txt /app/dist
ENTRYPOINT []
CMD ["otsu", "--help"]
