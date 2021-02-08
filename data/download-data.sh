#!/bin/bash

URL="http://data.statmt.org/heafield/wngt20/test"

# Downloads the test-set of WNGT-20 data
XZ_FILES=(
    keys
    ref-emea
    ref-federal
    ref-tatoeba
    sources.shuf
)

OUTPUT_DIR="wngt20"
mkdir -p ${OUTPUT_DIR};

for FILE in ${XZ_FILES[@]}
do
    if test -f "${OUTPUT_DIR}/${FILE}"; then
      echo "File exists, not redownloading";
    else
      wget --quiet --continue "${URL}/${FILE}.xz" -P ${OUTPUT_DIR}
      echo "Extracting ${FILE}.xz" && unxz ${OUTPUT_DIR}/${FILE}.xz
    fi
done;
