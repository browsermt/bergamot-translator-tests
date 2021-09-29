#!/bin/bash

# Usage (example on var): 
# MARIAN=../bergamot-translator/build TIMEOUT=45m BRT_THREADS=48 BRT_EXPECTED_MAXTIME=500 ./run_brt.sh speed-tests/test_translate_edit_workflow.sh
# 
# Uses the following environment variables additionally.
# TIMEOUT: 
#    Normal regression-tests have a timeout of 5m, however WNGT20 takes longer
#    even with many more cores.
# 
# BRT_THREADS:
#    Number of marian-worker threads to spawn on a test-machine.
#
# Tests cache with a scenario where there are a lot of hits. This serves too purposes:
#
# 1. This is threading/cache intensive. Deadlocks, races and other issues of
# the sort will appear in this test.
# 2. Allows to compare how an edit use-case works with or without cache. Cache
# can provide speedups for outbound translation where people type continuously
# and update a textbox of translation corresponding realtime.
   

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
