#!/bin/bash

set -eo pipefail;

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
    CACHE_FLAG=$1;
    CACHE_ARGS=(
        --model-config-paths "$BRT_TEST_PACKAGE_EN_DE/config.intgemm8bitalpha.yml.bergamot.yml"
        --cpu-threads ${THREADS}  
        --cache-translations=${CACHE_FLAG}
    )

    ${BRT_MARIAN}/bergamot-test-native --bergamot-mode test-benchmark-edit-workflow "${CACHE_ARGS[@]}" < ${INPUT_FILE} > ${TAG}.translated.log 2> ${TAG}.log ;
}

run-exp 1
run-exp 0
