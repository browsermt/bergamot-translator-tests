#!/bin/bash

#####################################################################################
# SUMMARY: Run tests for ssplit, with data file containing a few non-breaking prefixes.
# AUTHOR: jerinphilip 
# TAGS: full, native
#####################################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/ssplit/sample.en.out
EXPECTED=$BRT_DATA/ssplit/sample.en.expected
${BRT_MARIAN}/tests/blocking --bergamot-mode test-response-source-sentences ${BRT_BLOCKING_ARGS} < ${BRT_DATA}/ssplit/sample.en > $OUTFILE 

# Source sentences are deterministic.
$BRT_TOOLS/diff.sh $OUTFILE $EXPECTED 

exit 0
