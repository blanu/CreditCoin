import os
import sys

from paver.easy import *
from paver.path import *

sys.path.append(os.path.abspath('.'))

from keys import genKeys, loadKeys
from mint import Mint
from util import encode

options()

@task
@consume_args
def create(args):
  dir=args[0]

  if len(args)>1:
    proof=args[1]
  else:
    proof=None

  m=Mint(dir)
  m.create(proof)

@task
@consume_args
def signup(args):
  dir=args[0]
  genKeys(dir)

@task
@consume_args
def whoami(args):
  dir=args[0]

  pub, priv = loadKeys(dir)
  print(encode(pub.save_pkcs1('DER')))
