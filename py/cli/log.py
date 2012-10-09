import sys
import time
import random
import struct

from keys import loadKeys
from receipts import Receipts

dir=sys.argv[1]

receipts=Receipts()
receipts.load(dir+'/receipts.dat')
for receipt in receipts.receipts:
  print(receipt.cmd)
