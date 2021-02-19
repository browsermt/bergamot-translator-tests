#!/bin/bash

if [ -z ${BERGAMOT_TRANSLATOR+x} ];
then
    echo "BERGAMOT_TRANSLATOR is not set, script cannot run";
    echo "Usage: BERGAMOT_TRANSLATOR=<path-to-bergamot-build> $0"
    exit 1
fi

set -x;
set -eo pipefail;

SCRIPT_DIR=`dirname $0`
BERGAMOT_MODELS="${SCRIPT_DIR}/../models"
BERGAMOT_DATA="${SCRIPT_DIR}/../data"
THREADS=48
LOGDIR="batch-logs"
mkdir -p $LOGDIR


COMMON_ARGS=(
    -m ${BERGAMOT_MODELS}/deen/model.intgemm.alphas.bin
    --vocabs
        ${BERGAMOT_MODELS}/deen/vocab.deen.spm
        ${BERGAMOT_MODELS}/deen/vocab.deen.spm
    --beam-size 1 --skip-cost 
    --shortlist ${BERGAMOT_MODELS}/deen/lex.s2t.gz 50 50 
    --quiet --quiet-translation --int8shiftAlphaAll -w 128 
    --cpu-threads $THREADS
    --mini-batch-words 1024
)

INPUT_FILE=$BERGAMOT_DATA/wngt20/sources.shuf
test -f ${INPUT_FILE}

function run-service {
    RUNTIME_ARGS=(
        --maxi-batch $1
        --log $LOGDIR/run.service.$1.log -o $LOGDIR/run.service.$1.translated.log
    )
    LOCAL_ARGS=(
        --max-length-break 1024  --ssplit-mode sentence
    )
    $BERGAMOT_TRANSLATOR/app/concurrent-test-app "${COMMON_ARGS[@]}" "${LOCAL_ARGS[@]}" ${RUNTIME_ARGS[@]}< $INPUT_FILE;
}

function run-marian-decoder {
    RUNTIME_ARGS=(
        --maxi-batch $1
        --log $LOGDIR/run.marian-decoder.$1.log -o $LOGDIR/run.marian-decoder.$1.translated.log
    )
    LOCAL_ARGS=(
        --mini-batch 1
        --maxi-batch-sort src
    )

    $BERGAMOT_TRANSLATOR/marian-decoder "${COMMON_ARGS[@]}" "${LOCAL_ARGS[@]}" "${RUNTIME_ARGS[@]}" < $INPUT_FILE;
}

# MAXI_BATCHES=(10000 5000 2500 1000 500 200 100 50 25 10)
MAXI_BATCHES=(10)
for MAXI_BATCH in ${MAXI_BATCHES[@]}; do
    run-service $MAXI_BATCH
    run-marian-decoder $MAXI_BATCH
done;
