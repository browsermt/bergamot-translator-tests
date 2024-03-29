#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip 
# TAGS: full, async
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "response-source-sentences")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "response-source-sentences")
${BRT_MARIAN}/tests/async --bergamot-mode test-response-source-sentences ${BRT_ASYNC_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE 

# Source sentences are deterministic.
$BRT_TOOLS/diff.sh $OUTFILE $EXPECTED 
exit 0
