import sys
import time
import random
import struct

from keys import loadKeys
from coins import Coins
from receipts import Create, Receipts
from util import epoch

dir=sys.argv[1]

if len(sys.argv)>2:
  proof=sys.argv[2]
else:
  proof=None

pub, priv = loadKeys(dir)

cs=Coins()
cs.load(dir+'/coins.dat')
coin=cs.new(pub, priv)
cs.save(dir+'/coins.dat')

receipts=Receipts()
receipts.load(dir+'/receipts.dat')
cr=Create(None, pub, epoch(), coin, proof)
cr.setPrivate(priv)
cr.sign()
receipts.add(cr)
receipts.save(dir+'/receipts.dat')
