#!/usr/bin/env python3
"""
Patches a marian-compatible model config file with bergamot-compatible ones, with additional arguments such as:

    ssplit-prefix-file
    ssplit-mode

    ...
"""

import os
import yaml
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--config-path', type=str)
    parser.add_argument('--ssplit-prefix-file', type=str, required=True)
    args = parser.parse_args()
    data = None
    with open(args.config_path) as fp:
        data = yaml.load(fp)

    data.update({
        'ssplit-prefix-file': args.ssplit_prefix_file,
        'ssplit-mode': 'paragraph',
        'max-length-break': 128,
        'mini-batch-words': 1024,
    })

    with open(args.config_path + '.bergamot.yml', 'w') as ofp:
        print(yaml.dump(data, sort_keys=False), file=ofp)



