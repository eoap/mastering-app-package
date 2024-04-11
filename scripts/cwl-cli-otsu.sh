cwltool \
    --podman \
    --outdir ${WORKSPACE}/runs \
    ${WORKSPACE}/cwl-cli/otsu.cwl \
    --raster \
    ${WORKSPACE}/runs/norm_diff.tif