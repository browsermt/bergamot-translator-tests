#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip
# TAGS: full, native
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "quality_estimator_words")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "quality_estimator_words")

${BRT_MARIAN}/bergamot-test --bergamot-mode test-quality-estimator-words ${BRT_FILE_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE

$BRT_TOOLS/diff.sh $OUTFILE $EXPECTED

OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "quality_estimator_scores")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "quality_estimator_scores")

${BRT_MARIAN}/bergamot-test --bergamot-mode test-quality-estimator-scores ${BRT_FILE_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE

$BRT_TOOLS/diff-nums.py -p 0.0001 $OUTFILE $EXPECTED

exit 0
