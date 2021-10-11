#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: felipesantosk
# TAGS: full, native
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/quality-estimator/$(brt_outfile "words")
EXPECTED=$BRT_DATA/quality-estimator/$(brt_expected "words")

${BRT_MARIAN}/tests/native --bergamot-mode test-quality-estimator-words ${BRT_EN_ET_ARGS} < ${BRT_DATA}/quality-estimator/input.txt > $OUTFILE

$BRT_TOOLS/diff.sh $OUTFILE $EXPECTED

exit 0
