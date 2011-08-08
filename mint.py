import sys
import time
import random
import struct

import rsa

from keys import loadKeys
from coins import Coins
from receipts import Create, Receipts
from util import epoch

class Mint:
  def __init__(self, dir):
    self.dir=dir
    self.pub, self.priv = loadKeys(self.dir)

  def create(self, proof=None):
    cs=Coins()
    cs.load(self.dir+'/coins.dat')
    coin=cs.new(self.pub, self.priv)
    cs.save(self.dir+'/coins.dat')

    receipts=Receipts()
    receipts.load(self.dir+'/receipts.dat')
    cr=Create(None, self.pub, epoch(), coin, proof)
    cr.setPrivate(self.priv)
    cr.sign()
    receipts.add(cr)
    receipts.save(self.dir+'/receipts.dat')
