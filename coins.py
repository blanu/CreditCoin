import os
import json
import random

import rsa

from util import encode, decode
from keys import fixPub

class Coin:
  def __init__(self, seed=None, pub=None, sig=None):
    self.seed=seed
    self.pub=pub
    self.sig=sig
    
  def save(self):
    seed=encode(self.seed)
    pub=encode(self.pub.save_pkcs1_der())
    sig=self.sig
    
    return [seed, pub, sig]
    
  def load(self, l):
    seed, pub, sig=l
    self.seed=decode(seed)
    self.pub=fixPub(rsa.key.PublicKey.load_pkcs1_der(decode(pub)))
    self.sig=sig
    
  def verify(self):
    if rsa.verify(str(self.sig), self.pub):
      return True
    else:
      return False

class Coins:
  def __init__(self):
    self.coins=[]
    
  def new(self, pub, priv):
    s=''
    for x in range(20):
      i=random.getrandbits(8)
      s=s+chr(i)
    return self.create(s, pub, priv)

  def load(self, filename):
    if os.path.exists(filename):
      f=open(filename, 'rb')
      b=f.read()
      f.close()

      self.coins=[]
      l=json.loads(b)
      for item in l:
        coin=Coin()
        coin.load(item)
        if coin.verify():
          self.coins.append(coin)
    else:
      self.coins=[]

  def save(self, filename):
    f=open(filename, 'wb')
    l=[]
    for coin in self.coins:
      l.append(coin.save())
    b=json.dumps(l)
    f.write(b)
    f.close()

  def create(self, id, pub, priv):
    coin=Coin(id, pub, rsa.sign(id, priv))
    self.coins.append(coin)
    return coin

  def get(self):
    if len(self.coins)==0:
      return None
    else:
      return self.coins.pop()
      
  def add(self, coin):
    self.coins.append(coin)
