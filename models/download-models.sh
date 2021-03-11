#!/bin/bash

URL="http://data.statmt.org/bergamot/models/deen"
FILE="ende.student.tiny11.tar.gz"
OUTPUT_DIR="deen"

mkdir -p ${OUTPUT_DIR}

if [ -f "$FILE" ]; then
    echo "File ${FILE} already downloaded."
else
    wget --quiet --continue $URL/${FILE}
    tar xf $FILE -C $OUTPUT_DIR/
    # wasm build doesnt support zipped input 
    ( cd models/deen/ende.student.tiny11 && gunzip lex.s2t.gz )
fi
