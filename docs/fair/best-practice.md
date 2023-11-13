## Application Package Software Configuration Management

The SCM has the task of tracking and controlling changes in the software as a part of the larger cross-disciplinary field of configuration management. 

SCM practices include revision control and the establishment of baselines.

The Application Package code is hosted on a repository publicly accessible (Github, Bitbucket, a GitLab instance, an institutional software forge, etc.) using one of the version control systems supported by (Subversion, Mercurial and Git)

The Application Package code include, at the top level of the source code tree, the following files:

* README containing a description of the software (name, purpose, pointers to website, documentation, development platform, contact, and support information, …)
* AUTHORS, a list of all the persons to be credited for the software.
* LICENSE, the project license terms. For Open Source Licenses, the standard SPDX license names are used. For large software projects and developers, the REUSE (https://reuse.software/) process and tools can be an option to look at.
* codemeta.json, a linked data metadata file that helps index the source code in the Software Heritage archive and provides an easy way to link to other related research outputs.

The code meta project motivation (https://codemeta.github.io/) is reported below:

**Research relies heavily on scientific software, and a large and growing fraction of researchers are engaged in developing software as part of their own research (Hannay et al 2009). Despite this, infrastructure to support the preservation, discovery, reuse, and attribution of software lags substantially behind that of other research products such as journal articles and research data. This lag is driven not so much by a lack of technology as it is by a lack of unity: existing mechanisms to archive, document, index, share, discover, and cite software contributions are heterogeneous among both disciplines and archives and rarely meet best practices (Howison 2015). Fortunately, a rapidly growing movement to improve preservation, discovery, reuse, and attribution of academic software is now underway: a recent NIH report; conferences and working groups of FORCE11, WSSSPE & Software Sustainability Institute; and the rising adoption of repositories like GitHub, Zenodo, figshare & DataONE by academic software developers. Now is the time to improve how these resources can communicate to each other.**

CodeMeta developed the translations from the different vocabularies. The CodeMeta vocabulary is an extension of the SoftwareApplication and SoftwareSourceCode classes found in the vocabulary of the Schema.org initiative [schema]. Metadata information conformant to the CodeMeta vocabulary can be represented in JSON format, named codemeta.json, like the example below with the information for Water Bodies Detection application.

```json linenums="1" title="codemeta.json"
--8<--
codemeta.json
--8<--
```

## Application Package Software identification and traceability

In a Reproducible FAIR Workflow scenario, ensuring that the code behind the application is uniquely identified and traceable is necessary. Even if software configuration management systems have become a common tool for tracking and controlling changes in the software, the FAIR publication of applications also needs methods for software citation, software retrieval, and long-term preservation. This is achieved with the issuing of a persistent identifier.

The persistent identifier provides a long-lasting reference to source code and is usually understood as an actionable and accessible reference over the Internet that retrieves the necessary files. As such, the persistent component is dependent on the service commitment to resolve the identifier and the dedicated storage lifespan.

Several initiatives provide this persistent dual functionality of identification and archivation. This Best Practice identifies one solution with Software Heritage. Software Heritage is a non-profit multi-stakeholder initiative unveiled in 2016 by the French Institute for Research in Computer Science and Automation (Inria) and supported by UNESCO. The mission of Software Heritage is to collect, preserve, and share all software that is publicly available in source code form, with the goal of building a common shared infrastructure at the service of industry, research, culture, and society.

The __Software Heritage__ provides SoftWare Heritage persistent IDentifiers (SWHIDs) and ensures preservation of the software source code by crawling code hosting platforms, like GitHub, GitLab.com, or Bitbucket, and package archives, like npm or PyPI, ingested into a special data structure, a Merkle DAG, that is the core of the archive.

To obtain a SWHID, the code must be hosted on a publicly accessible repository (Github, Bitbucket, a GitLab instance, an institutional software forge, etc.) using one of the version control systems supported by Software Heritage (Subversion, Mercurial, and Git).

## Application Package Containers identification

A Reproducible FAIR Workflow scenario also requires that the application container(s) is(are) uniquely identified and traceable. 

Using the sha256 signature of the container, containers have an identifier.

Example:

```yaml
- class: CommandLineTool
  id: crop

  hints:
    DockerRequirement:
      dockerPull: docker.io/terradue/crop@sha256:ec2d8e71ab5834cb9db01c5001bde9c3d6038d0418ad085726b051b4359750e1
```

## Application Package metadata

The OGC Best Practices for EO Application Packages (OGC 20-089) recommends that to enrich the application package with new concepts, these should originate from schema.org and be linked with their RDF encoding. While OGC 20-089 only enforces the version element as a mandatory, it already suggest several additional elements that are key for the Reproducible FAIR Workflows scenario such as the following.

* **author**: The main author of the Application Package - https://schema.org/author.
* **citation**: A citation or reference to a publication, web page, scholarly article, etc. https://schema.org/citation.
* **codeRepository**: Link to the repository where the Application code is located (e.g., SVN, github). https://schema.org/codeRepository.
* **contributor**: A secondary contributor to the Application Package https://schema.org/contributor.
* **dateCreated**: The date on which the Application Package was created. https://schema.org/dateCreated.
* **keywords**: Keywords used to describe this application. Multiple entries in a keywords list are delimited by commas. https://schema.org/keywords.
* **license**: An URL to the license document that applies to this application. https://schema.org/license.
* **releaseNotes**: Description of what changed in this version. https://schema.org/releaseNotes.

All these elements can be obtained from the CodeMeta vocabulary (i.e., codemeta.json) and can be directly added when defining the Application Package (e.g. during the Continuous Integration).

Example:

```
cwlVersion: v1.0
$graph:
...
$namespaces:
  s: https://schema.org/
s:author:
- class: s:Person
  s:affiliation: Planet Earth
  s:email: john.doe@somedomain.org
  s:name: Doe, John
s:contributor:
- class: s:Person
  s:affiliation: Planet Earth
  s:email: jane.doe@somedomain.org
  s:name: Doe, Jane
s:softwareVersion: 1.1.6
schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf
```

## Application Package identification and traceability

In a Reproducible FAIR Workflow scenario, it is necessary to ensure that the Application Package is uniquely identified and traceable. 

The assignment of a DOI to the application package extends the metadata section of the Application Package CWL with:

```
sameAs: URL of a reference Web page that unambiguously indicates the item’s identity. https://schema.org/sameAs.
```

Example

```yaml hl_lines="16"
cwlVersion: v1.0
$graph:
...
$namespaces:
  s: https://schema.org/
s:author:
- class: s:Person
  s:affiliation: Planet Earth
  s:email: john.doe@somedomain.org
  s:name: Doe, John
s:contributor:
- class: s:Person
  s:affiliation: Planet Earth
  s:email: jane.doe@somedomain.org
  s:name: Doe, Jane
s:sameas: https://doi.org/10.5072/zenodo.1107209
s:softwareVersion: 1.1.6
schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf
```