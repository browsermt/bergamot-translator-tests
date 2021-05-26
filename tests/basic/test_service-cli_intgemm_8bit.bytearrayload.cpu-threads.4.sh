#!/bin/bash

#####################################################################
# SUMMARY: service-cli with bytearray load capabilities
# AUTHOR: jerinphilip 
# TAGS: full, native
#####################################################################

set -eo pipefail;

BRT_INSTRUCTION=$( $BRT_TOOLS/detect-instruction.sh )
prefix=intgemm_8bit
ARGS=(
    -m $BRT_TEST_PACKAGE_EN_DE/model.intgemm.alphas.bin
    --vocabs 
        $BRT_TEST_PACKAGE_EN_DE/vocab.deen.spm 
        $BRT_TEST_PACKAGE_EN_DE/vocab.deen.spm
    --shortlist $BRT_TEST_PACKAGE_EN_DE/lex.s2t.bin 50 50
    --ssplit-mode paragraph
    --bytearray true
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
OUTFILE="service-cli-bytearray.$prefix.$BRT_INSTRUCTION.out"
${BRT_MARIAN}/app/service-cli "${ARGS[@]}" < ${BRT_DATA}/simple/bergamot.in > $OUTFILE

# Compare with output specific to hardware.
$BRT_TOOLS/diff.sh $OUTFILE service-cli.$prefix.$BRT_INSTRUCTION.expected > $prefix.$BRT_INSTRUCTION.diff
exit 0
