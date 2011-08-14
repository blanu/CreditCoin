import os
import sys
import json

from paver.easy import *
from paver.path import *

from github2.client import Github
from github import github

sys.path.append(os.path.abspath('..'))

from keys import genKeys, loadKeys
from mint import Mint
from coins import Coin, Coins
from keys import loadKeys, loadPublic, loadPrivate
from util import encode, decode, epoch
from receipts import Receipts, Send, Receive

options()

@task
def GitBank():
  if os.path.exists('GitBank'):
    return
  github = Github(username="blanu", api_token="91eb4a7c4ce63f50f0aa6ed50b015715")
  repos = github.repos.list('blanu') # FIXME - need username
  found=None
  for repo in repos:
    if repo.name=='GitBank':
      found=repo
  if not found:
    print('Forking...')
    github.repos.fork('blanu/GitBank')

    for repo in repos:
      if repo.name=='GitBank':
        found=repo
  if found:
    url=found.url.replace('https', 'git')+'.git'
    print(found.url)
    sh('git clone '+url)
  else:
    print('Fork failed.')

@task
def fetchParticipants():
  if os.path.exists('participants.json'):
    return

  participants={}

  gh=Github()
  comments=gh.issues.comments('blanu/CreditCoin', 1)
  for comment in comments:
    participants[comment.user]=comment.body
  f=open('participants.json', 'wb')
  f.write(json.dumps(participants)+"\n")
  f.close()

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

@task
@consume_args
@needs(['GitBank', 'fetchParticipants'])
def send(args):
  to=args[0]

  f=open('participants.json', 'rb')
  participants=json.loads(f.read())
  f.close()

  if not to in participants:
    print('Unknown participant: '+str(to))
    return

  toPub=participants[to]
  to=loadPublic(toPub, format='PEM')

  (pub, priv) = loadKeys('GitBank')

  cs=Coins('GitBank')
  coin=cs.get()

  if not coin:
    print('No coins!')
    return

  receipt=Send(None, pub, epoch(), coin, to)
  receipt.setPrivate(priv)
  receipt.sign()

  receipts=Receipts('GitBank')
  receipts.add(receipt)

@task
@needs(['GitBank'])
def receive():
  (pub, priv) = loadKeys('GitBank')

  cs=Coins('GitBank')

  receipts=Receipts('GitBank')
  pending=receipts.findPending(pub)
  if len(pending)==0:
    print('No pending coins')
  elif len(pending)==1:
    print('1 pending coin')
  else:
    print(str(len(pending))+' pending coins')
  for receipt in pending:
    print(receipt)

  if receipt.cmd!='send':
    print('Unknown command: '+str(receipt.cmd))
    return
  if receipt.args!=pub:
    print('Not me: '+str(receipt.args)+' '+str(pub))
    return
  if not receipt.verify():
    print('Not verified')
    return
  cs.add(receipt.coin)

  receipt=Receive(None, pub, epoch(), receipt.coin, receipt.pub)
  receipt.setPrivate(priv)
  receipt.sign()
  receipts.add(receipt)
