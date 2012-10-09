//
//  Contact.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Contact.h"
#import "SScrypto.h"

@implementation Contact

@synthesize info=_info;
@synthesize publicKey=_publicKey;
@synthesize signature=_signature;

+ (Contact *)loadWithObjects:(NSArray *)items
{
	NSDictionary *info=(NSDictionary *)[items objectAtIndex:0];
	NSData *publicKey=(NSData *)[items objectAtIndex:1];
	NSData *signature=(NSData *)[items objectAtIndex:2];
	
	return [[Contact alloc] initWithSignature:signature info:info publicKey:publicKey];
}

- (Contact *)initWithSignature:(NSData *)signature info:(NSDictionary *)info publicKey:(NSData *)publicKey
{
  self=[super init];
  if(self)
  {
    self.signature=signature;
    self.info=info;
    self.publicKey=publicKey;
  }
  return self;
}

- (Contact *)initWithPrivateKey:(NSData *)privateKey info:(NSDictionary *)info
{
    self=[super init];
    if(self)
    {
        self.info=info;
        self.publicKey=[SSCrypto generateRSAPublicKeyFromPrivateKey:privateKey];        
        [self sign:privateKey];        
    }
    return self;
}

- (void)sign:(NSData *)privateKey
{
	NSData *data=[self serializeWithoutSignature];
	
	SSCrypto *crypto=[[SSCrypto alloc] initWithPrivateKey:privateKey];
	[crypto setClearTextWithData:[SSCrypto getSHA1ForData:data]];
	self.signature=[crypto sign];
}

- (NSData *)serializeWithoutSignature
{
    NSMutableArray *data=[[NSMutableArray alloc] init];
    [data addObject:self.info];
    [data addObject:[self.publicKey encodeBase64]];
    return  [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
}

- (NSData *)serializeWithSignature
{
    NSMutableArray *data=[[NSMutableArray alloc] init];
    [data addObject:self.info];
    [data addObject:[self.publicKey encodeBase64]];
    [data addObject:[self.signature encodeBase64]];
    return  [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
}

- (NSArray *)objects
{
    NSMutableArray *data=[[NSMutableArray alloc] init];
    [data addObject:self.info];
    [data addObject:self.publicKey];
    [data addObject:self.signature];
    return data;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.info];
    [encoder encodeObject:self.publicKey];
    [encoder encodeObject:self.signature];
}

-(id) initWithCoder:(NSCoder *)decoder
{
    self.info=[decoder decodeObject];
    self.publicKey=[decoder decodeObject];
    self.signature=[decoder decodeObject];
    return self;
}

@end
