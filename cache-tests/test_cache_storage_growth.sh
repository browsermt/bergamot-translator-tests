#!/bin/bash

# Usage (example on var): 
# MARIAN=../bergamot-translator/build TIMEOUT=45m BRT_THREADS=48 BRT_EXPECTED_MAXTIME=500 ./run_brt.sh speed-tests/test_wngt20_perf.sh
# 
# Uses the following environment variables additionally.
# TIMEOUT: 
#    Normal regression-tests have a timeout of 5m, however WNGT20 takes longer
#    even with many more cores.
# 
# BRT_THREADS:
#    Number of marian-worker threads to spawn on a test-machine.
#   
# BRT_EXPECTED_MAXTIME:
#   Parameter needs to be set with a reasonable value tuning for hardware.
#   Repeated development shouldn't compromise the existing speed.
# 
# Computes BLEU/performance on WNGT20 continuously to ensure no quality issues
# arise in continuous development.

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


INPUT_FILE="$BRT_DATA/wngt20/sources.shuf"
TAG="cache-growth.${THREADS}.cache.true"

CACHE_ARGS=(
    --model-config-paths "$BRT_TEST_PACKAGE_EN_DE/config.intgemm8bitalpha.yml.decoder.yml"
    --cpu-threads ${THREADS}  
    --cache-translations=1
)

${BRT_MARIAN}/bergamot-test-native --bergamot-mode test-cache-storage-growth "${CACHE_ARGS[@]}" \
    < $INPUT_FILE \
    > ${TAG}.translated.log \
    2> $TAG.log;
