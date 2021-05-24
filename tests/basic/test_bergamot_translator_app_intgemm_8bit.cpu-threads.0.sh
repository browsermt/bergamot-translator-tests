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
    -m $BRT_MODELS/deen/ende.student.tiny11/model.intgemm.alphas.bin
    --vocabs 
        $BRT_MODELS/deen/ende.student.tiny11/vocab.deen.spm 
        $BRT_MODELS/deen/ende.student.tiny11/vocab.deen.spm
    --ssplit-mode paragraph
    --check-bytearray false
    --beam-size 1
    --skip-cost
    --shortlist $BRT_MODELS/deen/ende.student.tiny11/lex.s2t 50 50
    --int8shiftAlphaAll
    --cpu-threads 0
    --max-length-break 1024
    --mini-batch-words 1024
    -w 128
)

# Generate output specific to hardware.
OUTFILE="bergamot.$prefix.$BRT_INSTRUCTION.out"
${BRT_MARIAN}/app/bergamot --bergamot-mode wasm "${ARGS[@]}" < ${BRT_DATA}/simple/bergamot.in > $OUTFILE

#This used to be provided via stdin: < ${BRT_DATA}/simple/bergamot.in  but the bergamot-translator-app doesn't accept stdin text
# Compare with output specific to hardware.
$BRT_TOOLS/diff.sh $OUTFILE bergamot.$prefix.$BRT_INSTRUCTION.expected > $prefix.$BRT_INSTRUCTION.diff
exit 0
