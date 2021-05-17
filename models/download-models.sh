#!/bin/bash

URL="http://data.statmt.org/bergamot/models/deen"
MODEL="ende.student.tiny.for.regression.tests"
FILE="${MODEL}.tar.gz"
OUTPUT_DIR="deen"

mkdir -p ${OUTPUT_DIR}

if [ -f "$FILE" ]; then
    echo "File ${FILE} already downloaded."
else
    echo "Downloading ${FILE}"
    wget --quiet --continue $URL/${FILE}
    tar xf $FILE -C $OUTPUT_DIR/
    # wasm build doesnt support zipped input 
    ( cd ${OUTPUT_DIR}/${MODEL} && gunzip -f lex.s2t.gz )
fi

test -f ${OUTPUT_DIR}/${MODEL}/vocab.deen.spm || exit 1
test -f ${OUTPUT_DIR}/${MODEL}/model.intgemm.alphas.bin || exit 1
test -f ${OUTPUT_DIR}/${MODEL}/lex.s2t || exit 1

