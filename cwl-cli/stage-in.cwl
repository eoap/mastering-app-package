cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
# Training-example authors and creation date mirror codemeta.json.
s:name: Stage-in STAC assets
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
s:softwareVersion: 2.0.0

class: CommandLineTool
id: main
inputs:
  reference:
    type: string
    label: STAC item reference
    doc: URI of the STAC item whose assets are downloaded.
    inputBinding:
      prefix: --reference
outputs:
  staged:
    type: Directory
    outputBinding:
      glob: .
    label: Staged acquisition
    doc: Directory containing the staged STAC catalog, item, and downloaded assets.
baseCommand: stage-in
requirements:
  DockerRequirement:
    dockerPull: localhost/stage-in:latest
  InlineJavascriptRequirement: {}
  NetworkAccess:
    networkAccess: true
  EnvVarRequirement:
    envDef:
      PATH: /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
