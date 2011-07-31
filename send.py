import sys
import time
import random
import struct
import json
import traceback

import rsa

import monocle
from monocle import _o, Return
monocle.init('tornado')

from monocle.stack import eventloop
from monocle.stack.network import add_service, Client, ConnectionLost

from coins import Coin, Coins
from keys import loadKeys, loadPublic, loadPrivate
from util import encode, decode
from receipts import Receipts, Send, Receive

(pub, priv) = loadKeys()

@_o
def send(coin, to):
 try:
  receipt=Send(None, pub, coin, to)
  receipt.setPrivate(priv)
  receipt.sign()

  receipts=Receipts()
  receipts.load('receipts.data')  
  receipts.add(receipt)
  receipts.save('receipts.dat')
  
  smsg=json.dumps(receipt.save(True))
  
  client=Client()
  yield client.connect('blanu.net', 7050)
  yield client.write(smsg+"\n")

  s=yield client.read_until("\n")
  msg=json.loads(s)
  receipt=Receive()
  receipt.load(msg)
  
  if receipt.cmd!='receive':
    print('Unknown command: '+str(receipt.cmd))
    return
  if receipt.args.save_pkcs1_der()!=pub.save_pkcs1_der():
    print('Not me')
    return
  if not rsa.verify(str(receipt.sig), receipt.pub):
    print('Not verified')
    return    
  cs.save('coins.dat')
  receipts.add(receipt)
  receipts.save('receipts.data')
  
  eventloop.halt()
 except Exception, e:
  print('Exception:')
  print(e)
  traceback.print_exc()

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
