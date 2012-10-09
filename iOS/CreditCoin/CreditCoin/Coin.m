//
//  Coin.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Coin.h"
#import <SSCrypto/SSCrypto.h>

@implementation Coin

+ (Coin *)create:(NSData *)privateKey
{
    NSLog(@"Coin create");
    return [[Coin alloc] initWithPrivateKey:privateKey];
}

+ (Coin *)load:(NSData *)data
{
	NSArray *items=(NSArray *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  return [Coin loadWithObjects:items];
}
  
+ (Coin *)loadWithObjects:(NSArray *)items
{
	NSData *seedData=(NSData *)[items objectAtIndex:0];
	NSData *publicKey=(NSData *)[items objectAtIndex:1];
	NSData *signature=(NSData *)[items objectAtIndex:2];
	
	return [[Coin alloc] initWithSeed:seedData publicKey:publicKey signature:signature];
}

- (Coin *)initWithSeed:(NSData *)seedData publicKey:(NSData *)publicKey signature:(NSData *)signature
{
  self=[super init];
  if(self)
  {
    seed=seedData;
    pub=publicKey;
    sig=signature;
  }
  return self;
}

- (Coin *)initWithPrivateKey:(NSData *)privateKey
{
  self=[super init];
  if(self)
  {
    NSMutableData *seedData=[NSMutableData dataWithCapacity:20];
    for(unsigned int i=0; i<20; i++)
    {
      NSInteger b=arc4random();
      [seedData appendBytes:(void*)&b length:1];
    }
    seed=[NSData dataWithData:seedData];
	
    pub=[SSCrypto generateRSAPublicKeyFromPrivateKey:privateKey];
	
    [self sign:privateKey];
  }
  return self;
}

- (NSData *)serializeWithoutSignature
{
    NSMutableArray *data=[[NSMutableArray alloc] init];
    [data addObject:[seed encodeBase64]];
    [data addObject:[pub encodeBase64]];
    return  [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
}

- (NSString *)serializeWithSignature
{
    NSMutableArray *data=[[NSMutableArray alloc] init];
    [data addObject:[seed encodeBase64]];
    [data addObject:[pub encodeBase64]];
    [data addObject:[sig encodeBase64]];
    return  [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:0 error:nil] encoding:NSUTF8StringEncoding];
}

- (void)sign:(NSData *)privateKey
{
  NSLog(@"coin sign");
	NSData *coinData=[self serializeWithoutSignature];
  NSLog(@"coin sign %d", [coinData length]);
	
	SSCrypto *crypto=[[SSCrypto alloc] initWithPrivateKey:privateKey];
	[crypto setClearTextWithData:[SSCrypto getSHA1ForData:coinData]];
	sig=[crypto sign];
  NSLog(@"coin signed");
}

- (NSData *)getSeed
{
  return seed;
}


- (NSArray *)objects
{
    NSMutableArray *data=[[NSMutableArray alloc] init];
    [data addObject:seed];
    [data addObject:pub];
    [data addObject:sig];
    return data;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:seed];
    [encoder encodeObject:pub];
    [encoder encodeObject:sig];
}

-(id) initWithCoder:(NSCoder *)decoder
{
    seed=[decoder decodeObject];
    pub=[decoder decodeObject];
    sig=[decoder decodeObject];
    return self;
}

@end
