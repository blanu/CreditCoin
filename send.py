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
from util import encode, decode, epoch
from receipts import Receipts, Send, Receive

dir=sys.argv[1]
to=sys.argv[2]
(pub, priv) = loadKeys(dir)

@_o
def send(dir, coin, to):
 try:
  receipt=Send(None, pub, epoch(), coin, loadPublic(to))
  receipt.setPrivate(priv)
  receipt.sign()

  receipts=Receipts()
  receipts.load(dir+'/receipts.dat')  
  receipts.add(receipt)
  
  smsg=json.dumps(receipt.save(True))
  
  print('sending')
  client=Client()
  yield client.connect('localhost', 7050)
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
    
  cs.save(dir+'/coins.dat')
  receipts.add(receipt)
  print('saving '+str(len(receipts.receipts)))
  receipts.save(dir+'/receipts.dat')
  
  eventloop.halt()
 except Exception, e:
  print('Exception:')
  print(e)
  traceback.print_exc()

if __name__=='__main__':
  cs=Coins()
  cs.load(dir+'/coins.dat')
  coin=cs.get()
  
  if not coin:
    print('No coins!')
  else:
    send(dir, coin, to)
    eventloop.run()
