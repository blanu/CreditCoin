import os
import json

import rsa

from util import encode, decode

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
    self.pub=rsa.key.PublicKey.load_pkcs1_der(decode(pub))
    self.sig=sig
    
  def verify(self):
    return True # FIXME
    if rsa.verify(self.sig, self.pub):
      print('Verified')
      return True
    else:
      print('Not verified')
      return False

class Coins:
  def __init__(self):
    self.coins=[]

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
    print('creating')
    print(type(id))
    print(type(priv))
    coin=Coin(id, pub, rsa.sign(id, priv))
    self.coins.append(coin)

  def get(self):
    if len(self.coins)==0:
      return None
    else:
      return self.coins.pop()
      