#!/bin/bash

#####################################################################
# SUMMARY: faithful-translation with bytearray load capabilities
# AUTHOR: jerinphilip 
# TAGS: full
#####################################################################

set -eo pipefail;


# Generate output specific to hardware.
OUTFILE=${BRT_DATA}/simple/bergamot/$(brt_outfile "faithful-translation")
EXPECTED=${BRT_DATA}/simple/bergamot/$(brt_expected "faithful-translation")
${BRT_MARIAN}/app/bergamot --bergamot-mode native ${BRT_BYTEARRAY_ARGS} < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE

# Compare with output specific to hardware.
$BRT_TOOLS/diff.sh $OUTFILE $EXPECTED

exit 0
