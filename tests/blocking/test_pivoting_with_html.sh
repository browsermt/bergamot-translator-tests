#!/bin/bash

#####################################################################
# SUMMARY: Run tests for faithful-translation
# AUTHOR: jerinphilip 
# TAGS: full, blocking
#####################################################################

set -eo pipefail;

ARGS=(
    --model-config-paths 
        "$BRT_TEST_PACKAGE_EN_ES/config.intgemm8bitalpha.yml.bergamot.yml" # forward
        "$BRT_TEST_PACKAGE_ES_EN/config.intgemm8bitalpha.yml.bergamot.yml" # backward
)

# Generate output specific to hardware.
OUTFILE=${BRT_DATA}/simple/bergamot/$(brt_outfile "pivoting-with-html")
EXPECTED=${BRT_DATA}/simple/bergamot/$(brt_expected "pivoting-with-html")

${BRT_MARIAN}/tests/blocking --bergamot-mode test-pivot-with-html "${ARGS[@]}" < ${BRT_DATA}/simple/bergamot.html/input.txt > $OUTFILE

# Compare with output specific to hardware.
if [[ "$BRT_EVAL_MODE" == "approx" ]]; then
   $BRT_TOOLS/approx-diff.py $OUTFILE $EXPECTED 
else
   $BRT_TOOLS/diff.sh $OUTFILE $EXPECTED 
fi



exit 0
