import time
import random
import struct

from keys import loadKeys
from coins import Coins
from util import encode

pub, priv = loadKeys()
print(encode(pub.save_pkcs1_der()))
