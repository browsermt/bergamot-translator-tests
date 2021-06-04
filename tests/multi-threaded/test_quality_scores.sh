#!/bin/bash

#####################################################################
# SUMMARY: Run tests for quality-scores
# AUTHOR: jerinphilip 
# TAGS: full
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "quality-scores")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "quality-scores")
${BRT_MARIAN}/app/bergamot-test --bergamot-mode test-quality-scores ${BRT_FILE_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE 

if [[ "$BRT_EVAL_MODE" == "approx" ]]; then
   echo "Quality scores cannot be evaluated in an approximate setting, due to sampling-step and error propogation involved"
   exit 100
else
   python3 ${BRT_TOOLS}/diff-nums.py --allow-n-diffs 20 ${OUTFILE} ${EXPECTED}
fi

exit 0
