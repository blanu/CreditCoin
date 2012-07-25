//
//  Wallet.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Wallet.h"

@implementation Wallet

+ (Wallet *)load:(NSData *)coinData receipts:(NSData *)receiptData
{
	NSArray *coinOjects=[NSJsonSerialization objectsWithData:coinData];
	NSArray *coinArray=[[NSArray alloc] init];
	
	for(int i=0; i<[coinObjects count]; i++)
	{
		NSArray *item=(NSArray *)[coinObjects objectAt:i];
		NSData *seedData=(NSData *)[item objectAt:0];
		NSData *publicKey=(NSData *)[item objectAt:1];
		NSData *signature=(NSData *)[item objectAt:2];
		Coin *coin=[[Coin alloc] initWithSeed:seedData publicKey:publicKey signature:signature];
		[coinArray addObject:coin];
	}
	
	NSArray *receiptOjects=[NSJsonSerialization objectsWithData:receiptData];
	NSArray *receiptArray=[[NSArray alloc] init];
	
	for(int i=0; i<[receiptObjects count]; i++)
	{
		NSArray *item=(NSArray *)[receiptObjects objectAt:i];
		NSData *commandName=(NSData *)[item objectAt:0];
		NSData *publicKey=(NSData *)[item objectAt:1];
		NSData *coinData=(NSData *)[item objectAt:2];
		Coin *coin=[Coin load:coinData];
		NSData *argument=(NSData *)[item objectAt:3];
		NSData *signature=(NSData *)[item objectAt:4];
		Receipt *receipt=[[Receipt alloc] initWithSignature:signature command:commandName publicKey:publicKey coin:coin argument:argument];
		[receiptArray addObject:receipt];
	}
	
	
	return [[Wallet alloc] initWithArrays:coinArray receipts:receiptArray];
}

- (Wallet *)init
{
	coins=[[NSArray alloc] init];
	receipts=[[NSArray alloc] init];
}

- (Wallet *)initWithArrays:(NSArray *)coinArray receipts:(NSArray *)receiptArray
{
	coins=coinArray;
	receipts=receiptArray;
}

@end
