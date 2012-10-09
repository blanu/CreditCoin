//
//  Receipt.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SSCrypto.h"
#import "Receipt.h"
#import "Coin.h"

@implementation Receipt

@synthesize command=_command;
@synthesize publicKey=_publicKey;
@synthesize coin=_coin;
@synthesize argument=_argument;
@synthesize signature=_signature;

+ (Receipt *)create:(NSData *)privateKey proof:(NSData *)proof
{
    NSLog(@"Receipt create");
    NSString *commandName=@"create";
    Coin *coinObject=[Coin create:privateKey];
    NSData *argument=proof;
    NSLog(@"got coin");
    
    return [[Receipt alloc] initWithPrivateKey:privateKey command:commandName coin:coinObject argument:argument];
}

+ (Receipt *)destroy:(NSData *)privateKey coin:(Coin *)coinObject
{
    NSString *commandName=@"destroy";
    NSData *argument=[@"" dataUsingEncoding:NSUTF8StringEncoding]; 
    return [[Receipt alloc] initWithPrivateKey:privateKey command:commandName coin:coinObject argument:argument];    
}

+ (Receipt *)send:(NSData *)privateKey coin:(Coin *)coinObject to:(NSData *)destination
{
    NSString *commandName=@"send";
    NSData *argument=destination;
    
    return [[Receipt alloc] initWithPrivateKey:privateKey command:commandName coin:coinObject argument:argument];
}

+ (Receipt *)receive:(NSData *)privateKey coin:(Coin *)coinObject from:(NSData *)sender
{
    NSString *commandName=@"receive";
    NSData *argument=sender;
    
    return [[Receipt alloc] initWithPrivateKey:privateKey command:commandName coin:coinObject argument:argument];
}

+ (Receipt *)load:(NSData *)data
{
    NSArray *objects=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *commandName=[objects objectAtIndex:0];
    NSData *publicKey=[objects objectAtIndex:1];
    NSData *coinData=[objects objectAtIndex:2];
    Coin *coinObject=[Coin load:coinData];
    NSData *argument=[objects objectAtIndex:3];
    NSData *signature=[objects objectAtIndex:4];
    
    return [[Receipt alloc] initWithSignature:signature command:commandName publicKey:publicKey coin:coinObject argument:argument];
}

- (Receipt *)initWithSignature:(NSData *)signature command:(NSString *)commandName publicKey:(NSData *)publicKey coin:(Coin *)coinObject argument:(NSData *)argument;
{
    NSLog(@"receipt initWithSignature");
    self=[super init];
    if(self)
    {
      self.command=commandName;
      self.publicKey=publicKey;
      self.coin=coinObject;
      self.argument=argument;
      self.signature=signature;
    }
    return self;
}

- (Receipt *)initWithPrivateKey:(NSData *)privateKey command:(NSString *)commandName coin:(Coin *)coinObject argument:(NSData *)argument
{
    self=[super init];
    if(self)
    {
      NSData *publicKey=[SSCrypto generateRSAPublicKeyFromPrivateKey:privateKey];
    
      self.command=commandName;
      self.publicKey=publicKey;
      self.coin=coinObject;
      self.argument=argument;
      
      [self sign:privateKey];
    }
    return self;
}

- (NSData *)serializeWithoutSignature
{
    NSMutableArray *data=[[NSMutableArray alloc] init];
    [data addObject:self.command];
    [data addObject:[self.publicKey encodeBase64]];
    [data addObject:[self.coin serializeWithSignature]];
    [data addObject:[self.argument encodeBase64]];
    return  [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
}

- (void)sign:(NSData *)privateKey
{
    NSData *data=[self serializeWithoutSignature];
	
	SSCrypto *crypto=[[SSCrypto alloc] initWithPrivateKey:privateKey];
	[crypto setClearTextWithData:[SSCrypto getSHA1ForData:data]];
	NSData *signature=[crypto sign];

    self.signature=signature;
}

- (NSArray *)objects
{
    NSMutableArray *data=[[NSMutableArray alloc] init];
    [data addObject:self.command];
    [data addObject:self.publicKey];
    [data addObject:[self.coin objects]];
    [data addObject:self.argument];
    [data addObject:self.signature];
    return data;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.command];
    [encoder encodeObject:self.publicKey];
    [encoder encodeObject:self.coin];
    [encoder encodeObject:self.argument];
    [encoder encodeObject:self.signature];
}

-(id) initWithCoder:(NSCoder *)decoder
{
    self.command=[decoder decodeObject];
    self.publicKey=[decoder decodeObject];
    self.coin=[decoder decodeObject];
    self.argument=[decoder decodeObject];
    self.signature=[decoder decodeObject];
    return self;
}

@end
