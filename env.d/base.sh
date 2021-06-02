#!/bin/bash

export GEMM_PRECISION=int8shiftAlphaAll

COMMON_ARGS=(
    -m $BRT_TEST_PACKAGE_EN_DE/model.intgemm.alphas.bin
    --vocabs 
        $BRT_TEST_PACKAGE_EN_DE/vocab.deen.spm 
        $BRT_TEST_PACKAGE_EN_DE/vocab.deen.spm
    --alignment soft
    --beam-size 1
    --skip-cost
    --gemm-precision ${GEMM_PRECISION} 
    --max-length-break 1024
    --mini-batch-words 1024
    -w 128
)

function brt-file-args {
    BRT_FILE_ARGS=(
        "${COMMON_ARGS[@]}"
        --shortlist $BRT_TEST_PACKAGE_EN_DE/lex.s2t.bin 50 50
        --bytearray false
    )
    echo "${BRT_FILE_ARGS[@]}";
}

function brt-bytearray-args {
    BRT_BYTEARRAY_ARGS=(
        "${COMMON_ARGS[@]}"
        --shortlist $BRT_TEST_PACKAGE_EN_DE/lex.s2t.bin 50 50
        --bytearray true
    )
    echo "${BRT_BYTEARRAY_ARGS[@]}"
}

export BRT_FILE_ARGS=$(brt-file-args)
export BRT_BYTEARRAY_ARGS=$(brt-bytearray-args)

