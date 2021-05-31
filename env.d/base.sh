#!/bin/bash

function detect-max-instruction {
    BRT_INSTRUCTION=''

    CPU_FEATURES_OUTPUT=cpu.features.log
    $BRT_TOOLS/cpu-features/build/list_cpu_features > $CPU_FEATURES_OUTPUT

    # Skip if requirements are not met
    if ! grep -q -e "avx" -e "ssse3" $CPU_FEATURES_OUTPUT; then
        echo "Your CPU does not support AVX* or SSSE3, which is required" 1>&2
        exit 100
    fi


    # Outputs differ on CPUs supporting AVX AVX2 or AVX512
    BRT_INSTRUCTION=avx
    if grep -q "avx512vnni" $CPU_FEATURES_OUTPUT ; then
        BRT_INSTRUCTION=avx512vnni
    elif grep -q "avx512" $CPU_FEATURES_OUTPUT ; then
        BRT_INSTRUCTION=avx512
    elif grep -q "avx2" $CPU_FEATURES_OUTPUT ; then
        BRT_INSTRUCTION=avx2
    elif grep -q "ssse3" $CPU_FEATURES_OUTPUT; then
        BRT_INSTRUCTION=ssse3
    fi

    echo $BRT_INSTRUCTION
}


function detect-env-instruction {
    echo "INTGEMM_CPUID=$INTGEMM_CPUID" 1>&2 ;
    if [[ "$INTGEMM_CPUID" == "AVX512VNNI" ]];
    then
        echo "avx512vnni";
    elif [[ "$INTGEMM_CPUID" == "AVX512BW" ]]
    then
        echo "avx512";
    elif [[ "$INTGEMM_CPUID" == "AVX2" ]]
    then
        echo "avx2";
    elif [[ "$INTGEMM_CPUID" == "SSSE3" ]]
    then
        echo "ssse3";
    else
        echo $(detect-max-instruction)
    fi
}

export GEMM_PRECISION=int8shiftAlphaAll
export BRT_INSTRUCTION=$(detect-env-instruction)

COMMON_ARGS=(
    -m $BRT_TEST_PACKAGE_EN_DE/model.intgemm.alphas.bin
    --vocabs 
        $BRT_TEST_PACKAGE_EN_DE/vocab.deen.spm 
        $BRT_TEST_PACKAGE_EN_DE/vocab.deen.spm
    --alignment soft
    --beam-size 1
    --skip-cost
    --gemm-precision ${GEMM_PRECISION} 
    --max-length-break 1024
    --mini-batch-words 1024
    -w 128
)

function brt-file-args {
    BRT_FILE_ARGS=(
        "${COMMON_ARGS[@]}"
        --shortlist $BRT_TEST_PACKAGE_EN_DE/lex.s2t.bin 50 50
        --bytearray false
    )
    echo "${BRT_FILE_ARGS[@]}";
}

function brt-bytearray-args {
    BRT_BYTEARRAY_ARGS=(
        "${COMMON_ARGS[@]}"
        --shortlist $BRT_TEST_PACKAGE_EN_DE/lex.s2t.bin 50 50
        --bytearray true
    )
    echo "${BRT_BYTEARRAY_ARGS[@]}"
}

export BRT_FILE_ARGS=$(brt-file-args)
export BRT_BYTEARRAY_ARGS=$(brt-bytearray-args)

