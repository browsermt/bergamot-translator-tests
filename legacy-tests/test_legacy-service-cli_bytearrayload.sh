#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip 
# TAGS: full
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=${BRT_DATA}/simple/bergamot/$(brt_outfile "legacy-service-cli")
EXPECTED=${BRT_DATA}/simple/bergamot/$(brt_expected "legacy-service-cli")
${BRT_MARIAN}/app/bergamot --bergamot-mode legacy-service-cli ${BRT_BYTEARRAY_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE

# Compare with output specific to hardware.
if [[ "$BRT_EVAL_MODE" == "approx" ]]; then
   $BRT_TOOLS/approx-diff.py $OUTFILE $EXPECTED 
else
   $BRT_TOOLS/diff.sh $OUTFILE $EXPECTED 
fi
exit 0
