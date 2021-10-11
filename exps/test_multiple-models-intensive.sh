
#!/bin/bash

#####################################################################
# SUMMARY: Run tests for faithful-translation
# AUTHOR: jerinphilip 
# TAGS: full, native
#####################################################################

set -eo pipefail;

ARGS=(
    --model-config-paths 
        "$BRT_TEST_PACKAGE_EN_ES/config.intgemm8bitalpha.yml.bergamot.yml" # one-model
        "$BRT_TEST_PACKAGE_EN_DE/config.intgemm8bitalpha.yml.bergamot.yml" # another
    --cpu-threads 40
)

# Generate output specific to hardware.
${BRT_MARIAN}/bergamot-test --bergamot-mode test-multimodels-intensive "${ARGS[@]}" < ${BRT_DATA}/wngt20/sources.shuf


exit 0
