import rsa

def genKeys():
  (pub, priv) = rsa.newkeys(512)
  
  print(type(pub))
  print(type(priv))

  f=open('id_rsa', 'wb')
  f.write(priv.save_pkcs1())
  f.close()

  f=open('id_rsa.pub', 'wb')
  f.write(pub.save_pkcs1())
  f.close()

def fixPriv(priv):
  return rsa.key.PrivateKey(long(priv.n), long(priv.e), long(priv.d), long(priv.p), long(priv.q), long(priv.exp1), long(priv.exp2), long(priv.coef))
  
def fixPub(pub):
  return rsa.key.PublicKey(long(pub.n), long(pub.e))

def loadKeys():
  f=open('id_rsa', 'rb')
  s=f.read()
  priv=fixPriv(rsa.key.PrivateKey.load_pkcs1(s))
  f.close()

  f=open('id_rsa.pub', 'rb')
  s=f.read()
  pub=fixPub(rsa.key.PublicKey.load_pkcs1(s))
  f.close()

  print(type(pub))
  print(type(priv))

  return (pub, priv)

