
#!/bin/bash

URL="http://data.statmt.org/heafield/wngt20/test/"

# Downloads the test-set of WNGT-20 data
FILES=(
    keys.xz
    ref-emea.xz
    ref-federal.xz
    ref-tatoeba.xz
    restore.py
    sources.shuf.xz
)

OUTPUT_DIR="wngt20"
mkdir -p ${OUTPUT_DIR};

for FILE in ${FILES[@]}
do
    wget -c "${URL}/${FILE}" -P ${OUTPUT_DIR}
    echo "Extracting ${FILE}" && unxz ${OUTPUT_DIR}/${FILE}
done;
