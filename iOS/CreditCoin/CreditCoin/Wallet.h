//
//  Wallet.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class Contact;

@interface Wallet : NSObject <GKTurnBasedEventHandlerDelegate>
{
  NSData *priv;
  NSData *pub;
	NSMutableArray *coins;
	NSMutableArray *receipts;
  NSMutableArray *contacts;
    NSString *playerid;
}

+ (Wallet *)instance;
+ (Wallet *)loadFromFile;
+ (Wallet *)loadFromFile:(NSString *)filename;
+ (Wallet *)load:(NSData *)privateKey coins:(NSData *)coinData receipts:(NSData *)receiptData contacts:(NSData *)contactData;
+ (Wallet *)loadWithObjects:(NSData *)privateKey coins:(NSArray *)coinObjects receipts:(NSArray *)receiptObjects contacts:(NSArray *)contactObjects;

- (void)writeToFile;
- (void)writeToFile:(NSString *)filename;

- (Wallet *)init;
- (Wallet *)initWithArrays:(NSData *)privateKey coins:(NSArray *)coinArray receipts:(NSArray *)receiptArray contacts:(NSArray *)contactArray;

- (NSData *)getPrivateKey;
- (NSData *)getPublicKey;
- (NSArray *)getCoins;
- (NSArray *)getReceipts;
- (NSArray *)getContacts;
- (Contact *)getContact;

- (void)create;

@end
