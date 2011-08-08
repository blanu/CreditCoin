import os
import sys

from paver.easy import *
from paver.path import *

from github2.client import Github
from github import github

sys.path.append(os.path.abspath('..'))

from keys import genKeys, loadKeys
from mint import Mint

options()

@task
def GitBank():
  if not os.path.exists('GitBank'):
    sh('git clone git://github.com/blanu/GitBank.git') # FIXME - this is the read-only URL

@task
@consume_args
@needs(['GitBank'])
def create(args):
  username=args[0]
  token=args[1]
  project=args[2]
  branch=args[3]

  m=Mint('GitBank')

  agh=github.GitHub(username, token)
  user=agh.users.show(username)
  parts=project.split('/')
  commits=agh.commits.forBranch(parts[0], parts[1], branch)
  collabs=agh.repos.collaborators(parts[0], parts[1])

  if username in collabs:
    print("You can't mint from your own repo.")
  else:
    print('Searching for commits')
    for commit in commits:
      if commit.committer.login==username:
        print('http://github.com'+commit.url)
        m.create(commit.url)

@task
@consume_args
@needs(['GitBank'])
def signup(args):
  username=args[0]
  token=args[1]

  if not os.path.exists('GitBank/id_rsa.pub'):
    genKeys('GitBank')

    pub, priv=loadKeys()

    agh=Github(username, token)
    agh.issues.comment('blanu/CreditCoin', 1, pub)
