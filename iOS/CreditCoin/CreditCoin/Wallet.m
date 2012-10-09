//
//  Wallet.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Wallet.h"
#import "Coin.h"
#import "Receipt.h"
#import "Contact.h"
#import "Transaction.h"
#import "SSCrypto.h"
#import "CreditcoinClient.h"
#import <GameKit/GameKit.h>

@implementation Wallet

static Wallet *_instance;

+ (Wallet *)instance
{
  if(_instance==nil)
  {
    NSLog(@"new instance");
    _instance=[Wallet loadFromFile];
                  
      [_instance loadContact];    
      [_instance loadMatches];
  }
  
  NSLog(@"instance: %@", _instance);
  
  return _instance;
}

- (void)loadContact
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error)
     {
         // Authentication error
         if(error!=nil)
         {
             // GameCenter not enabled for this app, fix this in iTunes Connect
             if(error.code==GKErrorGameUnrecognized)
             {
                 NSLog(@"GameCenter not enabled for this app");
             }
             else if(error.code==GKErrorNotSupported) // GameCenter not available on this device, iOS version is too old
             {
                 NSLog(@"GameCenter not available for this device");                
             }
             else // Some other error, probably network connectivity
             {
                 NSLog(@"Unknown GameCenter error: %@", [error localizedDescription]);
             }
         }
         else // No authentication error
         {
             // Authentication was successful
             if (localPlayer.isAuthenticated)
             {
                 playerid=localPlayer.playerID;
                 
                 GKTurnBasedEventHandler *handler=[GKTurnBasedEventHandler sharedTurnBasedEventHandler];
                 handler.delegate=_instance;
                 NSLog(@"set delegate");                 
             }
         }
     }];        
}

- (void)loadMatches
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error)
     {
         for(int i=0; i<[matches count]; i++)
         {
             GKTurnBasedMatch *match=(GKTurnBasedMatch *)[matches objectAtIndex:i];
             
             [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error)
              {                  
                  if([match.currentParticipant.playerID isEqualToString:playerid])
                  {
                      NSLog(@"my turn: %@", playerid);
                      Transaction *transaction=[Transaction load:matchData];
                      [transaction log];

                      if(transaction.receiver==nil)
                      {
                          [self sendContact:match transaction:transaction];                      
                      }
                      else if([transaction.sender.email isEqualToString:playerid])
                      {
                          NSLog(@"move is from me");
                      
                          [self sendSend:match transaction:transaction];
                      }
                      else if([transaction.receiver.email isEqualToString:playerid])
                      {
                          NSLog(@"move is to me");
                      
                          [self sendReceive:match transaction:transaction];
                      }
                      else
                      {
                          NSLog(@"move is not for me, why do I have this?");
                          return;
                      }   
                      
                      NSLog(@"New state:");
                      [transaction log];
                  }
                  else
                  {
                      NSLog(@"not my turn %@", playerid);

                      Transaction *transaction=[Transaction load:matchData];
                      [transaction log];                      
                  }
              }];
         }
     }];
}


+ (Wallet *)loadFromFile
{
  return [Wallet loadFromFile:@"wallet.plist"];
}

+ (Wallet *)loadFromFile:(NSString *)filename
{
  NSError *error;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *path = [documentsDirectory stringByAppendingPathComponent:@"wallet.plist"];

  NSFileManager *fileManager = [NSFileManager defaultManager];

  if (![fileManager fileExistsAtPath: path])
  {
    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"wallet" ofType:@"plist"];
    [fileManager copyItemAtPath:bundle toPath: path error:&error];
    
    NSLog(@"file not found");
    Wallet *wallet=[[Wallet alloc] init];
    [wallet writeToFile:filename];
    return wallet;
  }
  else
  {  
    NSArray *data=[[NSArray alloc] initWithContentsOfFile:path];
    
    if([data count]>=4)
    {
      NSLog(@"file found");
      NSData *privateKey=(NSData *)[data objectAtIndex:0];
      NSArray *coinObjects=(NSArray *)[data objectAtIndex:1];
      NSArray *receiptObjects=(NSArray *)[data objectAtIndex:2];  
      NSArray *contactObjects=(NSArray *)[data objectAtIndex:3];  
  
      return [Wallet loadWithObjects:privateKey coins:coinObjects receipts:receiptObjects contacts:contactObjects];
    }
    else
    {
      NSLog(@"file empty");
      Wallet *wallet=[[Wallet alloc] init];
      [wallet writeToFile:filename];
      return wallet;    
    }
  }
}

- (void)writeToFile
{
  [self writeToFile:@"wallet.plist"];
}

