import os
import json

import rsa

from util import encode, decode
from keys import loadPublic

from coins import Coin

class Receipt:
  def __init__(self, sig=None, pub=None, cmd=None, coin=None, args=None):
    self.sig=sig
    self.pub=pub
    self.cmd=cmd
    self.coin=coin
    self.args=args
    
    self.priv=None

    if self.pub and self.cmd and self.coin and self.args:
      self.makeMessage()
    
  def load(self, l):
    self.sig=l[0]
    self.pub=l[1]
    self.pub=loadPublic(pub)    
    self.cmd=l[2]
    self.coin=Coin()
    self.coin.load(l[3])
    self.args=l[4]
           
  def save(self, saveSig):
    if self.args:
      msg=[encode(self.pub.save_pkcs1_der()), self.cmd, self.coin.save(), self.args]
    else:
      msg=[encode(self.pub.save_pkcs1_der()), self.cmd, self.coin.save()]
      
    if saveSig:
      msg=[self.sig]+msg
      
    print('saving: '+str(msg))

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
  def __init__(self, sig=None, pub=None, coin=None, args=None):
    Receipt.__init__(self, sig, pub, 'create', coin)
    
class Send(Receipt):
  def __init__(self, pub=None, sig=None, args=None):
    Receipt.__init__(self, pub, sig, 'send', args)
    self.coin=Coin()
    self.coin.load()
    self.coin.verify()
    
class Receive(Receipt):
  def __init__(self, pub=None, sig=None, args=None):
    Receipt.__init__(self, pub, sig, 'receive', args)
    self.coin=Coin()
    self.coin.load()
    self.coin.verify()

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
    f=open(filename, 'wb')
    l=[]
    for receipt in self.receipts:
      l.append(receipt.save(True))
    b=json.dumps(l)
    f.write(b)
    f.close()

  def create(self, id, pub, priv):
    receipt=Receipt(id, pub, rsa.sign(id, priv))
    self.receipts.append(receipt)

  def get(self):
    if len(self.receipts)==0:
      return None
    else:
      return self.receipts.pop()
      
  def add(self, receipt):
    self.receipts.append(receipt)
