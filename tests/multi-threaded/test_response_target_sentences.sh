#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip 
# TAGS: full
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "response-target-sentences")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "response-target-sentences")
${BRT_MARIAN}/bergamot-test --bergamot-mode test-response-target-sentences ${BRT_FILE_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE 

# Compare with output specific to hardware.
if [[ "$BRT_EVAL_MODE" == "approx" ]]; then
    python3 $BRT_TOOLS/approx-diff.py $OUTFILE ${EXPECTED}
else
    $BRT_TOOLS/diff.sh $OUTFILE ${EXPECTED} 
fi
exit 0
