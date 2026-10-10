# Water bodies detection based on NDWI and otsu threshold v1.4.1

Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items

> This software is licensed under the terms of the [Creative Commons Attribution-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/) license - SPDX short identifier: [CC-BY-SA-4.0](https://spdx.org/licenses/CC-BY-SA-4.0)
>
> 2022-09-01 - 2026-10-10T18:20:08.682 Copyright [EO Application Packaging](mailto:None) - > [https://github.com/eoap](https://github.com/eoap)

## Project Team

### Authors

| Name | Email | Organization | Role | Identifier |
|------|-------|--------------|------|------------|
| Doe, Jane | [jane.doe@acme.earth](mailto:jane.doe@acme.earth) | [ACME](None) | [N/A](None) | [None](None) |
| Doe, John | [john.doe@acme.earth](mailto:john.doe@acme.earth) | [ACME](None) | [N/A](None) | [None](None) |


### Contributors

The are no contributors for this project.


## Mastering Earth Observation Application Packaging with CWL

Mastering Earth Observation Application Packaging with CWL can be found on [https://eoap.github.io/mastering-app-package](https://eoap.github.io/mastering-app-package).


## Runtime environment

### Supported Operating Systems

The are no Supported Operating Systems specified for this project.


### Requirements

- [container runtime](container runtime)
- [cwl runner](cwl runner)



---


## detect_water_body

### CWL Class

[Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow)

### Requirements

* [ScatterFeatureRequirement](https://www.commonwl.org/v1.2/Workflow.html#ScatterFeatureRequirement)

### Inputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `aoi` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | None | area of interest as a bounding box |
| `epsg` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | None | EPSG code |
| `bands` | `array` of [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | None | bands used for the NDWI |
| `item` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | None | STAC item |


### Steps

| Id | Runs | Label | Doc |
|----|------|-------|-----|
| [node_crop](#crop) | `#crop` | None | None |
| [node_normalized_difference](#norm_diff) | `#norm_diff` | None | None |
| [node_otsu](#otsu) | `#otsu` | None | None |


### Outputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `detected_water_body` | [File](https://www.commonwl.org/v1.2/Workflow.html#File) | None | None |


### OGC API - Processes

When `detect_water_body` [Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow) is exposed through [OGC API - Processes - Part 1: Core](https://docs.ogc.org/is/18-062r2/18-062r2.html), `inputs` and `outputs` fields below represent the interface of the [getProcessDescription](https://developer.ogc.org/api/processes/index.html#tag/ProcessDescription/operation/getProcessDescription) API.



#### Inputs

![detect_water_body OGC API Processes JSON Inputs schema](./detect_water_body/ogc_processes_inputs.svg "detect_water_body  diagram")

#### Outputs

![detect_water_body OGC API Processes JSON Outputs schema](./detect_water_body/ogc_processes_outputs.svg "detect_water_body  diagram")


### UML Diagrams


#### Activity diagram

Learn more about the [Activity diagram](https://en.wikipedia.org/wiki/Activity_diagram) below.

![detect_water_body flow diagram](./detect_water_body/activity.svg "detect_water_body Activity diagram")

#### Component diagram

Learn more about the [Component diagram](https://en.wikipedia.org/wiki/Component_diagram) below.

![detect_water_body flow diagram](./detect_water_body/component.svg "detect_water_body Component diagram")

#### Class diagram

Learn more about the [Class diagram](https://en.wikipedia.org/wiki/Class_diagram) below.

![detect_water_body flow diagram](./detect_water_body/class.svg "detect_water_body Class diagram")

#### Sequence diagram

Learn more about the [Sequence diagram](https://en.wikipedia.org/wiki/Sequence_diagram) below.

![detect_water_body flow diagram](./detect_water_body/sequence.svg "detect_water_body Sequence diagram")

#### State diagram

Learn more about the [State diagram](https://en.wikipedia.org/wiki/State_diagram) below.

![detect_water_body flow diagram](./detect_water_body/state.svg "detect_water_body State diagram")


### Run in step

`node_crop`



## crop

### CWL Class

[CommandLineTool](https://www.commonwl.org/v1.2/CommandLineTool.html#CommandLineTool)

### Inputs

| Id | Option | Type |
|----|------|-------|
| `item` | `--input-item` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) |
| `aoi` | `--aoi` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) |
| `epsg` | `--epsg` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) |
| `band` | `--band` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) |

### Execution usage example:

```
python -m app \
--input-item <ITEM> \
--aoi <AOI> \
--epsg <EPSG> \
--band <BAND>
```

### Run in step

`node_normalized_difference`



## norm_diff

### CWL Class

[CommandLineTool](https://www.commonwl.org/v1.2/CommandLineTool.html#CommandLineTool)

### Inputs

| Id | Option | Type |
|----|------|-------|
| `rasters` | `--rasters` | `array` of [File](https://www.commonwl.org/v1.2/Workflow.html#File) |

### Execution usage example:

```
python -m app \
--rasters <RASTERS>
```

### Run in step

`node_otsu`



## otsu

### CWL Class

[CommandLineTool](https://www.commonwl.org/v1.2/CommandLineTool.html#CommandLineTool)

### Inputs

| Id | Option | Type |
|----|------|-------|
| `raster` | `--raster` | [File](https://www.commonwl.org/v1.2/Workflow.html#File) |

### Execution usage example:

```
python -m app \
--raster <RASTER>
```
