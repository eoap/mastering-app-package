
Previous OGC Testbeds 13-16 initiated the design of an application package for Earth Observation Applications in distributed Cloud Platforms 

The application package provides information about the software item, metadata and dependencies

The application package can be deployed and executed within an Exploitation Platform in a service compliant with the OGC API Processes specification

OGC 20-089 defines the Best Practice to package and deploy Earth Observation Applications in an Exploitation Platform


OGC 20-089 defines guidance for the 3 viewpoints:

* For a Developer to adapt an application 
* For an Integrator to package an application 
* For an Platform to deploy and execute the application

12 submitters organisations:

* Pedro Gonçalves (editor)	Terradue
* Fabrice Brito	Terradue
* Tom Landry	CRIM
* Francis Charette-Migneault	CRIM
* Richard Conway	Telespazio VEGA UK
* Adrian Luna	European Union Satellite Centre
* Omar Barrilero	European Union Satellite Centre
* Panagiotis (Peter) A. Vretanos	CubeWerx Inc.
* Cristiano Lopes	European Space Agency (ESA)
* Antonio Romeo	RHEA Group
* Paulo Sacramento	Solenix
* Samantha Lavender	Pixalytics
* Marian Neagul	West University of Timisoara

## Application Package Drivers

Decouple application developers from exploitation platform operators and from application consumers:

* Focus on application development by minimizing platform specific particularities
* Make their applications compatible with several execution scenarios 

Enable exploitation platforms to virtually support any type of packaged EO application

## Application Package Role

The Application Package:

* Describes the data processing application by providing information about parameters, software item, executable, dependencies and metadata. 
* Ensures that the application is fully portable supporting execution and automatic deployment in a Machine-To- Machine (M2M) scenario and execution in other scenarios. 
* Contains an information model to allow its deployment of the application as OGC API - Processes compliant web service


## Application Package Process

Application developers:

* Create containers with their runtime environment, dependencies and command line tools
* Orchestrate the processing steps in a Directed Acyclic Graph (DAG)
* Use fan-out or fan-in patterns at step level to exploit distributed computing resources
* Describe their Application Package using the Common Workflow Language (CWL) 

## About the Common Workflow Language (CWL)

The Common Workflow Language (CWL) is an open standard for describing analysis workflows and tools in a way that makes them portable and scalable across a variety of software and hardware environments, from workstations to cluster, cloud, and high performance computing environments.

The CWL is a specification for describing analysis workflows and tools.

CWL workflows are portable and scalable across a variety of software and hardware environments, from workstations to cluster, cloud, and high performance computing (HPC) environments.

CWL is designed to meet the needs of data-intensive science, such as Bioinformatics, Medical Imaging, Astronomy, Physics, and Chemistry.

