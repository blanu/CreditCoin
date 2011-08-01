import rsa

from util import encode, decode

def genKeys(dir):
  (pub, priv) = rsa.newkeys(512)

  f=open(dir+'/id_rsa', 'wb')
  f.write(priv.save_pkcs1())
  f.close()

  f=open(dir+'/id_rsa.pub', 'wb')
  f.write(pub.save_pkcs1())
  f.close()

def loadPublic(s):
  return fixPub(rsa.key.PublicKey.load_pkcs1_der(decode(s)))

def loadPrivate(s):
  return fixPriv(rsa.key.PrivateKey.load_pkcs1_der(decode(s)))

def fixPriv(priv):
  return rsa.key.PrivateKey(long(priv.n), long(priv.e), long(priv.d), long(priv.p), long(priv.q), long(priv.exp1), long(priv.exp2), long(priv.coef))

def fixPub(pub):
  return rsa.key.PublicKey(long(pub.n), long(pub.e))

def loadKeys(dir):
  f=open(dir+'/id_rsa', 'rb')
  s=f.read()
  priv=fixPriv(rsa.key.PrivateKey.load_pkcs1(s))
  f.close()

  f=open(dir+'/id_rsa.pub', 'rb')
  s=f.read()
  pub=fixPub(rsa.key.PublicKey.load_pkcs1(s))
  f.close()

  return (pub, priv)
