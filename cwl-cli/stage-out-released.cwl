cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
# Training-example authors and creation date mirror codemeta.json.
s:name: Stage-out STAC results (released container)
s:description: Upload the results catalog and its assets to S3-compatible
  storage.
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
id: stage-out

doc: "Stage-out the results to S3"
inputs:
  s3_bucket:
    type: string
  sub_path:
    type: string
  aws_access_key_id:
    type: string
  aws_secret_access_key:
    type: string
  region_name:
    type: string
  endpoint_url:
    type: string
  stac_catalog:
    type: Directory
outputs:
  s3_catalog_output:
    outputBinding:
      outputEval: ${  return "s3://" + inputs.s3_bucket + "/" + inputs.sub_path + "/catalog.json"; }
    type: string
baseCommand:
  - python
  - stage.py
arguments:
  - $( inputs.stac_catalog.path )
  - $( inputs.s3_bucket )
  - $( inputs.sub_path )
requirements:
  DockerRequirement:
    dockerPull: ghcr.io/eoap/mastering-app-package/stage:1.0.0
  InlineJavascriptRequirement: {}
  NetworkAccess:
    networkAccess: true
  EnvVarRequirement:
    envDef:
      aws_access_key_id: $( inputs.aws_access_key_id )
      aws_secret_access_key: $( inputs.aws_secret_access_key )
      aws_region_name: $( inputs.region_name )
      aws_endpoint_url: $( inputs.endpoint_url )
  ResourceRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: stage.py
        entry: |-
          import os
          import sys
          import pystac
          import botocore
          import boto3
          import shutil
          from pystac.stac_io import DefaultStacIO, StacIO
          from urllib.parse import urlparse

          cat_url = sys.argv[1]
          bucket = sys.argv[2]
          subfolder = sys.argv[3]

          aws_access_key_id = os.environ["aws_access_key_id"]
          aws_secret_access_key = os.environ["aws_secret_access_key"]
          region_name = os.environ["aws_region_name"]
          endpoint_url = os.environ["aws_endpoint_url"]

          shutil.copytree(cat_url, "/tmp/catalog")
          cat = pystac.read_file(os.path.join("/tmp/catalog", "catalog.json"))

          class CustomStacIO(DefaultStacIO):
              """Custom STAC IO class that uses boto3 to read from S3."""

              def __init__(self):
                  self.session = botocore.session.Session()
                  self.s3_client = self.session.create_client(
                      service_name="s3",
                      use_ssl=True,
                      aws_access_key_id=aws_access_key_id,
                      aws_secret_access_key=aws_secret_access_key,
                      endpoint_url=endpoint_url,
                      region_name=region_name,
                  )

              def write_text(self, dest, txt, *args, **kwargs):
                  parsed = urlparse(dest)
                  if parsed.scheme == "s3":
                      self.s3_client.put_object(
                          Body=txt.encode("UTF-8"),
                          Bucket=parsed.netloc,
                          Key=parsed.path[1:],
                          ContentType="application/geo+json",
                      )
                  else:
                      super().write_text(dest, txt, *args, **kwargs)


          client = boto3.client(
              "s3",
              aws_access_key_id=aws_access_key_id,
              aws_secret_access_key=aws_secret_access_key,
              endpoint_url=endpoint_url,
              region_name=region_name,
          )

          StacIO.set_default(CustomStacIO)

          for item in cat.get_items():
              for key, asset in item.get_assets().items():
                  s3_path = os.path.normpath(
                      os.path.join(os.path.join(subfolder, item.id, asset.href))
                  )
                  print(f"upload {asset.href} to s3://{bucket}/{s3_path}",file=sys.stderr)
                  client.upload_file(
                      asset.get_absolute_href(),
                      bucket,
                      s3_path,
                  )
                  asset.href = f"s3://{bucket}/{s3_path}"
                  item.add_asset(key, asset)

          cat.normalize_hrefs(f"s3://{bucket}/{subfolder}")

          for item in cat.get_items():
              # upload item to S3
              print(f"upload {item.id} to s3://{bucket}/{subfolder}", file=sys.stderr)
              pystac.write_file(item, item.get_self_href())

          # upload catalog to S3
          print(f"upload catalog.json to s3://{bucket}/{subfolder}", file=sys.stderr)
          pystac.write_file(cat, cat.get_self_href())

          print(f"s3://{bucket}/{subfolder}/catalog.json", file=sys.stdout)