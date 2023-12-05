version="1.0.0"

cwltool \
    --podman \
    --outdir /workspace/runs \
    /workspace/runs/app-water-body.${version}.cwl \
    --item $( cat staged.json | jq -r .staged.path ) \
    --aoi="-118.985,38.432,-118.183,38.938" \
    --epsg "EPSG:4326" \
    --bands green \
    --bands nir08 > results.json