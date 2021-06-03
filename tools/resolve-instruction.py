#!/usr/bin/env python3

"""
Prints environment update commands for a specific input instruction. As of now,
provides configuration for the following which are consistent.

  INTGEMM_CPUID
  BRT_INSTRUCTION
  MKL_ENABLE_INSTRUCTIONS

Default operation is autodetect, which resolves to the highest available
instruction on the hardware run.

Requires the `list_cpu_features` executable from
https://github.com/google/cpu_features, which provides a cross-platfrom CPU
detection. The JSON output from `list_cpu_features` is used to resolve the
highest amongst available instruction on the hardware optionally upto a user
specified instruction.
"""

import sys
import argparse
import subprocess as sp
import json

# BRT available instructions (due to INTGEMM), in order of decreasing
# preference.

available = [
    'avx512vnni', 
    'avx512bw',
    'avx2', 
    'avx',
    'ssse3', 
]

# INTGEMM uses the uppercase of the above.
INTGEMM_TABLE = { k: k.upper() for k in available }

# MKL has a limitation in SSSE3, where we instead choose SSE4_2.

MKL_TABLE = {
    "avx512vnni": "AVX512",
    "avx512bw": "AVX512",
    "avx2": "AVX2",
    "avx": "AVX",
    "ssse3": "SSE4_2",
}

def env_setup_commands(resolved):
    # avx codepath is same as SSSE3 for INTGEMM.
    instruction = "ssse3" if resolved == "avx" else resolved

    envvars = {
        "INTGEMM_CPUID" : INTGEMM_TABLE[instruction],
        "BRT_INSTRUCTION" : instruction,
        "MKL_ENABLE_INSTRUCTIONS" : MKL_TABLE[instruction]
    }
    
    commands = [
        'export {}={}'.format(key, value) for key, value in envvars.items()
    ]
    return ('\n'.join(commands))

def main(args):
    # Run `list_cpu_features` to obtain JSON output.
    proc = sp.run(args=[args.path, '--json'], stdout=sp.PIPE, stderr=sp.PIPE)
    output = proc.stdout.decode('utf-8').strip()
    data = json.loads(output, strict=False)

    # Check instructions common to flags, and those available to BRT (hardcoded here).
    instructions = list(set(data["flags"]).intersection(set(available)))

    # Find the top available instruction
    top = min(instructions, key=lambda x: available.index(x))

    def min_instruction(a, b):
        return a if available.index(a) > available.index(b) else b

    # If args.upto is specified, resolve instruction further.
    resolved = top if (args.upto not in available) else min_instruction(top, args.upto)

    print(env_setup_commands(resolved))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--path', type=str, required=True, help='Path to cpu_features executable')
    parser.add_argument('--upto', type=str, default=None, choices=available + ['auto'], help="Highest instruction to choose from")
    args = parser.parse_args()
    main(args)

