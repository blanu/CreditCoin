//
//  Coin.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSCoder.h>

@interface Coin : NSObject <NSCoding>
{
	NSData *seed;
	NSData *pub;
	NSData *sig;
}

+ (Coin *)create:(NSData *)privateKey;
+ (Coin *)load:(NSData *)data;
+ (Coin *)loadWithObjects:(NSArray *)objects;

- (Coin *)initWithSeed:(NSData *)seed publicKey:(NSData *)publicKey signature:(NSData *)signature;
- (Coin *)initWithPrivateKey:(NSData *)privateKey;
- (NSData *)serializeWithoutSignature;
- (NSString *)serializeWithSignature;
- (void)sign:(NSData *)privateKey;
- (NSData *)getSeed;
- (NSArray *)objects;

@end
