#!/bin/bash

#####################################################################
# SUMMARY: Run tests for faithful-translation
# AUTHOR: jerinphilip 
# TAGS: full, native
#####################################################################

set -eo pipefail;

ARGS=(
    --model-config-paths 
        "$BRT_TEST_PACKAGE_EN_ES/config.intgemm8bitalpha.yml.bergamot.yml" # forward
        "$BRT_TEST_PACKAGE_ES_EN/config.intgemm8bitalpha.yml.bergamot.yml" # backward
    --cpu-threads 4
)

${BRT_MARIAN}/bergamot-test --bergamot-mode test-pivot "${ARGS[@]}" < ${BRT_DATA}/simple/bergamot/input.txt


exit 0
