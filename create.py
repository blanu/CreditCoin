import time
import random
import struct

from keys import loadKeys
from coins import Coins
from receipts import Create, Receipts

pub, priv = loadKeys()

cs=Coins()
cs.load('coins.dat')
coin=cs.new(pub, priv)
cs.save('coins.dat')

receipts=Receipts()
receipts.load('receipts.dat')
cr=Create(None, pub, coin)
cr.setPrivate(priv)
cr.sign()
receipts.add(cr)
receipts.save('receipts.dat')
