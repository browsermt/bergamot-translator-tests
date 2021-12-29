#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip 
# TAGS: full, blocking
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "html-translation")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "html-translation")
${BRT_MARIAN}/tests/blocking --bergamot-mode test-html-translation ${BRT_ASYNC_ARGS} < ${BRT_DATA}/simple/bergamot.html/input.txt > $OUTFILE 

# Compare with output specific to hardware.
if [[ "$BRT_EVAL_MODE" == "approx" ]]; then
    python3 $BRT_TOOLS/approx-diff.py $OUTFILE ${EXPECTED}
else
    $BRT_TOOLS/diff.sh $OUTFILE ${EXPECTED} 
fi
exit 0
