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
