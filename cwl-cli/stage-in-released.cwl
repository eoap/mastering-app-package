cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
# Training-example authors and creation date mirror codemeta.json.
s:name: Stage-in STAC assets (released container)
s:description: Download the assets of a STAC item for local processing.
s:dateCreated: '2022-09-01'
s:license:
  s:name: Creative Commons Attribution-ShareAlike 4.0 International
  s:url: https://creativecommons.org/licenses/by-sa/4.0/
  s:identifier: CC-BY-SA-4.0
s:softwareHelp:
  s:name: Mastering Earth Observation Application Packaging with CWL
  s:url: https://eoap.github.io/mastering-app-package
s:publisher:
  s:name: EO Application Packaging
  s:identifier: https://github.com/eoap
s:author:
- s:givenName: Jane
  s:familyName: Doe
  s:email: jane.doe@acme.earth
  s:affiliation:
    s:name: ACME
- s:givenName: John
  s:familyName: Doe
  s:email: john.doe@acme.earth
  s:affiliation:
    s:name: ACME
s:softwareRequirements:
- container runtime
- cwl runner
s:softwareVersion: 1.1.0

class: CommandLineTool
id: main
inputs:
  reference:
    type: string
outputs:
  staged:
    type: Directory
    outputBinding:
      glob: .
baseCommand: 
- python
- stage.py
arguments:
- $( inputs.reference )
requirements:
  DockerRequirement:
    dockerPull: ghcr.io/eoap/mastering-app-package/stage:1.0.0
  InlineJavascriptRequirement: {}
  NetworkAccess:
    networkAccess: true
  InitialWorkDirRequirement:
    listing:
      - entryname: stage.py
        entry: |-
          import pystac
          import stac_asset
          import asyncio
          import os
          import sys

          config = stac_asset.Config(warn=True)

          async def main(href: str):
              
              item = pystac.read_file(href)
              
              os.makedirs(item.id, exist_ok=True)
              cwd = os.getcwd()
              
              os.chdir(item.id)
              item = await stac_asset.download_item(item=item, directory=".", config=config)
              os.chdir(cwd)
              
              cat = pystac.Catalog(
                  id="catalog",
                  description=f"catalog with staged {item.id}",
                  title=f"catalog with staged {item.id}",
              )
              cat.add_item(item)
              
              cat.normalize_hrefs("./")
              cat.save(catalog_type=pystac.CatalogType.SELF_CONTAINED)

              return cat

          href = sys.argv[1]

          cat = asyncio.run(main(href))



