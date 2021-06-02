#!/bin/bash

data=$1
precision="int8shiftAlphaAll"

for arch in avx2 avx512bw avx512vnni; do
    dir="$data/$precision/$arch"
    find "$dir" -iname "*.out" | sed 's/\(.*\)\.out$/cp \1.out \1.expected/' | xargs -I% echo %
done

