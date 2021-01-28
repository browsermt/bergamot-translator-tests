#!/bin/bash

set -e;

ARGS=(
    -m $BRT_MODELS/deen/model.intgemm.alphas.bin
    --vocabs 
        $BRT_MODELS/deen/vocab.deen.spm 
        $BRT_MODELS/deen/vocab.deen.spm
    --ssplit-mode paragraph
    --beam-size 1
    --skip-cost
    --shortlist $BRT_MODELS/deen/lex.s2t.gz 50 50
    --int8shiftAlphaAll
    --cpu-threads 4
    --max-input-sentence-tokens 100
    --max-input-tokens 1024
    -w 128
    --quiet 
)

${BRT_MARIAN}/app/bergamot-translator-app "${ARGS[@]}" < ${BRT_DATA}/simple/bergamot.in > bergamot.out
diff -bsq bergamot.out bergamot.expected
exit $?
