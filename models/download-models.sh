#!/bin/bash

URL="http://data.statmt.org/bergamot/models/deen/"
FILE="ende.student.tiny11.tar.gz"
OUTPUT_DIR="deen"

mkdir -p ${OUTPUT_DIR}
wget -c $URL/${FILE}
tar xf $FILE -C $OUTPUT_DIR/
rm $FILE
