import os
import json

import rsa

from util import encode, decode, epoch
from keys import loadPublic

from coins import Coin

class Receipt:
  def __init__(self, sig=None, pub=None, time=None, cmd=None, coin=None, args=None):
    self.sig=sig
    self.pub=pub
    self.time=time
    self.cmd=cmd
    self.coin=coin
    self.args=args

    self.priv=None

  def load(self, l):
    self.sig=l[0]
    self.pub=l[1]
    self.pub=loadPublic(self.pub)
    self.time=l[2]
    self.cmd=l[3]
    self.coin=Coin()
    self.coin.load(l[4])

    if len(l)==6:
      self.args=loadPublic(l[5])

  def save(self, saveSig):
    if self.args:
      msg=[encode(self.pub.save_pkcs1_der()), self.time, self.cmd, self.coin.save(), encode(self.args.save_pkcs1_der())]
    else:
      msg=[encode(self.pub.save_pkcs1_der()), self.time, self.cmd, self.coin.save()]

    if saveSig:
      msg=[self.sig]+msg

    return msg

  def setPrivate(self, priv):
    self.priv=priv

  def sign(self):
    if self.priv:
      print('Signing')
      self.sig=rsa.sign(json.dumps(self.save(False)), self.priv)
    else:
      print('No private key')

  def verify(self):
    if rsa.verify(str(self.sig), self.pub):
      return True
    else:
      return False

class Create(Receipt):
  def __init__(self, sig=None, pub=None, time=None, coin=None, proof=None):
    Receipt.__init__(self, sig, pub, time, 'create', coin, proof)

class Send(Receipt):
  def __init__(self, sig=None, pub=None, time=None, coin=None, to=None):
    Receipt.__init__(self, sig, pub, time, 'send', coin, to)

class Receive(Receipt):
  def __init__(self, sig=None, pub=None, time=None, coin=None, frm=None):
    Receipt.__init__(self, sig, pub, time, 'receive', coin, frm)

class Receipts:
  def __init__(self):
    self.receipts=[]

  def load(self, filename):
    if os.path.exists(filename):
      f=open(filename, 'rb')
      b=f.read()
      f.close()

      self.receipts=[]
      l=json.loads(b)
      for item in l:
        receipt=Receipt()
        receipt.load(item)
        if receipt.verify():
          self.receipts.append(receipt)
    else:
      self.receipts=[]

  def save(self, filename):
    print('save')
    f=open(filename, 'wb')
    l=[]
    for receipt in self.receipts:
      l.append(receipt.save(True))
    b=json.dumps(l)
    f.write(b)
    f.close()

  def get(self):
    print('get')
    if len(self.receipts)==0:
      return None
    else:
      return self.receipts.pop()

  def add(self, receipt):
    print('add')
    print('appending '+str(receipt)+str(len(self.receipts)))
    self.receipts.append(receipt)
