//
//  Transaction.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Transaction.h"
#import "Coin.h"
#import "Receipt.h"
#import "Contact.h"
#import <GameKit/GameKit.h>

@implementation Transaction

@synthesize coin=_coin;
@synthesize senderName=_senderName;
@synthesize receiverName=_receiverName;
@synthesize sender=_sender;
@synthesize receiver=_receiver;
@synthesize sendReceipt=_sendReceipt;
@synthesize receiveReceipt=_receiveReceipt;

+ (Transaction *)load:(NSData *)data
{
    Transaction *transaction=[NSKeyedUnarchiver unarchiveObjectWithData:data];
 
    if(transaction.sender)
    {
        NSMutableArray *players=[[NSMutableArray alloc] init];
        [players addObject:transaction.sender.email];
        [GKPlayer loadPlayersForIdentifiers:players withCompletionHandler:^(NSArray *players, NSError *error)
         {
             NSLog(@"sender name callback");
             GKPlayer *player=[players objectAtIndex:0];
             transaction.senderName=player.alias;
         }];
    }
    if(transaction.receiver)
    {
        NSMutableArray *players=[[NSMutableArray alloc] init];
        [players addObject:transaction.receiver.email];
        [GKPlayer loadPlayersForIdentifiers:players withCompletionHandler:^(NSArray *players, NSError *error)
         {
             NSLog(@"receiver name callback");
             GKPlayer *player=[players objectAtIndex:0];
             transaction.receiverName=player.alias;
         }];
    }
    
    
    return transaction;
}

- (NSData *)serialize
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+ (Transaction *)send:(Coin *)coin from:(Contact *)sender to:(NSString *)playerid named:(NSString *)receiverName
{
    Transaction *transaction=[[Transaction alloc] init];
    transaction.coin=coin;
    transaction.receiverName=receiverName;
    transaction.sender=sender;

    NSMutableArray *players=[[NSMutableArray alloc] init];
    [players addObject:playerid];
    
    GKMatchRequest *request=[[GKMatchRequest alloc] init];
    request.minPlayers=2;
    request.maxPlayers=2;
    request.playersToInvite=players;
    
    [GKTurnBasedMatch findMatchForRequest:request withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error)
    {
        NSLog(@"found match %d", [match.participants count]);

        GKTurnBasedParticipant *firstParticipant=[match.participants objectAtIndex:0];
        GKTurnBasedParticipant *secondParticipant=[match.participants objectAtIndex:1];
        NSLog(@"participants %@, %@, %@, %@", firstParticipant.playerID, secondParticipant.playerID, playerid, sender.email);
        int index;
        if([firstParticipant.playerID isEqualToString:sender.email])
        {
            index=1;
        }
        else
        {
            index=0;
        }    
        
        NSLog(@"ending turn %d", index);
        [match endTurnWithNextParticipant:[match.participants objectAtIndex:index] matchData:[transaction serialize] completionHandler:^(NSError *error)
        {
            NSLog(@"ended turn");
            NSLog(@"I am %@, ending turn with %@", sender.email, ((GKTurnBasedParticipant *)[match.participants objectAtIndex:index]).playerID);
        }];
    }];
    
    return transaction;
}

-(Transaction *)init
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
    [encoder encodeObject:self.coin];
    [encoder encodeObject:self.receiverName];
    
    [encoder encodeObject:[NSNumber numberWithInt:state]];
    
    if(state>0)
    {
        [encoder encodeObject:self.sender];
        
        if(state>1)
        {
            [encoder encodeObject:self.receiver];
            
            if(state>2)
            {
                [encoder encodeObject:self.sendReceipt];
                
                if(state>3)
                {
                    [encoder encodeObject:self.receiveReceipt];
                }
            }
        }
    }
}

-(id) initWithCoder:(NSCoder *)decoder
{
    self.coin=[decoder decodeObject];
    self.receiverName=[decoder decodeObject];
    
    state=[(NSNumber *)[decoder decodeObject] integerValue];
    
    if(state>0)
    {
        self.sender=[decoder decodeObject];
        
        if(state>1)
        {
            self.receiver=[decoder decodeObject];
            
            if(state>2)
            {
                self.sendReceipt=[decoder decodeObject];
                
                if(state>3)
                {
                    self.receiveReceipt=[decoder decodeObject];
                }
            }
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
    else if(state==3)
    {
        return @"Receiving";
    }
    else if(state==4)
    {
        return @"Finished";
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

- (void)setSendReceipt:(Receipt *)sendReceipt
{
    NSLog(@"setSendReceipt");
    _sendReceipt=sendReceipt;
    
    if(state<3)
    {
        state=3;
    }
}

- (void)setReceiveReceipt:(Receipt *)receiveReceipt
{
    NSLog(@"setReceiveReceipt");
    _receiveReceipt=receiveReceipt;
    
    if(state<4)
    {
        state=4;
    }
}

- (void)log
{
    NSLog(@"Transaction [");
    NSLog(@"  state: %d", state);
    NSLog(@"  sender: %@", self.sender.email);
    NSLog(@"  receiver: %@", self.receiver.email);
    NSLog(@"  sendReceipt: %@", self.sendReceipt);
    NSLog(@"  receiveReceipt: %@", self.receiveReceipt);
    NSLog(@"]");
}

@end
