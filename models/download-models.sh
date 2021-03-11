#!/bin/bash

URL="http://data.statmt.org/bergamot/models/deen"
MODEL="ende.student.tiny11"
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
