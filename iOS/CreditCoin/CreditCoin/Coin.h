//
//  Coin.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Coin : NSObject
{
	NSData *seed;
	NSData *pub;
	NSData *sig;
}

+ (Coin *)create:(NSData *)privateKey;
+ (Coin *)load:(NSData *)data;

- (Coin *)initWithSeed:(NSData *)seed publicKey:(NSData *)publicKey signature:(NSData *)signature;
- (Coin *)initWithPrivateKey:(NSData *)privateKey;
- (NSData *)serializeWithoutSignature;
- (void)sign;

@end
