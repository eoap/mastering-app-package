
```linenums="1" hl_lines="154-166 169-171"
usage: calrissian [-h] [--basedir BASEDIR] [--outdir OUTDIR] [--log-dir LOG_DIR] [--parallel]
                  [--preserve-environment ENVVAR | --preserve-entire-environment] [--rm-container | --leave-container] [--cidfile-dir CIDFILE_DIR]
                  [--cidfile-prefix CIDFILE_PREFIX] [--tmpdir-prefix TMPDIR_PREFIX] [--tmp-outdir-prefix TMP_OUTDIR_PREFIX | --cachedir CACHEDIR]
                  [--rm-tmpdir | --leave-tmpdir] [--move-outputs | --leave-outputs | --copy-outputs] [--enable-pull | --disable-pull]
                  [--rdf-serializer RDF_SERIALIZER] [--eval-timeout EVAL_TIMEOUT] [--provenance PROVENANCE] [--enable-user-provenance]
                  [--disable-user-provenance] [--enable-host-provenance] [--disable-host-provenance] [--orcid ORCID] [--full-name CWL_FULL_NAME]
                  [--print-rdf | --print-dot | --print-pre | --print-deps | --print-input-deps | --pack | --version | --validate | --print-supported-versions | --print-subgraph | --print-targets | --make-template]
                  [--strict | --non-strict] [--skip-schemas] [--no-doc-cache | --doc-cache] [--verbose | --quiet | --debug]
                  [--write-summary WRITE_SUMMARY] [--strict-memory-limit] [--strict-cpu-limit] [--timestamps] [--js-console] [--disable-js-validation]
                  [--js-hint-options-file JS_HINT_OPTIONS_FILE] [--user-space-docker-cmd CMD | --udocker | --singularity | --podman | --no-container]
                  [--beta-dependency-resolvers-configuration BETA_DEPENDENCY_RESOLVERS_CONFIGURATION]
                  [--beta-dependencies-directory BETA_DEPENDENCIES_DIRECTORY] [--beta-use-biocontainers] [--beta-conda-dependencies] [--tool-help]
                  [--relative-deps {primary,cwd}] [--enable-dev] [--enable-ext] [--enable-color | --disable-color]
                  [--default-container DEFAULT_CONTAINER] [--no-match-user] [--custom-net CUSTOM_NET]
                  [--enable-ga4gh-tool-registry | --disable-ga4gh-tool-registry] [--add-ga4gh-tool-registry GA4GH_TOOL_REGISTRIES]
                  [--on-error {stop,continue}] [--compute-checksum | --no-compute-checksum] [--relax-path-checks] [--force-docker-pull]
                  [--no-read-only] [--overrides OVERRIDES] [--target TARGET | --single-step SINGLE_STEP | --single-process SINGLE_PROCESS]
                  [--mpi-config-file MPI_CONFIG_FILE] [--max-ram MAX_RAM] [--max-cores MAX_CORES] [--pod-labels [POD_LABELS]]
                  [--pod-env-vars [POD_ENV_VARS]] [--pod-nodeselectors [POD_NODESELECTORS]] [--pod-serviceaccount POD_SERVICEACCOUNT]
                  [--usage-report [USAGE_REPORT]] [--stdout [STDOUT]] [--stderr [STDERR]] [--tool-logs-basepath [TOOL_LOGS_BASEPATH]] [--conf CONF]
                  [cwl_document] ...

Reference executor for Common Workflow Language standards. Not for production use.

positional arguments:
  cwl_document          path or URL to a CWL Workflow, CommandLineTool, or ExpressionTool. If the `inputs_object` has a `cwl:tool` field indicating
                        the path or URL to the cwl_document, then the `cwl_document` argument is optional.
  inputs_object         path or URL to a YAML or JSON formatted description of the required input values for the given `cwl_document`.

optional arguments:
  -h, --help            show this help message and exit
  --basedir BASEDIR
  --outdir OUTDIR       Output directory. The default is the current directory.
  --log-dir LOG_DIR     Log your tools stdout/stderr to this location outside of container This will only log stdout/stderr if you specify
                        stdout/stderr in their respective fields or capture it as an output
  --parallel            [experimental] Run jobs in parallel.
  --preserve-environment ENVVAR
                        Preserve specific environment variable when running CommandLineTools. May be provided multiple times. By default PATH is
                        preserved when not running in a container.
  --preserve-entire-environment
                        Preserve all environment variables when running CommandLineTools without a software container.
  --rm-container        Delete Docker container used by jobs after they exit (default)
  --leave-container     Do not delete Docker container used by jobs after they exit
  --tmpdir-prefix TMPDIR_PREFIX
                        Path prefix for temporary directories. If --tmpdir-prefix is not provided, then the prefix for temporary directories is
                        influenced by the value of the TMPDIR, TEMP, or TMP environment variables. Taking those into consideration, the current
                        default is /tmp/.
  --tmp-outdir-prefix TMP_OUTDIR_PREFIX
                        Path prefix for intermediate output directories. Defaults to the value of --tmpdir-prefix.
  --cachedir CACHEDIR   Directory to cache intermediate workflow outputs to avoid recomputing steps. Can be very helpful in the development and
                        troubleshooting of CWL documents.
  --rm-tmpdir           Delete intermediate temporary directories (default)
  --leave-tmpdir        Do not delete intermediate temporary directories
  --move-outputs        Move output files to the workflow output directory and delete intermediate output directories (default).
  --leave-outputs       Leave output files in intermediate output directories.
  --copy-outputs        Copy output files to the workflow output directory and don't delete intermediate output directories.
  --enable-pull         Try to pull Docker images
  --disable-pull        Do not try to pull Docker images
  --rdf-serializer RDF_SERIALIZER
                        Output RDF serialization format used by --print-rdf (one of turtle (default), n3, nt, xml)
  --eval-timeout EVAL_TIMEOUT
                        Time to wait for a Javascript expression to evaluate before giving an error, default 60s.
  --print-rdf           Print corresponding RDF graph for workflow and exit
  --print-dot           Print workflow visualization in graphviz format and exit
  --print-pre           Print CWL document after preprocessing.
  --print-deps          Print CWL document dependencies.
  --print-input-deps    Print input object document dependencies.
  --pack                Combine components into single document and print.
  --version             Print version and exit
  --validate            Validate CWL document only.
  --print-supported-versions
                        Print supported CWL specs.
  --print-subgraph      Print workflow subgraph that will execute. Can combined with --target or --single-step
  --print-targets       Print targets (output parameters)
  --make-template       Generate a template input object
  --strict              Strict validation (unrecognized or out of place fields are error)
  --non-strict          Lenient validation (ignore unrecognized fields)
  --skip-schemas        Skip loading of schemas
  --no-doc-cache        Disable disk cache for documents loaded over HTTP
  --doc-cache           Enable disk cache for documents loaded over HTTP
  --verbose             Default logging
  --quiet               Only print warnings and errors.
  --debug               Print even more logging
  --write-summary WRITE_SUMMARY, -w WRITE_SUMMARY
                        Path to write the final output JSON object to. Default is stdout.
  --strict-memory-limit
                        When running with software containers and the Docker engine, pass either the calculated memory allocation from
                        ResourceRequirements or the default of 1 gigabyte to Docker's --memory option.
  --strict-cpu-limit    When running with software containers and the Docker engine, pass either the calculated cpu allocation from
                        ResourceRequirements or the default of 1 core to Docker's --cpu option. Requires docker version >= v1.13.
  --timestamps          Add timestamps to the errors, warnings, and notifications.
  --js-console          Enable javascript console output
  --disable-js-validation
                        Disable javascript validation.
  --js-hint-options-file JS_HINT_OPTIONS_FILE
                        File of options to pass to jshint. This includes the added option "includewarnings".
  --user-space-docker-cmd CMD
                        (Linux/OS X only) Specify the path to udocker. Implies --udocker
  --udocker             (Linux/OS X only) Use the udocker runtime for running containers (equivalent to --user-space-docker-cmd=udocker).
  --singularity         [experimental] Use Singularity runtime for running containers. Requires Singularity v2.6.1+ and Linux with kernel version
                        v3.18+ or with overlayfs support backported.
  --podman              [experimental] Use Podman runtime for running containers.
  --no-container        Do not execute jobs in a Docker container, even when `DockerRequirement` is specified under `hints`.
  --beta-dependency-resolvers-configuration BETA_DEPENDENCY_RESOLVERS_CONFIGURATION
                        Dependency resolver configuration file describing how to adapt 'SoftwareRequirement' packages to current system.
  --beta-dependencies-directory BETA_DEPENDENCIES_DIRECTORY
                        Default root directory used by dependency resolvers configuration.
  --beta-use-biocontainers
                        Use biocontainers for tools without an explicitly annotated Docker container.
  --beta-conda-dependencies
                        Short cut to use Conda to resolve 'SoftwareRequirement' packages.
  --tool-help           Print command line help for tool
  --relative-deps {primary,cwd}
                        When using --print-deps, print paths relative to primary file or current working directory.
  --enable-dev          Enable loading and running unofficial development versions of the CWL standards.
  --enable-ext          Enable loading and running 'cwltool:' extensions to the CWL standards.
  --enable-color        Enable logging color (default enabled)
  --disable-color       Disable colored logging (default false)
  --default-container DEFAULT_CONTAINER
                        Specify a default software container to use for any CommandLineTool without a DockerRequirement.
  --no-match-user       Disable passing the current uid to `docker run --user`
  --custom-net CUSTOM_NET
                        Passed to `docker run` as the '--net' parameter when NetworkAccess is true, which is its default setting.
  --enable-ga4gh-tool-registry
                        Enable tool resolution using GA4GH tool registry API
  --disable-ga4gh-tool-registry
                        Disable tool resolution using GA4GH tool registry API
  --add-ga4gh-tool-registry GA4GH_TOOL_REGISTRIES
                        Add a GA4GH tool registry endpoint to use for resolution, default ['https://dockstore.org/api']
  --on-error {stop,continue}
                        Desired workflow behavior when a step fails. One of 'stop' (do not submit any more steps) or 'continue' (may submit other
                        steps that are not downstream from the error). Default is 'stop'.
  --compute-checksum    Compute checksum of contents while collecting outputs
  --no-compute-checksum
                        Do not compute checksum of contents while collecting outputs
  --relax-path-checks   Relax requirements on path names to permit spaces and hash characters.
  --force-docker-pull   Pull latest software container image even if it is locally present
  --no-read-only        Do not set root directory in the container as read-only
  --overrides OVERRIDES
                        Read process requirement overrides from file.
  --target TARGET, -t TARGET
                        Only execute steps that contribute to listed targets (can be provided more than once).
  --single-step SINGLE_STEP
                        Only executes a single step in a workflow. The input object must match that step's inputs. Can be combined with --print-
                        subgraph.
  --single-process SINGLE_PROCESS
                        Only executes the underlying Process (CommandLineTool, ExpressionTool, or sub-Workflow) for the given step in a workflow. This
                        will not include any step-level processing: 'scatter', 'when'; and there will be no processing of step-level 'default', or
                        'valueFrom' input modifiers. However, requirements/hints from the step or parent workflow(s) will be inherited as usual.The
                        input object must match that Process's inputs.
  --mpi-config-file MPI_CONFIG_FILE
                        Platform specific configuration for MPI (parallel launcher, its flag etc). See README section 'Running MPI-based tools' for
                        details of the format.
  --max-ram MAX_RAM     Maximum amount of RAM to use, e.g 1048576, 512Mi or 2G. Follows k8s resource conventions
  --max-cores MAX_CORES
                        Maximum number of CPU cores to use
  --pod-labels [POD_LABELS]
                        YAML file of labels to add to Pods submitted
  --pod-env-vars [POD_ENV_VARS]
                        YAML file of environment variables to add at runtime to Pods submitted
  --pod-nodeselectors [POD_NODESELECTORS]
                        YAML file of node selectors to add to Pods submitted
  --pod-serviceaccount POD_SERVICEACCOUNT
                        Service Account to use for pods management
  --usage-report [USAGE_REPORT]
                        Output JSON file name to record resource usage
  --stdout [STDOUT]     Output file name to tee standard output (CWL output object)
  --stderr [STDERR]     Output file name to tee standard error to (includes tool logs)
  --tool-logs-basepath [TOOL_LOGS_BASEPATH]
                        Base path for saving the tool logs
  --conf CONF           Defines the default values for the CLI arguments

Options for recording the Docker container identifier into a file.:
  --cidfile-dir CIDFILE_DIR
                        Store the Docker container ID into a file in the specified directory.
  --cidfile-prefix CIDFILE_PREFIX
                        Specify a prefix to the container ID filename. Final file name will be followed by a timestamp. The default is no prefix.

Options for recording provenance information of the execution:
  --provenance PROVENANCE
                        Save provenance to specified folder as a Research Object that captures and aggregates workflow execution and data products.
  --enable-user-provenance
                        Record user account info as part of provenance.
  --disable-user-provenance
                        Do not record user account info in provenance.
  --enable-host-provenance
                        Record host info as part of provenance.
  --disable-host-provenance
                        Do not record host info in provenance.
  --orcid ORCID         Record user ORCID identifier as part of provenance, e.g. https://orcid.org/0000-0002-1825-0097 or 0000-0002-1825-0097.
                        Alternatively the environment variable ORCID may be set.
  --full-name CWL_FULL_NAME
                        Record full name of user as part of provenance, e.g. Josiah Carberry. You may need to use shell quotes to preserve spaces.
                        Alternatively the environment variable CWL_FULL_NAME may be set.
```