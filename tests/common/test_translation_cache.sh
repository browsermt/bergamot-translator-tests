#!/bin/bash

#####################################################################
# SUMMARY: Run tests for translation-cache
# AUTHOR: jerinphilip 
# TAGS: full, wasm, native
#####################################################################

set -eo pipefail;

# There are no output / expected files here. Just a check if the cache-stats reflect that the cache works correctly, ABORT contained within the test-app if not.

${BRT_MARIAN}/bergamot-test --bergamot-mode test-translation-cache ${BRT_FILE_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt

exit 0
