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
    parser.add_argument('--ssplit-prefix-file', type=str, required=False, default=None)
    parser.add_argument('--ssplit-mode', type=str, required=False, default='paragraph')
    parser.add_argument('--quality', type=str, required=False, default='')
    parser.add_argument('--max-length-break', type=int, required=False, default=128)
    parser.add_argument('--mini-batch-words', type=int, required=False, default=1024)
    parser.add_argument('--output-suffix', type=str, required=False, default="bergamot.yml")

    args = parser.parse_args()
    data = None
    with open(args.config_path) as fp:
        data = yaml.load(fp, Loader=yaml.FullLoader)

    data.update({
        'ssplit-mode': args.ssplit_mode,
        'max-length-break': args.max_length_break,
        'mini-batch-words': args.mini_batch_words,
        'alignment': 'soft', 
        'max-length-factor': 2.0,
    })

    if args.ssplit_prefix_file:
        data.update({
            'ssplit-prefix-file': args.ssplit_prefix_file,
        })

    if args.quality:
        data.update({
            'quality': args.quality, 
            'skip-cost': False
        })

    with open(args.config_path + '.' + args.output_suffix, 'w') as ofp:
        print(yaml.dump(data, sort_keys=False), file=ofp)



