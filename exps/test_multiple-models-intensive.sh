#!/bin/bash

ARGS=(
    --model-config-paths 
        "$BRT_TEST_PACKAGE_EN_ES/config.intgemm8bitalpha.yml.bergamot.yml" 
        "$BRT_TEST_PACKAGE_EN_DE/config.intgemm8bitalpha.yml.bergamot.yml" 
        --cpu-threads 2
)

$BRT_MARIAN/tests/async --bergamot-mode test-multimodels-intensive ${ARGS[@]} < $BRT_DATA/wngt20/sources.shuf.1k
