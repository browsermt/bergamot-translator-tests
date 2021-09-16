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
    --model-config-paths "$BRT_TEST_PACKAGE_EN_DE/config.intgemm8bitalpha.yml.bergamot.yml"
    --cpu-threads 4 
)

BRT_TEST_PACKAGE_EN_ET=${BRT_MODELS}/enet/enet.student.tiny11

COMMON_EN_ET_ARGS=(
    -m ${BRT_TEST_PACKAGE_EN_ET}/model.intgemm.alphas.bin
    --vocabs
        ${BRT_TEST_PACKAGE_EN_ET}/vocab.eten.spm
        ${BRT_TEST_PACKAGE_EN_ET}/vocab.eten.spm
    --ssplit-prefix-file
        ${BRT_TEST_PACKAGE_EN_DE}/nonbreaking_prefix.en
    --alignment soft
    --beam-size 1
    --gemm-precision ${GEMM_PRECISION}
    --max-length-break 1024
    --mini-batch-words 1024
    -w 128
    --quality ${BRT_TEST_PACKAGE_EN_ET}/quality_model.bin
)

# Shortlist differs in filename when using bytearray or files.
# We support both modes bytearray format and also files. 

function brt-file-args {
    BRT_FILE_ARGS=(
        "${COMMON_ARGS[@]}" 
        # --bytearray false
    )
    echo "${BRT_FILE_ARGS[@]}";
}

function brt-bytearray-args {
    BRT_BYTEARRAY_ARGS=(
        "${COMMON_ARGS[@]}" --bytearray
    )
    echo "${BRT_BYTEARRAY_ARGS[@]}"
}

export BRT_FILE_ARGS=$(brt-file-args)
export BRT_BYTEARRAY_ARGS=$(brt-bytearray-args)
export BRT_EN_ET_ARGS=$( echo "${COMMON_EN_ET_ARGS[@]}")

