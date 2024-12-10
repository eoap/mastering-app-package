# Mastering Earth Observation Application Packaging with CWL

This guide supports training events, where participants dive into the world of EO Application Packages and explore how to effectively package, share, and execute Earth observation workflows using the Common Workflow Language (CWL) standard.

This tutorial is designed for developers, scientists, and Earth observation enthusiasts who want to enhance their skills in creating and sharing EO Application Packages. 

Whether participants are new to CWL or already have some experience, this event provides valuable insights and practical knowledge to boost your expertise.

During a training event, the trainees learn:

* The fundamentals of EO Application Packages and their role in the Earth observation domain.
* How to leverage CWL to describe, package, and share workflows.
* Techniques for incorporating data, code, configuration files, and documentation into an EO Application Package.
* Best practices for creating portable and reproducible Earth observation workflows.
* Hands-on exercises to reinforce your understanding and gain practical experience.

When developers package and EO, they are in fact packaging their own software, written in a specific programming language, as a containerized application (or a set of containerized applications), to be described as an EO Application Package using the Common Workflow Language as described in the OGC proposed best practices.

To achieve this, developers follow the steps described below.

* Test the Application's individual steps
* Prepare one or more container images containing the execution dependencies of the software.
* Prepare the CWL CommandLineTool document(s) wrapping the command line tool available in container(s).
* Prepare the CWL Workflow orchestrating CWL CommandLineTool document(s) wrapping the command line tool available container(s).
* Test the application package in one or more execution scenarios.

This tutorial guides participants through step-by-step tutorials, demonstrating the process of creating EO Application Packages using CWL with a simple EO application for water bodies detection using NDWI. 

The webpage of the documentation is https://eoap.github.io/mastering-app-package/. 

[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC_BY--SA_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)