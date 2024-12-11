# Mastering Earth Observation Application Packaging with CWL

This guide supports "**Mastering Earth Observation Application Packaging with CWL**" training events, where participants dive into the world of Earth Observation (EO) Application Packages and explore how to effectively package, share, and execute EO workflows using the Common Workflow Language (CWL) standard.

This tutorial is designed for developers, scientists, and EO enthusiasts who want to enhance their skills in creating and sharing EO Application Packages. Whether participants are new to CWL or already have some experience, this event provides valuable insights and practical knowledge to boost their expertise.

During a training event, the trainees will learn:

* The fundamentals of EO Application Packages and their role in the EO domain.
* How to leverage CWL to describe, package, and share workflows.
* Techniques for incorporating data, code, configuration files, and documentation into an EO Application Package.
* Best practices for creating portable and reproducible EO workflows.
* Hands-on exercises to reinforce your understanding and gain practical experience.

When developers package an EO Application, they are in fact packaging their own software, written in a specific programming language, as a containerized application (or a set of containerized applications), to be described as an EO Application Package using the CWL as described in the OGC proposed best practices.

This tutorial will guide participants through step-by-step examples, mastering the process of creating EO Application Packages using CWL with a simple EO application for water bodies detection using Normalised Difference Water Index (NDWI).

## Implementation

To facilitate this process, participants are guided through the tutorial using interactive Jupyter Notebooks across various execution scenarios:

1. **Application**: Understand the Application and execute its individual steps (i.e. `crop`, `norm_diff`, `otsu`, `stac`) along with their associated Python modules.
2. **Containers**: Build container images for each Application step with the required execution software dependencies, then run each step in its respective container.
3. **CWL-CommandLineTool**: Prepare the CWL CommandLineTool document(s) wrapping the command line tool available in their associated container(s), and execute them with `cwltool`.
4. **CWL-Workflow**: Prepare the CWL Workflow orchestrating CWL CommandLineTool document(s) wrapping the command line tool available container(s). Three scenarios are demonstrated:

    1. Workflow that reads a single STAC Item as input and orchestrates the four steps `crop`, `norm_diff`, `otsu` and `stac`.
    2. Workflow that reads a STAC Catalog of a staged EO acquisition as input, then orchestrates the four steps. A first step to stage-in the EO data is also demonstrated.
    3. Workflow that reads multiple STAC Items as input and scatters them executing the Workflow in scenario 1. 

5. **Kubernetes**: Run the released Application Package CWL using `calrissian`, a CWL runner for kubernetes that creates a pod for each of the Workflow processing step. An additional Notebook is provided to demonstrate the use of the `calrissian` "usage report" feature to generate a resource consumption report of the execution. 

## Overview Flowchart and Key Tools

The tutorial is structured in several parts:

``` mermaid
%%{init: { 'logLevel': 'debug', 'theme': 'forest' } }%%
timeline
title Mastering EO Application Packaging with CWL
Part 1 - Water bodies detection
    : Short introduction 
    : Application steps
Part 2 - Execution in Python environments
    : Create Python environment
    : Run Python script 
Part 3 - Package the Application 1/2
    : Create and test the containers
    : Create the CWL CommandLineTool
  : Run the CWL CommandLineTool with podman
Part 4 - Package the Application 2/2
    : CWL Workflow for Sentinel-2 Cloud Native processing
    : CWL Workflow for Landsat-9 processing (includes stage-in/out)
    : CWL Workflow of workflows 
Part 5 - Release the Application
    : Continuous Integration
    : Containers published in a container registry
    : Application Packages in a package registry
Part 6 - Execution Scenarios
    : Execution using a CWL runner (cwltool)
    : Execution on kubernetes using the calrissian CWL runner
Part 7 - FAIR Application Packages
    : Recommendations and Best Practices
```

The tooling used during each part is listed below:

``` mermaid
%%{init: { 'logLevel': 'debug', 'theme': 'forest' } }%%
timeline
title Tooling
Part 1 - Water bodies detection
    : N/A
Part 2 - Execution in Python environments
    : python venv
    : python 
Part 3 - Package the Application 1/2
    : podman
    : cwltool
Part 4 - Package the Application 2/2
    : cwltool
Part 5 - Release the Application
    : N/A
Part 6 - Execution Scenarios
    : cwltool
    : calrissian
Part 7 - FAIR Application Packages
    : N/A 
```