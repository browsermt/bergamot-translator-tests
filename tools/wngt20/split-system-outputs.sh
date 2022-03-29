#!/bin/bash

set -eo pipefail;

FOLDER="$1"
WNGT_DATA="$2"

SACREBLEU="python3 -m sacrebleu" 

for c in federal emea tatoeba; do 
    for i in $FOLDER/$c; do 
        echo $SACREBLEU $WNGT_DATA/ref-$c \< $i \> $i.sacre; 
        $SACREBLEU $WNGT_DATA/ref-$c < $i > $i.sacre; 
    done; 
done;

for t in wmt10 wmt11 wmt13 wmt14 wmt15 wmt16 wmt17 wmt18 wmt19; do 
    echo $SACREBLEU -t $t -l en-de \< $FOLDER/$t \> $FOLDER/$t.sacre; 
    $SACREBLEU -t $t -l en-de < $FOLDER/$t > $FOLDER/$t.sacre; 
done

