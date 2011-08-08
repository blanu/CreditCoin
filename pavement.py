import os
import sys

from paver.easy import *
from paver.path import *

sys.path.append(os.path.abspath('.'))

from keys import genKeys
from mint import Mint

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
