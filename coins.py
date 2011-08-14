import os
import json
import random
import base64
import hashlib

import rsa

from util import encode, decode
from keys import fixPub

class Coin:
  def __init__(self, seed=None, pub=None, sig=None):
    self.seed=seed
    self.pub=pub
    self.sig=sig

    if self.pub:
      h=hashlib.sha1()
      h.update(self.pub.save_pkcs1('DER'))
      self.owner=base64.b32encode(h.digest())

      h=hashlib.sha1()
      h.update(self.serialize())
      self.id=base64.b32encode(h.digest())

  def save(self, filename):
    if not os.path.exists(filename+'/coins'):
      os.mkdir(filename+'/coins')
    if not os.path.exists(filename+'/coins/'+self.owner):
      os.mkdir(filename+'/coins/'+self.owner)
    f=open(filename+'/coins/'+self.owner+'/'+self.id, 'wb')
    f.write(self.serialize())
    f.close()

  def serialize(self, jsonify=True):
    seed=encode(self.seed)
    pub=encode(self.pub.save_pkcs1('DER'))
    sig=encode(self.sig)

    if jsonify:
      return json.dumps([seed, pub, sig])
    else:
      return [seed, pub, sig]

  def load(self, filename):
    f=open(filename, 'rb')
    b=f.read()
    f.close()
    return self.deserialize(json.loads(b))

  def deserialize(self, l):
    seed, pub, sig=l
    self.seed=decode(seed)
    self.pub=fixPub(rsa.key.PublicKey.load_pkcs1(decode(pub), 'DER'))
    self.sig=decode(sig)

    h=hashlib.sha1()
    h.update(self.pub.save_pkcs1('DER'))
    self.owner=base64.b32encode(h.digest())

    h=hashlib.sha1()
    h.update(self.serialize())
    self.id=base64.b32encode(h.digest())

  def verify(self):
#    print('verify: '+str(self.seed)+' '+str(self.sig)+' '+str(self.pub))
#    print(rsa.verify(self.seed, str(self.sig), self.pub))
#    if rsa.verify(self.seed, str(self.sig), self.pub):
#      return True
#    else:
#      return False
    return True

class Coins:
  def __init__(self, filename):
    self.filename=filename

  def new(self, pub, priv):
    s=''
    for x in range(20):
      i=random.getrandbits(8)
      s=s+chr(i)
    return self.create(s, pub, priv)

  def load(self):
    if os.path.exists(self.filename):
      coins=[]
      accounts=os.listdir(self.filename+'/coins')
      for account in accounts:
        cs=os.listdir(self.filename+'/coins/'+account)
        for coinfile in cs:
          coin=Coin()
          coin.load(self.filename+'/coins/'+account+'/'+coinfile)
          print('coin: '+str(coin))
          if coin.verify():
            coins.append(coin)
          else:
            print('Coin verification failed.')
      return coins
    else:
      return []

  def create(self, id, pub, priv):
    coin=Coin(id, pub, rsa.sign(id, priv, 'SHA-1'))
    coin.save(self.filename)
    return coin

  def get(self):
    coins=self.load()
    print('coins: '+str(coins))
    if len(coins)==0:
      return None
    else:
      coin=random.choice(coins) # FIXME - delete coin before returning
      return coin

  def add(self, coin):
    coin.save(self.filename)
