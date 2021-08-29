#!/bin/bash

#####################################################################
# SUMMARY: Run tests for service-cli
# AUTHOR: jerinphilip
# TAGS: full, native
#####################################################################

set -eo pipefail;

BRT_TEST_PACKAGE_EN_ET=${BRT_MODELS}/enet/enet.student.tiny11

echo ${BRT_TEST_PACKAGE_EN_ET}

QE_ARGS=(
    -m ${BRT_TEST_PACKAGE_EN_ET}/model.intgemm.alphas.bin
    --vocabs
        ${BRT_TEST_PACKAGE_EN_ET}/vocab.eten.spm
        ${BRT_TEST_PACKAGE_EN_ET}/vocab.eten.spm
    --ssplit-prefix-file
        ${BRT_TEST_PACKAGE_EN_DE}/nonbreaking_prefix.en
    --alignment soft
    --beam-size 1
    --gemm-precision ${GEMM_PRECISION}
    --max-length-break 1024
    --mini-batch-words 1024
    -w 128
    --quality ${BRT_TEST_PACKAGE_EN_ET}/quality_model.bin
)

# Generate output specific to hardware.
OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "quality_estimator_words")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "quality_estimator_words")

${BRT_MARIAN}/bergamot-test --bergamot-mode test-quality-estimator-words "${QE_ARGS[@]}" < ${BRT_DATA}/simple/bergamot/input_quality_estimator.txt > $OUTFILE

$BRT_TOOLS/diff.sh $OUTFILE $EXPECTED

OUTFILE=$BRT_DATA/simple/bergamot/$(brt_outfile "quality_estimator_scores")
EXPECTED=$BRT_DATA/simple/bergamot/$(brt_expected "quality_estimator_scores")

${BRT_MARIAN}/bergamot-test --bergamot-mode test-quality-estimator-scores "${QE_ARGS[@]}" < ${BRT_DATA}/simple/bergamot/input_quality_estimator.txt > $OUTFILE

$BRT_TOOLS/diff-nums.py -p 0.0001 $OUTFILE $EXPECTED

exit 0
