#!/usr/bin/env python
# e mclean, feb 2017

'''
generates a file containing a reduced (spherical) wavefunction to be read into the milc code
and made into a wavefunction source.

r is given in femtometers.

the code will normalise the wavefunction automatically so don't worry about that.
'''


import sys
from math import exp

outfile = "exp3.425_3296.wf"

dr = 0.088/2  #distance between data in r
L = 32*0.088 #lattice spacial extent
r0 = 3.425*0.088 #chararctoristic radius of smearing function

def main(argv):

    f = open(outfile,'w')

    #the first (non-normalized) point at r=0.
    #(my hacked version of) the milc code will not divide by r on the first point,
    #as this results in a nan.
#    f.write(str(0.0)+' '+str(1.0)+'\n')

    N = int(L/dr)
    for n in range(N):

        r = n*dr
        ur = r*exp(-r/r0)

        f.write(str(r)+' '+str(ur)+'\n')

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
