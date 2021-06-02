#!/usr/bin/env python3

import sys
import argparse
import subprocess as sp
import json

available = [
    'avx512vnni', 
    'avx512bw',
    'avx2', 
    'avx',
    'ssse3', 
]

INTGEMM_TABLE = { k: k.upper() for k in available }

MKL_TABLE = {
    "avx512vnni": "AVX512",
    "avx512bw": "AVX512",
    "avx2": "AVX2",
    "avx": "AVX",
    "ssse3": "SSE4_2",
}

def env_setup_commands(resolved):
    instruction = "ssse3" if resolved == "avx" else resolved
    envvars = {}
    envvars["INTGEMM_CPUID"] = INTGEMM_TABLE[instruction]
    envvars["BRT_INSTRUCTION"] = instruction
    envvars["MKL_ENABLE_INSTRUCTIONS"] = MKL_TABLE[instruction]
    
    commands = [
        'export {}={}'.format(key, value) for key, value in envvars.items()
    ]
    return ('\n'.join(commands))

def main(args):
    proc = sp.run(args=[args.path, '--json'], capture_output=True)
    output = proc.stdout.decode('utf-8').strip()
    data = json.loads(output, strict=False)
    instructions = list(set(data["flags"]).intersection(set(available)))
    instructions = sorted(instructions, key=lambda x: available.index(x))

    def min_instruction(a, b):
        return a if available.index(a) > available.index(b) else b


    top, *rest = instructions
    resolved = top if (args.upto not in available) else min_instruction(top, args.upto)
    # print(resolved)
    print(env_setup_commands(resolved))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--path', type=str, required=True, help='Path to cpu_features executable')
    parser.add_argument('--upto', type=str, default=None, choices=available + ['auto'], help="Highest instruction to choose from")
    args = parser.parse_args()
    main(args)

