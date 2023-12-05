cwltool \
    --podman \
    --outdir /workspace/runs \
    ${WORKSPACE}/cwl-workflow/cwl-workflow/app-water-body.cwl \
    --item $( cat staged.json | jq -r .staged.path ) \
    --aoi="-118.985,38.432,-118.183,38.938" \
    --epsg "EPSG:4326" \
    --bands green \
    --bands nir08