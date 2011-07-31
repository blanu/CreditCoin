import time
import random
import struct

from keys import loadKeys
from coins import Coins
from receipts import Create, Receipts

pub, priv = loadKeys()

cs=Coins()
cs.load('coins.dat')
for coin in cs.coins:
  print(coin.sig)
