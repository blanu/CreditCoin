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
from monocle.stack.network import add_service, Service, ConnectionLost

from coins import Coin, Coins
from keys import loadKeys, loadPrivate, loadPublic
from util import encode, decode

cs=Coins()
cs.load('coins.dat')

(pub, priv) = loadKeys()

@_o
def handle_recv(conn):
  print('connected')
  s=yield conn.read_until("\n")
  print('read')
  print('s:')
  print(s)
  print(len(s))
  print(type(s))
  smsg=json.loads(s)
  msg=smsg[0]
  cmd, scoin, frm, to=msg
  coin=Coin()
  coin.load(scoin)
  frm=loadPublic(frm)
  print('to:')
  print(to)
  to=loadPublic(to)
  sig=smsg[1]
  
  if cmd!='send':
    print('Unknown command: '+str(cmd))
    return
  if to!=pub:
    print('Not me: '+str(to)+' '+str(pub))
    return
  print('sig:')
  print(type(sig))
  print('frm:')
  print(type(frm))
  if not rsa.verify(str(sig), frm):
    print('Not verified')
    return
  cs.add(coin)
  cs.save('coins.dat')
  
  msg=['receive', coin.save(), encode(frm.save_pkcs1_der()), encode(to.save_pkcs1_der())]
  msgs=json.dumps(msg)
  sig=rsa.sign(msgs, priv)

  smsg=json.dumps([msg, sig])

  print('sending')  
  print(smsg)
  yield conn.write(smsg+"\n")
  print('sent')
  
add_service(Service(handle_recv, port=7050))
eventloop.run()
