When developers package and EO, they are in fact packaging their own software, written in a specific programming language, as a containerized application (or a set of containerized applications), to be described as an EO Application Package using the Common Workflow Language as described in the OGC proposed best practices.

To achieve this, developers follow the steps described below.

* Prepare one or more container images containing the execution dependencies of the software.
* Prepare the CWL CommandLineTool document(s) wrapping the command line tool available in container(s).
* **Prepare the CWL Workflow orchestrating CWL CommandLineTool document(s) wrapping the command line tool available container(s).**
* Test the application package in one or more execution scenarios.

This section shows how to do the step:

* Prepare the CWL Workflow orchestrating CWL CommandLineTool document(s) wrapping the command line tool available container(s).

### Orchestrating CWL CommandLineTools

The CWL CommandLineTools wrapping the `crop`, `norm_diff`, `otsu` and `stac` command-line tools had a single CWL class in each of the CWL documents.

For orchestrating these CWL CommandLineTools, we will need a CWL document with a list of process objects. 

A `$graph` document does not have a process object at the root. Instead there is a $graph field which consists of a list of process objects.

Each process object must have an `id` field: 

```yaml
cwlVersion=1.0

$graph:
- class: Workflow
  id: main
  ...

- class: CommandLineTool
  id: crop
  ...

- class: CommandLineTool
  id: norm_diff
  ...

- class: CommandLineTool
  id: otsu
  ...

- class: CommandLineTool
  id: norm_diff
  ...
```

Workflow run fields cross-reference other processes in the document `$graph` using the `id` of the process object:

```yaml
cwlVersion=1.0

$graph:
- class: Workflow
  id: main
  steps:
    node_crop:
      run: "#crop"
      ...
    node_normalized_difference:
      run: "#norm_diff"
      ...
    node_otsu:
      run: "#otsu"
      ...
    node_stac:
      run: "#stac"
      ...
  ...

- class: CommandLineTool
  id: crop
  ...

- class: CommandLineTool
  id: norm_diff
  ...

- class: CommandLineTool
  id: otsu
  ...

- class: CommandLineTool
  id: norm_diff
  ...
```

We propose three Workflows:

* `app-water-body-cloud-native.cwl` reading a STAC Item as input and orchestrating the `crop`, `norm_diff`, `otsu` and `stac` steps and thus taking a single STAC item as input
* `app-water-body.cwl` reading a staged EO acquisition as a STAC Catalog 
* `app-water-bodies-cloud-native.cwl` that scatters the Workflow `app-water-body-cloud-native.cwl` on a list of STAC items.