- (void)writeToFile:(NSString *)filename
{
  NSError *error;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *path = [documentsDirectory stringByAppendingPathComponent:@"wallet.plist"];

  NSFileManager *fileManager = [NSFileManager defaultManager];

  if (![fileManager fileExistsAtPath: path])
  {
    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"wallet" ofType:@"plist"];
    [fileManager copyItemAtPath:bundle toPath: path error:&error];
  }
  
  NSArray *data=[self objects];
  [data writeToFile:path atomically:YES];
}

- (NSArray *)objects
{
  NSMutableArray *data=[[NSMutableArray alloc] init];
  [data addObject:priv];
  [data addObject:coins];
  [data addObject:receipts];
  [data addObject:contacts];
  return data;
}

+ (Wallet *)load:(NSData *)privateKey coins:(NSData *)coinData receipts:(NSData *)receiptData contacts:(NSData *)contactData
{
	NSArray *coinObjects=[NSJSONSerialization JSONObjectWithData:coinData options:0 error:nil];
	NSArray *receiptObjects=[NSJSONSerialization JSONObjectWithData:receiptData options:0 error:nil];
	NSArray *contactObjects=[NSJSONSerialization JSONObjectWithData:contactData options:0 error:nil];

  return [Wallet loadWithObjects:privateKey coins:coinObjects receipts:receiptObjects contacts:contactObjects];
}

+ (Wallet *)loadWithObjects:(NSData *)privateKey coins:(NSArray *)coinObjects receipts:(NSArray *)receiptObjects contacts:(NSArray *)contactObjects;
{
  return [[Wallet alloc] initWithArrays:privateKey coins:coinObjects receipts:receiptObjects contacts:contactObjects];
}

- (NSArray *)getCoins
{
	NSMutableArray *coinArray=[[NSMutableArray alloc] init];
	
	for(int i=0; i<[coins count]; i++)
	{
		NSArray *item=(NSArray *)[coins objectAtIndex:i];
		NSData *seedData=(NSData *)[item objectAtIndex:0];
		NSData *publicKey=(NSData *)[item objectAtIndex:1];
		NSData *signature=(NSData *)[item objectAtIndex:2];
    
		Coin *coin=[[Coin alloc] initWithSeed:seedData publicKey:publicKey signature:signature];
		[coinArray addObject:coin];
	}
  
  return coinArray;
}

- (NSArray *)getReceipts
{
	NSLog(@"getReceipts %d", [receipts count]);
	NSMutableArray *receiptArray=[[NSMutableArray alloc] init];
	
	for(int i=0; i<[receipts count]; i++)
	{
		NSArray *item=(NSArray *)[receipts objectAtIndex:i];
		NSString *commandName=(NSString *)[item objectAtIndex:0];
		NSData *publicKey=(NSData *)[item objectAtIndex:1];
		NSArray *coinData=(NSArray *)[item objectAtIndex:2];
		Coin *coin=[Coin loadWithObjects:coinData];
		NSData *argument=(NSData *)[item objectAtIndex:3];
		NSData *signature=(NSData *)[item objectAtIndex:4];
    
		Receipt *receipt=[[Receipt alloc] initWithSignature:signature command:commandName publicKey:publicKey coin:coin argument:argument];
		[receiptArray addObject:receipt];
	}	

  NSLog(@"done getReceipts");
  
  return receiptArray;
}

- (NSArray *)getContacts
{
	NSMutableArray *contactArray=[[NSMutableArray alloc] init];
	
	for(int i=0; i<[contacts count]; i++)
	{
		NSArray *item=(NSArray *)[contacts objectAtIndex:i];
		Contact *contact=[Contact loadWithObjects:item];
    
		[contactArray addObject:contact];
	}	
  
  return contactArray;
}

- (NSData *)getPrivateKey
{
  return priv;
}

- (NSData *)getPublicKey
{
  return pub;
}

- (Wallet *)init
{
  self=[super init];
  if(self)
  {
    priv=[SSCrypto generateRSAPrivateKeyWithLength:1024];
    pub=[SSCrypto generateRSAPublicKeyFromPrivateKey:priv];
    coins=[[NSMutableArray alloc] init];
    receipts=[[NSMutableArray alloc] init];
    contacts=[[NSMutableArray alloc] init];
  }
  return self;
}

- (Wallet *)initWithArrays:(NSData *)privateKey coins:(NSArray *)coinArray receipts:(NSArray *)receiptArray contacts:(NSArray *)contactArray
{
  self=[super init];
  if(self)
  {
    priv=privateKey;
    pub=[SSCrypto generateRSAPublicKeyFromPrivateKey:priv];
    coins=[NSMutableArray arrayWithArray:coinArray];
    receipts=[NSMutableArray arrayWithArray:receiptArray];
    contacts=[NSMutableArray arrayWithArray:contactArray];
  }
  return self;
}

- (void)uploadContact
{
    Contact *contact=[self getContact];
    NSData *data=[contact serializeWithSignature];
    NSString *s=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    CreditcoinClient *client=[[CreditcoinClient alloc] init];
    [client setContact:contact.email contact:s];
}

