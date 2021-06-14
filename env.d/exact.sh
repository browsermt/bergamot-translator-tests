#!/bin/bash

function brt_outfile {
    TEST_NAME=$1
    echo "outputs/${GEMM_PRECISION}/${BRT_INSTRUCTION}/${TEST_NAME}.out"
}

function brt_expected {
    TEST_NAME=$1
    echo "outputs/${GEMM_PRECISION}/${BRT_INSTRUCTION}/${TEST_NAME}.expected"
}

export -f brt_outfile
export -f brt_expected
