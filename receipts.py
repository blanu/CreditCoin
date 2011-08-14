import os
import json
import base64
import random
import hashlib

import rsa

from util import encode, decode, epoch
from keys import loadPublic

from coins import Coin

class Receipt:
  def __init__(self, sig=None, pub=None, time=None, cmd=None, coin=None, args=None):
    print('Receipt: '+str(pub))
    self.sig=sig
    self.pub=pub
    self.time=time
    self.cmd=cmd
    self.coin=coin
    self.args=args

    if self.sig:
      h=hashlib.sha1()
      h.update(self.serialize(saveSig=True, jsonify=True))
      self.id=base64.b32encode(h.digest())

    self.priv=None

  def load(self, filename):
    f=open(filename, 'rb')
    l=json.loads(f.read())
    f.close()
    self.deserialize(l)

    h=hashlib.sha1()
    h.update(self.serialize(saveSig=True, jsonify=True))
    self.id=base64.b32encode(h.digest())

  def deserialize(self, l):
    self.sig=decode(l[0])
    self.pub=l[1]
    self.pub=loadPublic(self.pub)
    self.time=l[2]
    self.cmd=l[3]
    self.coin=Coin()
    self.coin.deserialize(l[4])

    if len(l)==6:
      if self.cmd=='create':
        self.args=l[5]
      else:
        self.args=loadPublic(l[5])

  def save(self, filename, saveSig):
    f=open(filename, 'wb')
    f.write(self.serialize(saveSig=saveSig, jsonify=True))

  def serialize(self, saveSig=False, jsonify=False):
    if self.args:
      if type(self.args)==unicode:
        msg=[encode(self.pub.save_pkcs1('DER')), self.time, self.cmd, self.coin.serialize(jsonify=False), self.args]
      else:
        msg=[encode(self.pub.save_pkcs1('DER')), self.time, self.cmd, self.coin.serialize(jsonify=False), encode(self.args.save_pkcs1('DER'))]
    else:
      msg=[encode(self.pub.save_pkcs1('DER')), self.time, self.cmd, self.coin.serialize(jsonify=False)]

    if saveSig:
      msg=[encode(self.sig)]+msg

    if jsonify:
      return json.dumps(msg)
    else:
      return msg

  def setPrivate(self, priv):
    self.priv=priv

  def sign(self):
    if self.priv:
      print('Signing')
      self.sig=rsa.sign(self.serialize(saveSig=False, jsonify=True), self.priv, 'SHA-1')

      h=hashlib.sha1()
      h.update(self.serialize(saveSig=True, jsonify=True))
      self.id=base64.b32encode(h.digest())
    else:
      print('No private key')

  def verify(self):
#    if rsa.verify(self.serialize(saveSig=False, jsonify=True), str(self.sig), self.pub):
#      return True
#    else:
#      return False
    return True

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
  def __init__(self, filename):
    self.filename=filename

  def load(self):
    if os.path.exists(self.filename):
      receipts=[]
      accounts=os.listdir(self.filename+'/receipts')
      for account in accounts:
        rs=os.listdir(self.filename+'/receipts/'+account)
        for receiptfile in cs:
          receipt=Receipt()
          receipt.load(self.filename+'/receipts/'+account+'/'+receiptfile, 'rb')
          if receipt.verify():
            receipts.append(receipt)
      return receipts
    else:
      return []

  def findPending(self, to):
    pending={}

    ep=str(epoch())
    if not os.path.exists(self.filename):
      print('No directory')
      return []
    if not os.path.exists(self.filename+'/receipts'):
      print('No receipts')
      return []
    if not os.path.exists(self.filename+'/receipts/'+ep):
      print('No receipts for this epoch: '+ep)
      return []
    for receiptfile in os.listdir(self.filename+'/receipts/'+ep):
      receipt=Receipt()
      receipt.load(self.filename+'/receipts/'+ep+'/'+receiptfile)
      print(receipt.id)
      if receipt.cmd=='send':
        if receipt.args==to:
          coin=receipt.coin
          pending[coin.id]=receipt
    print(pending)
    for receiptfile in os.listdir(self.filename+'/receipts/'+ep):
      receipt=Receipt()
      receipt.load(self.filename+'/receipts/'+ep+'/'+receiptfile)
      print(receipt.id)
      if receipt.cmd=='receive':
        if receipt.args==to:
          coin=receipt.coin
          if coin.id in pending:
            del pending[coin.id]
    print(pending)
    return pending.values()

  def add(self, receipt):
    if not os.path.exists(self.filename+'/receipts'):
      os.mkdir(self.filename+'/receipts')
    if not os.path.exists(self.filename+'/receipts/'+str(receipt.time)):
      os.mkdir(self.filename+'/receipts/'+str(receipt.time))
    receipt.save(self.filename+'/receipts/'+str(receipt.time)+'/'+receipt.id, saveSig=True)
