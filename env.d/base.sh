#!/bin/bash

# Sets up some basic environment for BRTS.


# In all our tests, we use --gemm-precision int8shiftAlphaAll. The outputs vary
# with change in this precision (perhaps to int8shift or int8) and is
# parameterized using the GEMM_PRECISION environment variable, available to all
# BRT shell scripts.

export GEMM_PRECISION=int8shiftAlphaAll


# Common args configured for bergamot-translator. Grouping these here prevents
# having to repeat and possible inconsitency over several scripts.

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

# Shortlist differs in filename when using bytearray or files.
# We support both modes bytearray format and also files. 

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

