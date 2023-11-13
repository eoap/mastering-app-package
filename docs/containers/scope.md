When developers package and EO, they are in fact packaging their own software, written in a specific programming language, as a containerized application (or a set of containerized applications), to be described as an EO Application Package using the Common Workflow Language as described in the OGC proposed best practices.

To achieve this, developers follow the steps described below.

* **Prepare one or more container images containing the execution dependencies of the software.**
* Prepare the CWL CommandLineTool document(s) wrapping the command line tool available container(s).
* Prepare the CWL Workflow orchestrating CWL CommandLineTool document(s) wrapping the command line tool available container(s).
* Test the application package in one or more execution scenarios.

This page shows how to do the step:

* Prepare one or more container images containing the execution dependencies of the software.

### The container recipes

Each step has its own recipe to build the container image.

The `crop` step container image recipe is:

```dockerfile linenums="1" title="crop/Dockerfile"
--8<--
water-bodies/command-line-tools/crop/Dockerfile
--8<--
```

The `norm_diff` step container image recipe is:

```dockerfile linenums="1" title="norm_diff/Dockerfile"
--8<--
water-bodies/command-line-tools/norm_diff/Dockerfile
--8<--
```

The `otsu` step container image recipe is:

```dockerfile linenums="1" title="otsu/Dockerfile"
--8<--
water-bodies/command-line-tools/otsu/Dockerfile
--8<--
```

The `stac` step container image recipe is:

```dockerfile linenums="1" title="stac/Dockerfile"
--8<--
water-bodies/command-line-tools/stac/Dockerfile
--8<--
```

### Building the containers:

Build the container images with:

```bash linenums="1" title="terminal"
--8<--
scripts/build_containers.sh
--8<--
```

```
sh ${WORKSPACE}/scripts/build_containers.sh
```

### Expected outcome

The local container registry lists the built images:

```
(base) jovyan@coder-mrossi:~/runs$ podman images | grep localhost
localhost/stac                                                  latest      1e8ca97d1619  About a minute ago  288 MB
localhost/otsu                                                  latest      3b8c17119f85  About a minute ago  477 MB
localhost/norm-diff                                             latest      a69126fa050c  2 minutes ago       285 MB
localhost/crop                                                  latest      b66603b11c46  2 minutes ago       325 MB
```