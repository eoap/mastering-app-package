
### Goal 

Wrap the `crop` step as a Common Workflow Language CommandLineTool and execute it with a CWL runner.

### Lab

This step has a dedicated lab available at /workspace/mastering-app-package/practice-labs/3-CWL-CommandLineTools/crop.ipynb

### How to wrap a step as a CWL CommandLineTool 

The CWL document below shows the `crop` step wrapped as a CWL CommandLineTool:

```yaml linenums="1" title="cwl-cli/crop.cwl"
--8<--
cwl-cli/crop.cwl
--8<--
```

Let's break down the key components of this CWL document:

* `cwlVersion: v1.2`: Specifies the version of the CWL specification that this document follows.
* `class: CommandLineTool`: Indicates that this CWL document defines a command-line tool.
* `id: crop`: Provides a unique identifier for this tool, which can be used to reference it in workflows.
* `requirements`: Specifies the requirements and dependencies of the tool. In this case, it defines the following:
    * `InlineJavascriptRequirement`: This requirement allows the use of inline JavaScript expressions in the tool.
    * `EnvVarRequirement`: It sets environment variables. In this case, it sets the `PYTHONPATH` environment variable to "/app."
    * `ResourceRequirement`: Specifies resource requirements for running the tool, including the maximum number of CPU cores and maximum RAM.
    * `DockerRequirement`: This requirement specifies the Docker container to be used. It indicates that the tool should be executed in a Docker container with the image `localhost/crop:latest`.
* `baseCommand`: Defines the base command to be executed in the container. In this case, it's running a Python module called "app" with the command `python -m app`.
* `arguments`: This section is empty, meaning there are no additional command-line arguments specified here. The tool is expected to receive its arguments via the input parameters.
* `inputs`: Describes the input parameters for the tool, including their types and how they are bound to command-line arguments. The tool expects the following inputs:
    * `item`: A URI record containing a `value` field with the STAC item URL; `valueFrom: $(self.value)` passes that URL, bound to the `--input-item` argument.
    * `aoi`: A GeoJSON Polygon record with `coordinates` and `bbox`; `valueFrom: $(self.bbox.join(","))` converts its bounding box to the application argument, bound to the `--aoi` argument.
    * `epsg`: A string representing the EPSG code for the coordinate system, bound to the `--epsg` argument.
    * `band`: A string representing the name of the band to be extracted, bound to the `--band` argument.
* `outputs`: Specifies the tool's output. It defines an output parameter named `cropped`, which is of type `File`. The outputBinding section specifies that the tool is expected to produce one or more TIFF files (glob: '*.tif') as output.

### Steps

Clean-up the `/workspace/mastering-app-package/runs` folder: 

```
rm -fr /workspace/mastering-app-package/runs/*
```

Run the CWL document using the `cwltool` CWL runner to execute the `crop` step with the `green` band with:


```console hl_lines="9-12 49-53" title="terminal"
--8<--
scripts/cwl-cli-crop-green.sh
--8<--
```

```
sh -x ${WORKSPACE}/scripts/cwl-cli-crop-green.sh
```

Run the CWL document using the `cwltool` CWL runner to execute the `crop` step with the `nir` band with:

```console hl_lines="9-12 49-53" title="terminal"
--8<--
scripts/cwl-cli-crop-nir.sh
--8<--
```

```
sh -x ${WORKSPACE}/scripts/cwl-cli-crop-nir.sh
```

### Expected outcome

The folder `/workspace/mastering-app-package/runs` contains: 

```
(base) jovyan@coder-mrossi:~/runs$ tree .
.
├── crop_green.tif
└── crop_nir.tif

0 directories, 2 files
```

### Extra 

The CWL runner `cwltool` allows you to do a YAML file with the parameters:

```yaml title="crop-params.yaml"
--8<--
cwl-cli/crop-params.yaml
--8<--
```

and run it with:

```console hl_lines="5" title="terminal"
cwltool \
    --podman \
    --outdir /workspace/mastering-app-package/runs \
    ${WORKSPACE}/cwl-cli/crop.cwl \
    ${WORKSPACE}/cwl-cli/crop-params.yaml
```

`SchemaDefRequirement` imports the EOAP GeoJSON and URI record schemas. Use the YAML job above to supply structured inputs. The standalone crop tool retains string `epsg` and `band` inputs; the workflows constrain these through enums. The application still crops a rectangle using `bbox`.
