#!/bin/bash

#####################################################################
# SUMMARY: Run tests for faithful-translation
# AUTHOR: jerinphilip 
# TAGS: full
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=${BRT_DATA}/simple/bergamot/$(brt_outfile "faithful-translation")
EXPECTED=${BRT_DATA}/simple/bergamot/$(brt_expected "faithful-translation")
${BRT_MARIAN}/app/bergamot --bergamot-mode native ${BRT_FILE_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE

# Compare with output specific to hardware.
if [[ "$BRT_EVAL_MODE" == "approx" ]]; then
   $BRT_TOOLS/approx-diff.py $OUTFILE $EXPECTED 
else
   $BRT_TOOLS/diff.sh $OUTFILE $EXPECTED 
fi

exit 0
