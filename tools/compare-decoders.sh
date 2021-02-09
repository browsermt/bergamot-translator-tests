#!/bin/bash

# This script runs the new replacement for marian-decoder through an executable
# created for bergamot-translator and marian-decoder under similar settings.
# Both use a mini-batch-words hyperparameter to construct batches.

if [ -z ${BERGAMOT_TRANSLATOR+x} ];
then
    echo "BERGAMOT_TRANSLATOR is not set, script cannot run";
    echo "Usage: BERGAMOT_TRANSLATOR=<path-to-bergamot-build> $0"
    exit 1
fi

# The following environment variables prevent any extra threads from being
# launched, intgemm internally handles these. This ensures no mixup of threads
# in marian-decoder or marian-decoder-new.

# OMP_NUM_THREADS:
#   If OMP_NUM_THREADS is set, it asks OMP runtime to spawn additional threads
#   (pthreads internally). But for this to happen, compile flags
#   should be enabled, which probably is not by default. 

export OMP_NUM_THREADS=1

# MKL_NUM_THREADS:
#   MKL_NUM_THREADS is a safety variable, it defaults to OMP_NUM_THREADS and is
#   thread safe. 

export MKL_NUM_THREADS=1


SCRIPT_DIR=`dirname $0`
BERGAMOT_MODELS="${SCRIPT_DIR}/../models"
BERGAMOT_DATA="${SCRIPT_DIR}/../data"

INPUT_FILE="$BERGAMOT_DATA/wngt20/sources.shuf"
MINI_BATCH_WORDS=1024

OUTPUT_DIR="${SCRIPT_DIR}/speed"
mkdir -p $OUTPUT_DIR

COMMON_ARGS=(
    -m $BERGAMOT_MODELS/deen/model.intgemm.alphas.bin 
    --vocabs 
        $BERGAMOT_MODELS/deen/vocab.deen.spm 
        ${BERGAMOT_MODELS}/deen/vocab.deen.spm 
    --beam-size 1 --skip-cost 
    --shortlist ${BERGAMOT_MODELS}/deen/lex.s2t.gz 50 50 
    --quiet --quiet-translation 
    --int8shiftAlphaAll 
    -w 128 
)

function run-service {
    # Launches app/marian-decoder-new, a cmdline to the replacement to marian-decoder built with Service.
    THREADS="$1"
    TAG="${OUTPUT_DIR}/cpu.mts.${THREADS}"
    MTS_ARGS=(
        --max-input-sentence-tokens $MINI_BATCH_WORDS --max-input-tokens $MINI_BATCH_WORDS 
        --ssplit-mode sentence --cpu-threads ${THREADS} 
        --log ${TAG}.log -o ${TAG}.translated
    )

    ${BERGAMOT_TRANSLATOR}/app/marian-decoder-new "${COMMON_ARGS[@]}" "${MTS_ARGS[@]}" < $INPUT_FILE ;
}

function run-marian-decoder {
    # Launches the marian-decode compiled with marian-project.
    THREADS="$1"
    TAG="${OUTPUT_DIR}/cpu.marian-decoder.${THREADS}"
    DECODER_ARGS=(
        --maxi-batch 1000000 --mini-batch-words $MINI_BATCH_WORDS 
        --maxi-batch-sort src
        --cpu-threads ${THREADS} 
        --log ${TAG}.log -o ${TAG}.translated
    )

    ${BERGAMOT_TRANSLATOR}/marian-decoder "${COMMON_ARGS[@]}" "${DECODER_ARGS[@]}" < $INPUT_FILE;

}

set -x;

# var, where this script is run when necessary has 80 cpus, but 48 is what
# provides an optimal runtime, based on a sweep. Beyond that the gains are not
# much. The graphs are therefore computed to collect runtime datapoints for 1
# thread to 48 threads.

THREADS=(48 40 32 24 16 8 4 2 1)
for THREAD in ${THREADS[@]}; do
    run-service ${THREAD}
    run-marian-decoder ${THREAD}
done;
