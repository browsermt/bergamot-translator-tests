#!/bin/bash

set -eo pipefail;

# Skip if requirements are not met
if [ ! $BRT_MARIAN_USE_MKL ]; then
    echo "Bergamot translator is not compiled with CPU" 1>&2
    exit 100
elif ! grep -q -e "avx" -e "ssse3" /proc/cpuinfo  ; then
    echo "Your CPU does not support AVX or SSSE3, which is required" 1>&2
    exit 100
fi

THREADS=${BRT_THREADS:-16}
EXPECTED_MAX_TIME=${BRT_EXPECTED_MAXTIME:-2500.00}

if [ `nproc` -lt 16 ]; then
  echo "Skipping, not enough cores to run this test in feasible time. At least 16 required"
  exit 100
fi;

if [ `nproc` -lt ${THREADS} ]; then
  echo "Skipping, hardware doesn't have enough CPUs to run ${THREADS} threads."
  exit 100
fi;


INPUT_FILE="$BRT_DATA/edit-samples/c10k.txt"

function run-exp {
    CACHE_ARG=$1;
    ADDITIONAL_ARGS=(
        --cpu-threads ${THREADS}
        --log cpu.edit-workflow.${THREADS}.cache.${CACHE_ARG}.log 
        --cache-translations=${CACHE_ARG}
    )

    ${BRT_MARIAN}/bergamot-test-native --bergamot-mode test-benchmark-edit-workflow $BRT_FILE_ARGS "${ADDITIONAL_ARGS[@]}" < ${INPUT_FILE} > ${TAG}.translated.log;
}

run-exp 0
run-exp 1