- (void)create
{
  Receipt *receipt=[Receipt create:priv proof:[@"proof" dataUsingEncoding:NSUTF8StringEncoding]];
  Coin *coin=receipt.coin;
  [receipts addObject:[receipt objects]];
  [coins addObject:[coin objects]];
  
  NSLog(@"New coins %d, %d", [receipts count], [coins count]);
  
  [self writeToFile];
}

- (Contact *)getContact
{
    NSLog(@"getContact %d", [playerid length]);
    return [[Contact alloc] initWithPrivateKey:priv email:playerid];
}

- (Coin *)getCoin
{
    return [coins objectAtIndex:0];
}

- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite
{
    NSLog(@"got invite");
    GKMatchRequest *request=[[GKMatchRequest alloc] init];
    request.minPlayers=2;
    request.maxPlayers=2;
    request.playersToInvite=playersToInvite;
    
    [GKTurnBasedMatch findMatchForRequest:request withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error)
    {
        [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error)
        {
            Transaction *transaction=[Transaction load:matchData];
            [self sendContact:match transaction:transaction];
        }];
    }];
}

- (void)sendContact:(GKTurnBasedMatch *)match transaction:(Transaction *)transaction
{
    NSLog(@"sendContact");
    transaction.receiver=[self getContact];

    GKTurnBasedParticipant *firstParticipant=[match.participants objectAtIndex:0];
    int index;
    if([firstParticipant.playerID isEqualToString:playerid])
    {
        index=1;
    }
    else
    {
        index=0;
    }
    
    [match endTurnWithNextParticipant:[match.participants objectAtIndex:index] matchData:[transaction serialize] completionHandler:^(NSError *error)
     {
         NSLog(@"ended turn, sent receiver contact");
         NSLog(@"I am %@, ending turn with %@", playerid, ((GKTurnBasedParticipant *)[match.participants objectAtIndex:index]).playerID);
     }];    
}

- (void)sendSend:(GKTurnBasedMatch *)match transaction:(Transaction *)transaction
{
    NSLog(@"sendSend");
    Receipt *receipt=[Receipt send:priv coin:transaction.coin to:transaction.receiver.publicKey];
    transaction.sendReceipt=receipt;

    GKTurnBasedParticipant *firstParticipant=[match.participants objectAtIndex:0];
    int index;
    if([firstParticipant.playerID isEqualToString:playerid])
    {
        index=1;
    }
    else
    {
        index=0;
    }    
    
    [match endTurnWithNextParticipant:[match.participants objectAtIndex:index] matchData:[transaction serialize] completionHandler:^(NSError *error)
     {
         NSLog(@"ended turn, sent receiver contact");
         NSLog(@"I am %@, ending turn with %@", playerid, ((GKTurnBasedParticipant *)[match.participants objectAtIndex:index]).playerID);
     }];    
}

- (void)sendReceive:(GKTurnBasedMatch *)match transaction:(Transaction *)transaction
{
    NSLog(@"sendReceive");
    Receipt *receipt=[Receipt receive:priv coin:transaction.sendReceipt.coin from:transaction.sendReceipt.publicKey];
    transaction.receiveReceipt=receipt;

    [match endMatchInTurnWithMatchData:[transaction serialize] completionHandler:^(NSError *error)
     {
         NSLog(@"ended turn, ended match, sent receiver contact");
         NSLog(@"I am %@, ending match", playerid);
     }];    
}

- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"got event");
    [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error)
     {
         Transaction *transaction=[Transaction load:matchData];
         
         if([transaction.sender.publicKey isEqualToData:pub])
         {
             NSLog(@"move is from me");

             [self sendSend:match transaction:transaction];
         }
         else if([transaction.receiver.publicKey isEqualToData:pub])
         {
             NSLog(@"move is to me");
             
             [self sendReceive:match transaction:transaction];
         }
         else
         {
             NSLog(@"move is not for me, why do I have this?");
             return;
         }         
     }];    
}

- (void)handleMatchEnded:(GKTurnBasedMatch *)match
{
    NSLog(@"match ended");
    [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error)
     {
         Transaction *transaction=[Transaction load:matchData];
         if(transaction.sendReceipt!=nil && transaction.receiveReceipt!=nil)
         {
             NSLog(@"valid transaction!");
             if([transaction.sendReceipt.publicKey isEqualToData:pub])
             {
                 NSLog(@"coin is for me");
             }
             else if([transaction.receiveReceipt.publicKey isEqualToData:pub])
             {
                 NSLog(@"coin is from me");
             }
             else
             {
                 NSLog(@"coin is not for me, why do I have this?");
             }
         }
         else
         {
             NSLog(@"invalid transaction");
         }
     }];        
}                

@end
