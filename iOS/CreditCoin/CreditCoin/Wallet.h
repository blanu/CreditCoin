//
//  Wallet.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Wallet : NSObject
{
	NSArray *coins;
	NSArray *receipts;
}

+ (Wallet *)load:(NSData *)coinData receipts:(NSData *)receiptData;

- (Wallet *)init;
- (Wallet *)initWithArrays:(NSArray *)coinArray receipts:(NSArray *)receiptArray;

@end
