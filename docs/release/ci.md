
## Application Package Software Configuration Management

The SCM has the task of tracking and controlling changes in the software as a part of the larger cross-disciplinary field of configuration management. 

SCM practices include revision control and the establishment of baselines.

The Application Package code is hosted on a repository publicly accessible (Github, Bitbucket, a GitLab instance, an institutional software forge, etc.) using one of the version control systems supported by (Subversion, Mercurial and Git)

The Application Package code include, at the top level of the source code tree, the following files:

* README containing a description of the software (name, purpose, pointers to website, documentation, development platform, contact, and support information, …)
* AUTHORS, a list of all the persons to be credited for the software.
* LICENSE, the project license terms. For Open Source Licenses, the standard SPDX license names are used. For large software projects and developers, the REUSE (https://reuse.software/) process and tools can be an option to look at.
* codemeta.json, a linked data metadata file that helps index the source code in the Software Heritage archive and provides an easy way to link to other related research outputs.

The codemeta.json includes metadata information to support the Continuous Integration phase and it is shown below:

```json linenums="1" title="codemeta.json"
--8<--
codemeta.json
--8<--
```

## Application Package Continuous Integration

A typical Continuous Integration scenario for an Application Package includes the release of the CWL document(s) and publishing the container images to a container registry.

This is depicted below: 

``` mermaid
graph TB
SCM[(software repository)]
SCM -- CWL Workflow --> A
SCM -- codemeta.json --> B
A(validate CWL Workflow) --> B(extract version)
B --> C
subgraph Build containers
SCM -- Dockerfiles --> C
C(build container) --> D(push container) 
end
D -- push --> CR[(Container Registry)] 
D -- container sha256 --> F("update Dockerpull/metadata in CWL Workflows") 
F -- push --> AR[(Artifact Registry)]
SCM -- codemeta.json --> F
```

Below an example of a GitHub CI configuration implementing the scenario:

```yaml linenums="1" title=".github/workflows/build.yaml"
--8<--
.github/workflows/build.yaml
--8<--
```