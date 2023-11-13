When developers package and EO, they are in fact packaging their own software, written in a specific programming language, as a containerized application (or a set of containerized applications), to be described as an EO Application Package using the Common Workflow Language as described in the OGC proposed best practices.

To achieve this, developers follow the steps described below.

* Prepare one or more container images containing the execution dependencies of the software.
* Prepare the CWL CommandLineTool document(s) wrapping the command line tool available in container(s).
* Prepare the CWL Workflow orchestrating CWL CommandLineTool document(s) wrapping the command line tool available container(s).
* **Test the application package in one or more execution scenarios**.

This page covers the step:

**Test the application package in one or more execution scenarios**