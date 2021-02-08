#!/bin/bash

set -eo pipefail;

DIRS="$@"

for DIR in ${DIRS[@]}; do
    echo wmt10 wmt11 wmt13 wmt14 wmt15 wmt16 wmt17 wmt18 wmt19 federal emea tatoeba
    for t in wmt10 wmt11 wmt13 wmt14 wmt15 wmt16 wmt17 wmt18 wmt19; do 
        BLEU=$(cat $DIR/$t.sacre  | awk '{print $3;}');
        echo -n "$BLEU ";
    done;
    for c in federal emea tatoeba; do 
        BLEU=$(cat $DIR/$c.sacre  | awk '{print $3;}');
        echo -n "$BLEU ";
    done
    echo ""
done
