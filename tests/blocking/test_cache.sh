#!/bin/bash

#####################################################################
# SUMMARY: Run tests for translation-cache
# AUTHOR: jerinphilip 
# TAGS: full, blocking
#####################################################################

set -eo pipefail;

# There are no output / expected files here. Just a check if the cache-stats reflect that the cache works correctly, ABORT contained within the test-app if not.

${BRT_MARIAN}/tests/blocking --bergamot-mode test-translation-cache --cache-size=2000 ${BRT_BLOCKING_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt

exit 0
