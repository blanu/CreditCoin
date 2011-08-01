import sys
import time
import random
import struct

from keys import loadKeys
from coins import Coins
from util import encode

dir=sys.argv[1]

pub, priv = loadKeys(dir)
print(encode(pub.save_pkcs1_der()))
