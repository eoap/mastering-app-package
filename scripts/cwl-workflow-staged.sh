cat <<EOF > staged-params.yaml
item:
  class: Directory
  path: "$(jq -r .staged.path staged.json)"
aoi:
  type: Polygon
  coordinates:
    -   -   - -118.985
            - 38.432
        -   - -118.183
            - 38.432
        -   - -118.183
            - 38.938
        -   - -118.985
            - 38.938
        -   - -118.985
            - 38.432
  bbox:
    - -118.985
    - 38.432
    - -118.183
    - 38.938
epsg: '4326'
bands:
  - green
  - nir08
EOF

cwltool \
    --podman \
    --outdir "${WORKSPACE}/runs" \
    "${WORKSPACE}/cwl-workflow/app-water-body.cwl#water-bodies" \
    staged-params.yaml
