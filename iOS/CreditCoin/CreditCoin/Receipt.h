//
//  Receipt.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Receipt : NSObject
{
	NSData *command;
	NSData *pub;
	Coin *coin;
	NSData *arg;
	NSData *sig;
}

+ (Receipt *)create:(NSData *)privateKey proof:(NSData *)proof;
+ (Receipt *)send:(NSData *)privateKey coin:(Coin *)coinObject to:(NSData *)destination;
+ (Receipt *)receive:(NSData *)privateKey coin:(Coin *)coinObject from:(NSData *)sender;

+ (Receipt *)load:(NSData *)data;

- (Receipt *)initWithSignature:(NSData *)signature command:(NSData *)commandName publicKey:(NSData *)publicKey coin:(Coin *)coinObject argument:(NSData *)argument;
- (Receipt *)initWithPrivateKey:(NSData *)privateKey command:(NSData *)commandName coin:(Coin *)coinObject argument:(NSData *)argument;
- (NSData *)serializeWithoutSignature;

@end
