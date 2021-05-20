#!/bin/bash

#####################################################################
# SUMMARY: Run tests for bergamot-translator-app
# AUTHOR: jerinphilip 
# TAGS: wasm, full, mac
#####################################################################


set -eo pipefail;

BRT_INSTRUCTION=$( $BRT_TOOLS/detect-instruction.sh )
prefix=intgemm_8bit

ARGS=(
    -m $BRT_TEST_PACKAGE_EN_DE/model.intgemm.alphas.bin
    --vocabs 
        $BRT_TEST_PACKAGE_EN_DE/vocab.deen.spm 
        $BRT_TEST_PACKAGE_EN_DE/vocab.deen.spm
    --shortlist $BRT_TEST_PACKAGE_EN_DE/lex.s2t 50 50
    --beam-size 1
    --skip-cost
    --int8shiftAlphaAll
    --max-length-break 1024
    --mini-batch-words 1024
    -w 128

    --ssplit-mode paragraph
    --check-bytearray false
    --cpu-threads 0
)

# Generate output specific to hardware.
OUTFILE="bergamot.$prefix.$BRT_INSTRUCTION.out"
${BRT_MARIAN}/app/bergamot-translator-app "${ARGS[@]}" < ${BRT_DATA}/simple/bergamot.in > $OUTFILE

#This used to be provided via stdin: < ${BRT_DATA}/simple/bergamot.in  but the bergamot-translator-app doesn't accept stdin text
# Compare with output specific to hardware.
$BRT_TOOLS/diff.sh $OUTFILE bergamot.$prefix.$BRT_INSTRUCTION.expected > $prefix.$BRT_INSTRUCTION.diff
exit 0
