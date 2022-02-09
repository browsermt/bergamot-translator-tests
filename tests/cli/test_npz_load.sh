#!/bin/bash

#####################################################################
# SUMMARY: Run tests for npz-load
# AUTHOR: jerinphilip 
# TAGS: full, native
#####################################################################

set -eo pipefail;

# Generate output specific to hardware.
OUTFILE=${BRT_DATA}/simple/bergamot/$(brt_outfile "faithful-translation")
EXPECTED=${BRT_DATA}/simple/bergamot/$(brt_expected "faithful-translation")
${BRT_MARIAN}/app/bergamot --model-config-paths "$BRT_TEST_PACKAGE_EN_DE/config.yml.bergamot.yml" \
        < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE

# We will use approx
$BRT_TOOLS/approx-diff.py $OUTFILE $EXPECTED 
