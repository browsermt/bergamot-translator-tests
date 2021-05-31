#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip 
# TAGS: full
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "quality-scores")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "quality-scores")
${BRT_MARIAN}/app/bergamot --bergamot-mode test-quality-scores ${BRT_FILE_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE 

# Compare with output specific to hardware.
python3 ${BRT_TOOLS}/diff-nums.py ${OUTFILE} ${EXPECTED}
exit 0
