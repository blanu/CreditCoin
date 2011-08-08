import sys

from mint import Mint

dir=sys.argv[1]

if len(sys.argv)>2:
  proof=sys.argv[2]
else:
  proof=None

m=Mint(dir)
m.create(proof)
