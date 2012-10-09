//
//  Contact.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSCoder.h>

@interface Contact : NSObject <NSCoding>

@property NSDictionary *info;
@property (strong, nonatomic) NSData *publicKey;
@property (strong, nonatomic) NSData *signature;

+ (Contact *)loadWithObjects:(NSArray *)contactObjects;

- (Contact *)initWithSignature:(NSData *)signature info:(NSDictionary *)info publicKey:(NSData *)publicKey;
- (Contact *)initWithPrivateKey:(NSData *)privateKey info:(NSDictionary *)info;

- (NSArray *)objects;
- (NSData *)serializeWithSignature;

@end
