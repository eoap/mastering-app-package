cwltool \
    --podman \
    --outdir /workspace/runs \
    ${WORKSPACE}/cwl-cli/otsu.cwl \
    --raster \
    /workspace/runs/norm_diff.tif