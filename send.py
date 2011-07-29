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

from coins import Coins
from keys import loadKeys
from util import encode, decode

to=sys.argv[1]

cs=Coins()
cs.load('coins.dat')

(pub, priv) = loadKeys()

coin=cs.get()
msg=['send', coin.save(), encode(pub.save_pkcs1_der()), to]
msgs=json.dumps(msg)
sig=rsa.sign(msgs, priv)

smsg=[msg, sig]

print(smsg)

#cs.save('coins.dat')
