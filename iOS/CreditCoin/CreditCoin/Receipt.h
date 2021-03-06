//
//  Receipt.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSCoder.h>

@class Coin;

@interface Receipt : NSObject <NSCoding>

@property (strong, nonatomic) NSString *command;
@property (strong, nonatomic) NSData *publicKey;
@property (strong, nonatomic) Coin *coin;
@property (strong, nonatomic) NSData *argument;
@property (strong, nonatomic) NSData *signature;

+ (Receipt *)create:(NSData *)privateKey proof:(NSData *)proof;
+ (Receipt *)destroy:(NSData *)privateKey coin:(Coin *)coinObject;
+ (Receipt *)send:(NSData *)privateKey coin:(Coin *)coinObject to:(NSData *)destination;
+ (Receipt *)receive:(NSData *)privateKey coin:(Coin *)coinObject from:(NSData *)sender;

+ (Receipt *)load:(NSData *)data;

- (Receipt *)initWithSignature:(NSData *)signature command:(NSString *)commandName publicKey:(NSData *)publicKey coin:(Coin *)coinObject argument:(NSData *)argument;
- (Receipt *)initWithPrivateKey:(NSData *)privateKey command:(NSString *)commandName coin:(Coin *)coinObject argument:(NSData *)argument;
- (NSData *)serializeWithoutSignature;
- (NSArray *)objects;

@end
