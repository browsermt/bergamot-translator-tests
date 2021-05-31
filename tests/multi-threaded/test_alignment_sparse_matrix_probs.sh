#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip 
# TAGS: full
#####################################################################

set -eo pipefail;

source "$BRT_TOOLS/functions.sh"

ARGS=(
    -m $BRT_TEST_PACKAGE_EN_DE/model.intgemm.alphas.bin
    --vocabs 
        $BRT_TEST_PACKAGE_EN_DE/vocab.deen.spm 
        $BRT_TEST_PACKAGE_EN_DE/vocab.deen.spm
    --shortlist $BRT_TEST_PACKAGE_EN_DE/lex.s2t 50 50
    --alignment soft
    --beam-size 1
    --skip-cost
    --int8shiftAlphaAll
    --cpu-threads 4
    --max-length-break 1024
    --mini-batch-words 1024
    -w 128
)

# Generate output specific to hardware.
OUTFILE=${BRT_DATA}/simple/bergamot/$(brt_outfile "alignment-probs")
EXPECTED=${BRT_DATA}/simple/bergamot/$(brt_expected "alignment-probs")
${BRT_MARIAN}/app/bergamot --bergamot-mode test-alignment-scores "${ARGS[@]}" < ${BRT_DATA}/simple/bergamot/input.txt > $OUTFILE

# Compare with output specific to hardware.
python3 $BRT_TOOLS/diff-nums.py $OUTFILE ${EXPECTED} 
exit 0
