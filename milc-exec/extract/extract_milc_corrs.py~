#!/usr/bin/env python

# Andrew Lytle
# March 2015

import os
import re
import sys
from multiprocessing import Pool
from time import time

REGEX = re.compile('correlator_key:')  # Pattern signaling end of header.
T = 64

def sort_argv(argv):
    "Sort arguments in *.cfg_src by cfg then src."
    def sort_fun(arg):
        arg = os.path.basename(arg)  # Remove path.

        arg = arg.split('.')[2]

        cfg = arg.split('_')[0]
        src = ( arg.split('_')[1] ).split('t')[-1]

        return (cfg, src)

    return sorted(argv, key=sort_fun)

def remove_headers(lines):
    "Lines corresponding to correlation functions."
    result = []
    for i, line in enumerate(lines):
        if REGEX.match(line):
            # Skip "..." line after the match.
            result.append(lines[i+2:i+2+T])
    return result

def real_part(lines):
    "Real part of correlation functions."
    return [line.split()[1] for line in lines]

def extract(fname):
    with open(fname, 'r') as f:
        lines = remove_headers(f.readlines())
        nums = map(real_part, lines)
    return nums

def write_corr(corrs, batch):
    for corr in corrs:
        for num in corr[batch]:
            sys.stdout.write(num)
            sys.stdout.write('\n')
        sys.stdout.write('\n')

def main(argv):
    pool = Pool()
    argv = sort_argv(argv)
    corrs = pool.map(extract, argv)
    write_corr(corrs, 0)

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
