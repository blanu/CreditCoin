//
//  Coin.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Coin.h"
#import "SSCrypto.h"

@implementation Coin

+ (Coin *)create:(NSData *)privateKey
{
    return [[Coin alloc] initWithPrivateKey:privateKey];
}

+ (Coin *)load:(NSData *)data
{
	NSArray *items=[NSJsonSerialization jsonObjectWithData:data];
	NSData *seedData=(NSData *)[items objectAt:0];
	NSData *publicKey=(NSData *)[items objectAt:1];
	NSData *signature=(NSData *)[items objectAt:2];
	
	return [[Coin alloc] initWithSeed:seedData publicKey:publicKey signature:signature];
}

- (Coin *)initWithSeed:(NSData *)seedData publicKey:(NSData *)publicKey signature:(NSData *)signature
{
	seed=seedData;
	pub=publicKey;
	sig=signature;
}

- (Coin *)initWithPrivateKey:(NSData *)privateKey
{
	NSMutableData seedData=[NSMutableData dataWithCapacity:20];
	for(unsigned int i=0; i<20; i++)
	{
		NSInteger b=arc4random();
		[seedData appendBytes:(void*)&b length:1];
	}
	seed=[seedData data];
	
	pub=[SSCrypto generateRSAPublicKeyFromPrivateKey:privateKey];
	
    [self sign];
}

- (void)sign 
{
	NSData *coinData=[self serializeWithoutSignature];
	
	SSCrypto *crypto=[[SSCrypto alloc] initWithPrivateKey:privateKey];
	[crypto setClearTextWithData:coinData];
	sig=[crypto sign];
}

- (NSData *)serializeWithoutSignature
{
    NSArray *data=[[NSArray alloc] init];
    [data addObject:seed];
    [data addObject:pub];
    return  [NSJsonSerialization dataWithJSONobject:data options:0 error:nil];
}

@end
