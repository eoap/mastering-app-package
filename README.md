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

1. **Application**: Understand the Application and execute its individual steps along with their associated Python modules.
2. **Containers**: Build container images for each Application step with the required execution software dependencies, then run each step in its respective container.
3. **CWL-CommandLineTool**: Prepare the CWL CommandLineTool document(s) wrapping the command line tool available in container(s).
4. **CWL-Workflow**: Prepare the CWL Workflow orchestrating CWL CommandLineTool document(s) wrapping the command line tool available container(s).

The webpage of the documentation is https://eoap.github.io/mastering-app-package/. 

[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC_BY--SA_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)