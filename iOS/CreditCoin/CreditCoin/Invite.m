//
//  Invite.m
//  CreditCoin
//
//  Created by Brandon Wiley on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Invite.h"
#import <GameKit/GameKit.h>

@implementation Invite

@synthesize sender=_sender;
@synthesize receiver=_receiver;

+ (Invite *)load:(NSData *)data
{
    Invite *invite=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if(invite.sender)
    {
        NSMutableArray *players=[[NSMutableArray alloc] init];
        [players addObject:invite.sender.email];
        [GKPlayer loadPlayersForIdentifiers:players withCompletionHandler:^(NSArray *players, NSError *error)
         {
             NSLog(@"sender name callback");
         }];
    }
    if(invite.receiver)
    {
        NSMutableArray *players=[[NSMutableArray alloc] init];
        [players addObject:invite.receiver.email];
        [GKPlayer loadPlayersForIdentifiers:players withCompletionHandler:^(NSArray *players, NSError *error)
         {
             NSLog(@"receiver name callback");
         }];
    }    
    
    return invite;
}

- (NSData *)serialize
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

-(Invite *)init
{
    self=[super init];
    if(self)
    {
        state=1;
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSNumber numberWithInt:state]];
    
    if(state>0)
    {
        [encoder encodeObject:self.sender];
        
        if(state>1)
        {
            [encoder encodeObject:self.receiver];
        }
    }
}

-(id) initWithCoder:(NSCoder *)decoder
{
    state=[(NSNumber *)[decoder decodeObject] integerValue];
    
    if(state>0)
    {
        self.sender=[decoder decodeObject];
        
        if(state>1)
        {
            self.receiver=[decoder decodeObject];            
        }
    }
    
    return self;
}

- (NSString *)getState
{
    if(state==1)
    {
        return @"Waiting for contact";
    }
    else if(state==2)
    {
        return @"Sending";
    }
    else
    {
        return @"Unknown";
    }
}

- (void)setState:(NSInteger)newState
{
    state=newState;
}

- (void)setReceiver:(Contact *)receiver
{
    NSLog(@"setReceiver");
    _receiver=receiver;
    
    if(state<2)
    {
        state=2;
    }
}

- (void)log
{
    NSLog(@"Invite [");
    NSLog(@"  state: %d", state);
    NSLog(@"  sender: %@", self.sender.email);
    NSLog(@"  receiver: %@", self.receiver.email);
    NSLog(@"]");
}

@end
