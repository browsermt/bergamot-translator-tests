#!/bin/bash

# Model download

set -euo pipefail

function download-archive {
    URL=$1
    MODEL=$2
    FILE="${MODEL}.tar.gz"
    OUTPUT_DIR=$3
    mkdir -p ${OUTPUT_DIR}
    if [ -f "$FILE" ]; then
        echo "File ${FILE} already downloaded."
    else
        echo "Downloading ${FILE}"
        wget --quiet --continue $URL/${FILE}
        tar xf $FILE -C $OUTPUT_DIR/
        # wasm build doesnt support zipped input 
        ( cd ${OUTPUT_DIR}/${MODEL} && if [ -f lex.s2t.gz ]; then gunzip -f lex.s2t.gz; fi )
    fi
}

function download-ssplit-prefix-file {
    SLANG=$1
    OUTPUT_DIR=$2
    MODEL=$3
    wget "https://raw.githubusercontent.com/ugermann/ssplit-cpp/master/nonbreaking_prefixes/nonbreaking_prefix.${SLANG}" \
        -O "${OUTPUT_DIR}/${MODEL}/nonbreaking_prefix.${SLANG}" || exit 1
    test -f "${OUTPUT_DIR}/${MODEL}/nonbreaking_prefix.${SLANG}" || exit 1
}

# de-en
URL="http://data.statmt.org/bergamot/models/deen"
MODEL="ende.student.tiny.for.regression.tests"
OUTPUT_DIR="deen"

download-archive $URL $MODEL $OUTPUT_DIR

test -f ${OUTPUT_DIR}/${MODEL}/vocab.deen.spm || exit 1
test -f ${OUTPUT_DIR}/${MODEL}/model.intgemm.alphas.bin || exit 1
test -f ${OUTPUT_DIR}/${MODEL}/lex.s2t || exit 1

download-ssplit-prefix-file en $OUTPUT_DIR $MODEL
python3 ../tools/patch-marian-for-bergamot.py --config-path ${OUTPUT_DIR}/$MODEL/config.intgemm8bitalpha.yml --ssplit-prefix-file nonbreaking_prefix.en
python3 ../tools/patch-marian-for-bergamot.py --config-path ${OUTPUT_DIR}/$MODEL/config.yml --ssplit-prefix-file nonbreaking_prefix.en


# One additional configuration for decoder
python3 ../tools/patch-marian-for-bergamot.py --config-path ${OUTPUT_DIR}/$MODEL/config.intgemm8bitalpha.yml \
    --ssplit-mode sentence \
    --max-length-break 1024 --mini-batch-words 2048 \
    --output-suffix "decoder.yml"

# en->es

URL="http://data.statmt.org/bergamot/models/esen/"
MODEL="enes.student.tiny11"
OUTPUT_DIR="enes"

download-archive $URL $MODEL $OUTPUT_DIR
download-ssplit-prefix-file en $OUTPUT_DIR $MODEL
python3 ../tools/patch-marian-for-bergamot.py --config-path ${OUTPUT_DIR}/$MODEL/config.intgemm8bitalpha.yml --ssplit-prefix-file nonbreaking_prefix.en

# en->es

URL="http://data.statmt.org/bergamot/models/esen/"
MODEL="esen.student.tiny11"
OUTPUT_DIR="esen"

download-archive $URL $MODEL $OUTPUT_DIR
download-ssplit-prefix-file es $OUTPUT_DIR $MODEL
python3 ../tools/patch-marian-for-bergamot.py --config-path ${OUTPUT_DIR}/$MODEL/config.intgemm8bitalpha.yml --ssplit-prefix-file nonbreaking_prefix.es

URL="http://data.statmt.org/bergamot/models/eten"
MODEL="enet.student.tiny11"
OUTPUT_DIR="enet"

download-archive $URL $MODEL $OUTPUT_DIR
download-ssplit-prefix-file en $OUTPUT_DIR $MODEL
wget https://raw.githubusercontent.com/browsermt/students/master/eten/enet.quality.lr/quality_model.bin -O ${OUTPUT_DIR}/${MODEL}/quality_model.bin || exit 1
python3 ../tools/patch-marian-for-bergamot.py --config-path ${OUTPUT_DIR}/$MODEL/config.intgemm8bitalpha.yml --ssplit-prefix-file nonbreaking_prefix.en --quality quality_model.bin
