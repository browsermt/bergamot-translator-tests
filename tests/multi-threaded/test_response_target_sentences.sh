#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip 
# TAGS: full
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "response-target-sentences")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "response-target-sentences")
${BRT_MARIAN}/app/bergamot --bergamot-mode test-response-target-sentences ${BRT_FILE_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE 

$BRT_TOOLS/diff.sh $OUTFILE $EXPECTED 
exit 0
