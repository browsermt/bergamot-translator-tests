#!/bin/bash

#####################################################################
# SUMMARY: Run tests for bergamot-translator-app
# AUTHOR: jerinphilip 
# TAGS: wasm
#####################################################################


set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=${BRT_DATA}/simple/bergamot/$(brt_outfile "wasm")
EXPECTED=${BRT_DATA}/simple/bergamot/$(brt_expected "wasm")
${BRT_MARIAN}/app/bergamot --bergamot-mode wasm ${BRT_BYTEARRAY_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE

# This used to be provided via stdin: < ${BRT_DATA}/simple/bergamot.in  but the bergamot-translator-app doesn't accept stdin text
# Compare with output specific to hardware.
$BRT_TOOLS/diff.sh $OUTFILE $EXPECTED 
exit 0
