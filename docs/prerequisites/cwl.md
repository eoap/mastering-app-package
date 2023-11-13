
The paper [_Methods Included: Standardizing Computational Reuse and Portability with the Common Workflow Language_](https://arxiv.org/abs/2105.07028) provides an excellent description of the Common Workflow Language project producing free and open standards for describing command-line
tool based workflows.

## TL;DR

Although the paper provides a clear and concise description of the CWL standards, here's a light summary wrapping up the main points to provide the required concepts behind this guide.

### CWL Key Insights

1. CWL is a set of standards for describing and sharing computational workflows.

2. The CWL standards are used daily in many science and engineering domains, including by multi-stakeholder teams.

3. The CWL standards use a declarative syntax, facilitating polylingual workflow tasks. By being explicit about the run-time environment and any use of software containers, the CWL standards enable portability and reuse. 

4. The CWL standards provide a separation of concerns between workflow authors and workflow platforms.

5. The CWL standards support critical workflow concepts like automation, scalability, abstraction, provenance, portability, and reusability. 

6. The CWL standards are developed around core principles of community and shared decision-making, re-use, and zero cost for participants.

7. The CWL standards are provided as freely available open standards, supported by a diverse community in collaboration with industry, and is a Free/Open Source Software ecosystem 

### CWL Features

The CWL standard support polylingual and multi-party workflows and includes two main components:

1. A standard for describing command line tools

2. A standard for describing workflows that compose such tool descriptions

The CWL standards define an explicit language with a textual syntax derived from YAML

#### CWL Command Line Tool Description Standard

The CWL Command Line Tool Description Standard describes:

- how a particular command line tool works: what are the
inputs and parameters and their types
- how to add the correct flags and switches to the command line invocation 
- where to find the output files

#### CWL Workflow Description Standard

The CWL Workflow Description Standard is based on the same textual syntax derived from YAML to explicit workflow level inputs, outputs and steps.

Steps are comprised of CWL CommandLineTools or CWL sub-workflows, each re-exposing their tool’s required inputs. 

Inputs for each step are connected by referencing the name of either the common workflow inputs or particular outputs of other steps.

The workflow outputs expose selected outputs from workflow steps.

Being CWL a set of standards, the workflows are executed using a CWL _runner_ and there are several implementations of such runners. 

This guide uses the CWL runner [cwltool](https://pypi.org/project/cwltool).

### Recommendations

- Include documentation and labels for all components to enable the automatic generation of helpful visual depictions for any given CWL description

- Include metadata about the tool  

- Include a _Workflow_ class for all CommandLineTools (a single step Workflow)

- Organize your CWL files is several individual files to ease their readability and maintenance. Pack your multi-file CWL Workflows (`cwltool --pack`) when needed

## References

- Crusoe, M. R. et al. _Methods Included: Standardizing Computational Reuse and Portability with the Common Workflow Language_, retrieved from https://arxiv.org/abs/2105.07028