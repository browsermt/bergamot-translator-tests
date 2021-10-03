#!/bin/bash

# Usage (example on var): 
# MARIAN=../bergamot-translator/build TIMEOUT=45m BRT_THREADS=48 BRT_EXPECTED_MAXTIME=500 ./run_brt.sh speed-tests/test_cache_hparam.sh
# 
# Uses the following environment variables additionally.
# TIMEOUT: 
#    Normal regression-tests have a timeout of 5m, however WNGT20 takes longer
#    even with many more cores.
# 
# BRT_THREADS:
#    Number of marian-worker threads to spawn on a test-machine.
#   
# Just runs multiple runs on the hyperparameter cache-buckets, requested by
# @XapaJIaMnu during PR review. This runs on WNGT20 with BRT_THREADS number of
# threads. Reports time for each run between 1 thread and ${BRT_THREADS} in
# increments of 1.

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


INPUT_FILE="$BRT_DATA/wngt20/sources.shuf"


function benchmark-parameterized-by-cache {
    CACHE_ARG="$1"
    LOCAL_INPUT_FILE="$2"
    LOCAL_THREADS="$3"
    NUM_BUCKETS="$4"
    TAG="cache-hparam.${LOCAL_THREADS}.cache.${CACHE_ARG}.buckets.${NUM_BUCKETS}"

    CACHE_ARGS=(
        --model-config-paths "$BRT_TEST_PACKAGE_EN_DE/config.intgemm8bitalpha.yml.decoder.yml"
        --cpu-threads ${LOCAL_THREADS}  
        --cache-translations=${CACHE_ARG}
        --cache-buckets ${NUM_BUCKETS}
    )

    time ${BRT_MARIAN}/bergamot-test-native --bergamot-mode decoder "${CACHE_ARGS[@]}" < $LOCAL_INPUT_FILE > ${TAG}.translated.log 2> ${TAG}.log ;
    WALLTIME=$(tail -n1 -v ${TAG}.log | grep -o "[0-9\.]*s" | sed 's/s//g')
    echo "WallTime: $WALLTIME"
}


for NUM_BUCKETS in $(seq 1 1 ${BRT_THREADS}); do
    #echo ${NUM_BUCKETS}
    benchmark-parameterized-by-cache 1 $INPUT_FILE $THREADS $NUM_BUCKETS;
done;
