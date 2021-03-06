#!/usr/bin/env python3

"""
Converts sacrebleu into an assert for usage in a test-suite, with a few
hyperparameters to tweak per test-set. Usage is kept to similar to
diff-nums.py, which is inherited from marian-regression-tests, with a few
additional arguments.

Example usage:
    python3 approx-diff.py <output-file> <expected-output>    \
            --greater-than <bleu-threshold> 

Optionally, one can also switch to sentence-level BLEU score asserts and an
additional error rate, which can be useful to be tuned to per (output,
expected) pair based on the nature of the task.

    python3 approx-diff.py <output-file> <expected-output>    \
            --greater-than <bleu-threshold>  --sentence-level \
            --allow-error-rate <error-rate in [0.0, 1.0]>

This is intended as an approximate substitute for tools/diff.sh,
which is simply a redirect to the diff utility.  diff checks for exact matches,
which makes the tests susceptible to failure when output translations differ
out of floating point arithmetic differences.
"""

import sys
import argparse
import sacrebleu

def parse_user_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("file1", type=str)
    parser.add_argument("file2", type=str)
    parser.add_argument("-o", "--output", type=argparse.FileType('w'), metavar="FILE", default=sys.stdout)
    parser.add_argument("-e", "--allow-error-rate", type=float, metavar="FLOAT", default=0)
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

    def load_non_empty_lines(fpath):
        content = None
        with open(fpath) as fp:
            content = fp.read().splitlines()
            nonEmpty = lambda x: len(x) > 0
            content = list(filter(nonEmpty, content))
        return content

    system = load_non_empty_lines(args.file1)
    refs = [ load_non_empty_lines(args.file2) ]

    faults = 0
    max_allowed_faults = 0
    if args.sentence_level:
        max_allowed_faults = args.allow_error_rate*len(system)
        for i, (output, *references) in enumerate(zip(system, *refs), 1):
            score = metric.sentence_score(output, references)
            condition = score.score > args.greater_than
            if (not condition):
                faults += 1
                print("In line {}, {} <= {}; Fault {}".format(i, score.score, args.greater_than, faults))

    else:
        score = metric.corpus_score(system, refs)
        condition = score.score > args.greater_than
        if (not condition):
            print("Corpus BLEU, {} <= {}".format(i, score.score, args.greater_than))
            faults += 1

    print("faults / max_allowed among {} samples = {} / {} ".format(len(system), faults, max_allowed_faults))
    retcode = 0 if faults <= max_allowed_faults else 1
    exit(retcode)


if __name__ == '__main__':
    args = parse_user_args()
    main(args)
