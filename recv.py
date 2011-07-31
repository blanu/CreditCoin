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
from receipts import Receipts, Send, Receive

cs=Coins()
cs.load('coins.dat')

(pub, priv) = loadKeys()

@_o
def handle_recv(conn):
  print('connected')
  s=yield conn.read_until("\n")
  print('read')
  print(s)
  smsg=json.loads(s)

  receipts=Receipts()
  receipts.load('receipts.dat')  
  
  receipt=Send()
  receipt.load(smsg)
  
  if receipt.cmd!='send':
    print('Unknown command: '+str(receipt.cmd))
    return
  if receipt.args!=pub:
    print('Not me: '+str(receipt.args)+' '+str(pub))
    return
  if not rsa.verify(str(receipt.sig), receipt.pub):
    print('Not verified')
    return
  cs.add(receipt.coin)
  cs.save('coins.dat')
  receipts.add(receipt)
  receipts.save('receipts.dat')

  receipt=Receive(None, pub, receipt.coin, receipt.pub)
  receipt.setPrivate(priv)
  receipt.sign()
  receipts.add(receipt)
  receipts.save('receipts.data')    

  smsg=json.dumps(receipt.save(True))

  print('sending')  
  print(smsg)
  yield conn.write(smsg+"\n")
  print('sent')
  
add_service(Service(handle_recv, port=7050))
eventloop.run()
