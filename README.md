Marian regression tests
=======================

The template for this repository is borrowed from the
[marian-regression-tests](https://github.com/marian-nmt/marian-regression-tests/)
repository. 

<b>Marian</b> is an efficient Neural Machine Translation framework written in
pure C++ with minimal dependencies. <b>Bergamot</b> project involves using marian to
bring machine-translation to the client side.

This repository contains the regression test framework for the main development
repository: https://github.com/browsermt/bergamot-translator.

Tests have been developed for Linux for Marian compiled using GCC 8+.

Note: GPU tests are not functional at the moment.


## Structure

Directories:

* `tests` - regression tests
* `tools` - scripts and repositories
* `models` - models used in regression tests
* `data` - data used in training or decoding tests

Each test consists of:

* `test_*.sh` file
* `setup.sh` (optional)
* `teardown.sh` (optional)


## Usage

Downloading required data and tools:

    make install

Running regression tests:

    MARIAN=/path/to/bergamot-translator/build ./run_brt.sh

Enabling multi-GPU tests:

    CUDA_VISIBLE_DEVICES=0,1 ./run_brt.sh

More invocation examples:

    ./run_brt.sh tests/training/basics
    ./run_brt.sh tests/training/basics/test_valid_script.sh
    ./run_brt.sh previous.log
    ./run_brt.sh '#cpu'

where `previous.log` contains a list of test files, one test per line.  This
file is automatically generated each time `./run_brt.sh` finishes running.
The last example starts all regression tests labeled with '#tag'.  The list of
tests annotated with each available tag can be displayed by running
`./show_tags.sh`, e.g.:

    ./show_tags.sh cpu

Cleaning test artifacts:

    make clean

Notes:
- Majority of tests has been designed for GPU, so the framework assumes it runs
  Marian compiled with the CUDA support. To run only tests designed for CPU,
  use `./run_brt.sh '#cpu'`.
- Directories and test files with names starting with an underscore are turned
  off and are not traversed or executed by `./run_brt.sh`.
- Only some regression tests have been annotated with tags, so, for example,
  running tests with the tag #scoring will not start all available tests for
  scoring. The complete tags are #cpu, #server.


## Debugging failed tests

Failed tests are displayed at the end of testing or in `previous.log`, e.g.:

    Failed:
    - tests/training/restoring/multi-gpu/test_async.sh
    - tests/training/embeddings/test_custom_embeddings.sh
    ---------------------
    Ran 145 tests in 00:48:48.210s, 143 passed, 0 skipped, 2 failed

Logging messages are in files ending with _.sh.log_ suffix:

    less tests/training/restoring/multi-gpu/test_async.sh.log

The last command in most tests is an execution of a custom `diff` tool, which
prints the exact invocation commands with absolute paths. It can be used to
display the differences that cause the test fails.


## Adding new tests

Use templates provided in `tests/_template`.

Please follow these recommendations:

* Test one thing at a time
* For comparing outputs with numbers, please use float-friendly
  `tools/diff-nums.py` instead of GNU `diff`
* Make your tests deterministic using `--no-shuffle --seed 1111` or similar
* Make training execution time as short as possible, for instance, by reducing
  the size of the network and the number of iterations
* Do not run decoding or scoring on files longer than ca. 10-100 lines
* If your tests require downloading and running a custom model, please keep it
  as small as possible, and contact me (Roman) to upload it into our storage


## Continuous Integration

The regression tests are run automatically on GitHub CI on pull-request against
or push to main at
[browsermt/bergamot-translator](https://github.com/browsermt/bergamot-translator).

There are several variations supporting two platforms of builds. Keeping
platform differences aside, there is a single-threaded path allowing compiling
bergamot-translator targetting WASM for purposes of a local browser extension,
and a multithreaded path allowing for usage locally maximizing efficiency.
If build succeeds, created executables are used to run regression tests.

Please refer to the
[bergamot-translator](https://github.com/browsermt/bergamot-translator)
repository, or workflow files on instructions to build for each path.

In this repository, tests capable to run in these modes are filed using tags. 

```bash
# To run only test test-apps in the WASM path 
BRT_MARIAN=../build ./run_brt.sh '#wasm'

# To run tests on full path with multithreading etc.
# Do not specify any tags
BRT_MARIAN=../build ./run_brt.sh 
```

When adding a test to this repository, please place tags accordingly.

## Data storage

We host data and models used for regression tests on statmt.org (see
`models/download-models.sh`). If you want to add new files required for new
regression tests to our storage, please open a new issue providing a link to
tarball.


