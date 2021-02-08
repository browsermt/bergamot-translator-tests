#!/usr/bin/env python3
# Usage: restore.py keys system_dir < system

import os
import sys

if __name__ == '__main__':
    if len(sys.argv) != 3:
      print("Usage: " + sys.argv[0] + " keys out_dir <system.txt")
      exit()

    keys = sys.argv[1]
    outdir = sys.argv[2]
    os.mkdir(outdir)
    reordered = {}
    with open(keys) as k:
      for line in k:
        name, index = line.strip().split('\t')
        index = int(index)
        if name not in reordered:
           reordered[name] = []
        entry = reordered[name]
        if len(entry) <= index:
           entry += [None] * (index + 1 - len(entry))
        got = sys.stdin.readline()
        if got == '':
            sys.stderr.write("Short stdin.\n")
            sys.exit(2)
        entry[index] = got
    if sys.stdin.readline() != '':
        sys.stderr.write("Excess lines in stdin.\n")
        sys.exit(1)
    for name, lines in reordered.items():
        with open(outdir + "/" + name, 'w') as f:
            for l in lines:
                 assert l is not None
                 f.write(l)
