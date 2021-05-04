#!/bin/bash

# Skip if requirements are not met
if [ ! $BRT_MARIAN_MKL_FOUND ]; then
    echo "Bergamot translator is not compiled with MKL" 1>&2
    exit 100
fi
