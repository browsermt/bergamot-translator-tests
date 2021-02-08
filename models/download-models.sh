#!/bin/bash

URL="http://data.statmt.org/bergamot/models/deen"
FILE="ende.student.tiny11.tar.gz"
OUTPUT_DIR="deen"

mkdir -p ${OUTPUT_DIR}

if [ -f "$FILE" ]; then
    echo "File already downloaded."
else
    wget --quiet --continue $URL/${FILE}
    tar xf $FILE -C $OUTPUT_DIR/
fi
