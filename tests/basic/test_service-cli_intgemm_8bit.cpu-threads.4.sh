#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip 
# TAGS: full
#####################################################################

set -eo pipefail;

BRT_INSTRUCTION=$( $BRT_TOOLS/detect-instruction.sh )
prefix=intgemm_8bit

ARGS=(
    -m $BRT_MODELS/deen/ende.student.tiny11/model.intgemm.alphas.bin
    --vocabs 
        $BRT_MODELS/deen/ende.student.tiny11/vocab.deen.spm 
        $BRT_MODELS/deen/ende.student.tiny11/vocab.deen.spm
    --ssplit-mode paragraph
    --alignment soft
    --beam-size 1
    --skip-cost
    --shortlist $BRT_MODELS/deen/ende.student.tiny11/lex.s2t 50 50
    --int8shiftAlphaAll
    --cpu-threads 4
    --max-length-break 1024
    --mini-batch-words 1024
    -w 128
)

# Generate output specific to hardware.
OUTFILE="service-cli.$prefix.$BRT_INSTRUCTION.out"
${BRT_MARIAN}/app/service-cli "${ARGS[@]}" < ${BRT_DATA}/simple/bergamot.in > $OUTFILE

# Compare with output specific to hardware.
$BRT_TOOLS/diff.sh $OUTFILE service-cli.$prefix.$BRT_INSTRUCTION.expected > $prefix.$BRT_INSTRUCTION.diff
exit 0
