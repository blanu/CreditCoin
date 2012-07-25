//
//  Receipt.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Receipt.h"

@implementation Receipt

+ (Receipt *)create:(NSData *)privateKey proof:(NSData *)proof
{
    NSData *commandName=[NSData dataWithString:@"create"];
    Coin *coinObject=[Coin create:privateKey];
    NSData *argument=proof;
    
    return [[Receipt alloc] initWithPrivateKey:privateKey command:commandName coin:coinObject argument:argument];
}

+ (Receipt *)send:(NSData *)privateKey coin:(Coin *)coinObject to:(NSData *)destination
{
    NSData *commandName=[NSData dataWithString:@"send"];
    NSData *argument=destination;
    
    return [[Receipt alloc] initWithPrivateKey:privateKey command:commandName coin:coinObject argument:argument];
}

+ (Receipt *)receive:(NSData *)privateKey coin:(Coin *)coinObject from:(NSData *)sender
{
    NSData *commandName=[NSData dataWithString:@"send"];
    NSData *argument=sender;
    
    return [[Receipt alloc] initWithPrivateKey:privateKey command:commandName coin:coinObject argument:argument];
}

+ (Receipt *)load:(NSData *)data
{
    NSArray *objects=[NSJsonSerialization objectsWithData:data];
    NSData *commandName=[objects objectAt:0];
    NSData *publicKey=[objects objectAt:1];
    NSData *coinData=[objects objectAt:2];
    Coin *coinObject=[Coin load:coinData];
    NSData *argument=[objects objectAt:3];
    NSData *signature=[objects objectAt:4];
    
    return [[Receipt alloc] initWithCommand:commandName publicKey:publicKey coin:coinObject argument:argument signature:signature];
}

- (Receipt *)initWithSignature:(NSData *)signature command:(NSData *)commandName publicKey:(NSData *)publicKey coin:(Coin *)coinObject argument:(NSData *)argument;
{
    command=commandName;
    pub=publicKey;
    coin=coinObject;
    arg=argument;
    sig=signature;
}

- (Receipt *)initWithPrivateKey:(NSData *)privateKey command:(NSData *)commandName coin:(Coin *)coinObject argument:(NSData *)argument
{
    NSData *publicKey=[SSCrypto generateRSAPublicKeyFromPrivateKey:privateKey];
    
    command=commandName;
    pub=publicKey;
    coin=coinObject;
    arg=argument;
}

- (NSData *)serializeWithoutSignature
{
    NSArray *data=[[NSArray alloc] init];
    [data addObject:command];
    [data addObject:pub];
    [data addObject:[coin serialize]];
    [data addObject:arg];
    return  [NSJsonSerialization dataWithJSONobject:data options:0 error:nil];
}

- (void)sign:(NSData *)privateKey
{
    NSData *data=[self serialize];
	
	SSCrypto *crypto=[[SSCrypto alloc] initWithPrivateKey:privateKey];
	[crypto setClearTextWithData:data];
	NSData *signature=[crypto sign];

    sig=signature;
}

@end
