#!/bin/bash

set -eo pipefail;

# Skip if requirements are not met
if [ ! $BRT_MARIAN_USE_MKL ]; then
    echo "Bergamot translator is not compiled with CPU" 1>&2
    exit 100
elif ! grep -q -e "avx" -e "ssse3" /proc/cpuinfo ; then
    echo "Your CPU does not support AVX or SSSE3, which is required" 1>&2
    exit 100
fi

# Outputs differ on CPUs supporting AVX AVX2 or AVX512
suffix=avx
if grep -q "avx512_vnni" /proc/cpuinfo; then
    suffix=avx512_vnni
elif grep -q "avx512" /proc/cpuinfo; then
    suffix=avx512
elif grep -q "avx2" /proc/cpuinfo; then
    suffix=avx2
elif grep -q "ssse3" /proc/cpuinfo; then
    suffix=ssse3
fi

prefix=intgemm_8bit
ARGS=(
    -m $BRT_MODELS/deen/ende.student.tiny11/model.intgemm.alphas.bin
    --vocabs 
        $BRT_MODELS/deen/ende.student.tiny11/vocab.deen.spm 
        $BRT_MODELS/deen/ende.student.tiny11/vocab.deen.spm
    --ssplit-mode paragraph
    --beam-size 1
    --skip-cost
    --shortlist $BRT_MODELS/deen/ende.student.tiny11/lex.s2t.bin 50 50
    --int8shiftAlphaAll
    --cpu-threads 4
    --max-length-break 1024
    --mini-batch-words 1024
    -w 128
)

# Generate output specific to hardware.
OUTFILE="service-cli-bytearray.$prefix.$suffix.out"
${BRT_MARIAN}/app/service-cli-bytearray "${ARGS[@]}" < ${BRT_DATA}/simple/bergamot.in > $OUTFILE

# Compare with output specific to hardware.
$BRT_TOOLS/diff.sh $OUTFILE service-cli.$prefix.$suffix.expected > $prefix.$suffix.diff
exit 0
