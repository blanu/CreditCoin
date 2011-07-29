import sys
import time
import random
import struct
import json

import rsa

import monocle
from monocle import _o, Return
monocle.init('tornado')

from monocle.stack import eventloop
from monocle.stack.network import add_service, Client, ConnectionLost

from coins import Coin, Coins
from keys import loadKeys, loadPublic, loadPrivate
from util import encode, decode

(pub, priv) = loadKeys()

@_o
def send(coin, to):
  msg=['send', coin.save(), encode(pub.save_pkcs1_der()), to]
  msgs=json.dumps(msg)
  sig=rsa.sign(msgs, priv)

  smsg=json.dumps([msg, sig])

  client=Client()
  yield client.connect('blanu.net', 7050)
  yield client.write(smsg+"\n")

  s=yield client.read_until("\n")
  smsg=json.loads(s)
  msg=smsg[0]
  cmd, scoin, frm, to=msg
  coin=Coin()
  coin.load(scoin)
  frm=loadPublic(frm)
  to=loadPublic(to)
  sig=smsg[1]
  
  if cmd!='receive':
    print('Unknown command: '+str(cmd))
    return
  if frm.save_pkcs1_der()!=pub.save_pkcs1_der():
    print('Not me')
    print(encode(frm.save_pkcs1_der()))
    print(encode(pub.save_pkcs1_der()))
    return
  if not rsa.verify(str(sig), to):
    print('Not verified')
    return
  cs.save('coins.dat')
  
  eventloop.halt()

if __name__=='__main__':
  to=sys.argv[1]

  cs=Coins()
  cs.load('coins.dat')
  coin=cs.get()
  
  if not coin:
    print('No coins!')
  else:
    send(coin, to)
    eventloop.run()
