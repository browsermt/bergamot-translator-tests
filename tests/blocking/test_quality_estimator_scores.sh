#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: felipesantosk
# TAGS: full, native
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/quality-estimator/$(brt_outfile "scores")
EXPECTED=$BRT_DATA/quality-estimator/$(brt_expected "scores")

${BRT_MARIAN}/tests/blocking --bergamot-mode test-quality-estimator-scores ${BRT_EN_ET_WASM_ARGS} < ${BRT_DATA}/quality-estimator/input.txt > $OUTFILE

$BRT_TOOLS/diff-nums.py -p 0.001 $OUTFILE $EXPECTED

exit 0
