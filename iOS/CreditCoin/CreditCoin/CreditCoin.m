#import "SSacrypto.h"

@implementation CreditCoin : NSObject

- signup
{
  NSData *priv = [SSCrypto generateRSAPrivateKeyWithLength:128];
  NSData *pub = [SSCrypto generateRSAPublicKeyFromPrivateKey:priv];
  SSCrypto *crypto = [[SSCrypto alloc] initWithPublicKey:pub privateKey:priv];

  
}

- create
{
  NSString *coin = @"test coin";

  [crypto setClearTextWithString:coin];
  NSData *signature = [crypto sign];
  
}

- send
{
  NSString *receipt = [NSString stringWithFormat:@"send %s", coin, nil];
}

- recv
{
}


@end