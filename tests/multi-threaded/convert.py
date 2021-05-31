#!/bin/python

import sys
import os


def transform(s):
    name, intgemm, arch, _ext = s.split('.')
    arch = 'avx512vnni' if arch == 'avx512_vnni' else arch
    return os.path.join('expected', 'int8shiftAlphaAll', arch, 'bergamot.{}.out'.format(name))


if __name__ == '__main__':
    sources = sys.stdin.read().splitlines()
    targets = list(map(transform, sources))

    for src, tgt in zip(sources, targets):
        print('mv {} {}'.format(src, tgt))
