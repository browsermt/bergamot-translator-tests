#!/bin/bash

#####################################################################
# SUMMARY: Run tests for alignment-matrix-probs
# AUTHOR: jerinphilip 
# TAGS: full
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=${BRT_DATA}/simple/bergamot/$(brt_outfile "alignment-probs")
EXPECTED=${BRT_DATA}/simple/bergamot/$(brt_expected "alignment-probs")
${BRT_MARIAN}/app/bergamot --bergamot-mode test-alignment-scores ${BRT_FILE_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE

# Compare with output specific to hardware.
if [[ "$BRT_EVAL_MODE" == "approx" ]]; then
   echo "Quality scores cannot be evaluated in an approximate setting, due to sampling-step and error propogation involved"
   exit 100
else
   # Switch to percentage error rates? 
   python3 $BRT_TOOLS/diff-nums.py --allow-n-diffs 5 $OUTFILE ${EXPECTED} 
fi
exit 0
