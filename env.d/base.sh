#!/bin/bash

# Sets up some basic environment for BRTS.


# In all our tests, we use --gemm-precision int8shiftAlphaAll. The outputs vary
# with change in this precision (perhaps to int8shift or int8) and is
# parameterized using the GEMM_PRECISION environment variable, available to all
# BRT shell scripts.

export GEMM_PRECISION=int8shiftAlphaAll


# Common args configured for bergamot-translator. Grouping these here prevents
# having to repeat and possible inconsitency over several scripts.

NATIVE_ARGS=(
    --model-config-paths "$BRT_TEST_PACKAGE_EN_DE/config.intgemm8bitalpha.yml.bergamot.yml"
    --cpu-threads 4 
)

# WASM does not have the cpu-threads argument.
WASM_ARGS=(
    --model-config-paths "$BRT_TEST_PACKAGE_EN_DE/config.intgemm8bitalpha.yml.bergamot.yml"
    --bytearray # WASM always expected to use the byte-array path
)


COMMON_EN_ET_ARGS=(
    --model-config-paths "$BRT_TEST_PACKAGE_EN_ET/config.intgemm8bitalpha.yml.bergamot.yml"
    --cpu-threads 4
)

# Shortlist differs in filename when using bytearray or files.
# We support both modes bytearray format and also files. 

export BRT_NATIVE_ARGS=$(echo "${NATIVE_ARGS[@]}")
export BRT_WASM_ARGS=$(echo "${WASM_ARGS[@]}")
export BRT_EN_ET_ARGS=$(echo "${COMMON_EN_ET_ARGS[@]}")

