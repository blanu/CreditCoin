import time
import random
import struct

from keys import loadKeys
from coins import Coins

def newId():
  s=''
  for x in range(20):
    i=random.getrandbits(8)
    s=s+chr(i)
  return s

cs=Coins()
cs.load('coins.dat')

pub, priv = loadKeys()
id=newId()

cs.create(id, pub, priv)

cs.save('coins.dat')

