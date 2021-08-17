#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip
# TAGS: full, native
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "quality_estimator")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "quality_estimator")

${BRT_MARIAN}/bergamot-test --bergamot-mode test-quality-estimator ${BRT_FILE_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE

# Compare with output specific to hardware.
if [[ "$BRT_EVAL_MODE" == "approx" ]]; then
   $BRT_TOOLS/approx-diff.py $OUTFILE $EXPECTED
else
   $BRT_TOOLS/diff.sh $OUTFILE $EXPECTED
fi

exit 0
