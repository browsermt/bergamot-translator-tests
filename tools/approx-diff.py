#!/usr/bin/env python3

import sys
import argparse
import sacrebleu

def parse_user_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("file1", type=str)
    parser.add_argument("file2", type=str)
    parser.add_argument("-o", "--output", type=argparse.FileType('w'), metavar="FILE", default=sys.stdout)
    parser.add_argument("-p", "--precision", type=float, metavar="FLOAT", default=0.001)
    parser.add_argument("-n", "--allow-n-diffs", type=int, metavar="INT", default=0)
    # parser.add_argument("-s", "--separate", type=str, metavar="STRING")
    parser.add_argument("-a", "--abs", action="store_true")
    parser.add_argument("--numpy", action="store_true")
    parser.add_argument("-q", "--quiet", action="store_true")

    # BLEU related arguments: These are required to use sacreBleu
    parser.add_argument('--smooth-method', '-s', choices=sacrebleu.metrics.METRICS['bleu'].SMOOTH_DEFAULTS.keys(), default='exp',
                            help='smoothing method: exponential decay (default), floor (increment zero counts), add-k (increment num/denom by k for n>1), or none')
    parser.add_argument('--smooth-value', '-sv', type=float, default=None,
                         help='The value to pass to the smoothing technique, only used for floor and add-k. Default floor: {}, add-k: {}.'.format(
                         sacrebleu.metrics.METRICS['bleu'].SMOOTH_DEFAULTS['floor'], sacrebleu.metrics.METRICS['bleu'].SMOOTH_DEFAULTS['add-k']))
    parser.add_argument('--tokenize', '-tok', choices=sacrebleu.tokenizers.TOKENIZERS.keys(), default='13a',
      help='Tokenization method to use for BLEU. If not provided, defaults to `zh` for Chinese, `mecab` for Japanese and `mteval-v13a` otherwise.')
    parser.add_argument('-lc', action='store_true', default=False, help='Use case-insensitive BLEU (default: False)')
    parser.add_argument('--force', default=False, action='store_true',
                            help='insist that your tokenized input is actually detokenized')


    # Print args
    parser.add_argument('--score-only', '-b', default=False, action='store_true',
                            help='output only the BLEU score')
    parser.add_argument('--width', '-w', type=int, default=1,
                            help='floating point width (default: %(default)s)')

    parser.add_argument('--sentence-level', '-sl', default=False, action='store_true',
                            help='Compute sentence-level assertions')
    parser.add_argument('--greater-than', '-gt', default=40, type=float)

    return parser.parse_args()
    


def main(args):
    metric = sacrebleu.metrics.METRICS['bleu'](args)

    def loadNonEmptyLines(fpath):
        content = None
        with open(fpath) as fp:
            content = fp.read().splitlines()
            nonEmpty = lambda x: len(x) > 0
            content = list(filter(nonEmpty, content))
        return content

    system = loadNonEmptyLines(args.file1)
    refs = [ loadNonEmptyLines(args.file2) ]

    faults = 0
    if args.sentence_level:
        for i, (output, *references) in enumerate(zip(system, *refs), 1):
            score = metric.sentence_score(output, references)
            condition = score.score > args.greater_than
            if (not condition):
                faults += 1
                print("In line {}, {} <= {}; Fault {}".format(i, score.score, args.greater_than, faults))


    else:
        score = metric.corpus_score(system, refs)
        if (not condition):
            print("Corpus BLEU, {} <= {}".format(i, score.score, args.greater_than))
            faults += 1

    retcode = 0 if faults <= args.allow_n_diffs else 1
    exit(retcode)


if __name__ == '__main__':
    args = parse_user_args()
    main(args)
