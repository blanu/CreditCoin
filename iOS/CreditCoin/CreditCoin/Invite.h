//
//  Invite.h
//  CreditCoin
//
//  Created by Brandon Wiley on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSCoder.h>
#import "Contact.h"

@interface Invite : NSObject <NSCoding>
{
    NSInteger state;
}

@property (strong, nonatomic) Contact *sender;
@property (strong, nonatomic) Contact *receiver;

+ (Invite *)load:(NSData *)data;

- (NSString *)getState;
- (NSData *)serialize;
- (void)setState:(NSInteger)newState;
- (void)log;

@end
