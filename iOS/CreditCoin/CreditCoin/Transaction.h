//
//  Transaction.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSCoder.h>
#import "Contact.h"
#import "Receipt.h"

@interface Transaction : NSObject <NSCoding>
{
    NSInteger state;
}

@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSString *receiverName;
@property (strong, nonatomic) Coin *coin;
@property (strong, nonatomic) Contact *sender;
@property (strong, nonatomic) Contact *receiver;
@property (strong, nonatomic) Receipt *sendReceipt;
@property (strong, nonatomic) Receipt *receiveReceipt;

+ (Transaction *)load:(NSData *)data;
+ (Transaction *)send:(Coin *)coin from:(Contact *)sender to:(NSString *)playerid named:(NSString *)receiverName;

- (NSString *)getState;
- (NSData *)serialize;
- (void)setState:(NSInteger)newState;
- (void)log;

@end
