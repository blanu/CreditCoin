//
//  FriendsViewController.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsViewController.h"
#import "TransactionsViewController.h"
#import "GameKit/GameKit.h"
#import "Coin.h"
#import "Wallet.h"
#import "Transaction.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController
@synthesize friends=_friends;
@synthesize friendsTable=_friendsTable;
@synthesize coin=_coin;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.friends=[[NSArray alloc] init];
    
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
                 [[GKLocalPlayer localPlayer] loadFriendsWithCompletionHandler:
                  ^(NSArray *friends, NSError *error)
                  {
                      if (error)
                      {
                          NSLog(@"friends error");
                          // Handle error
                      }
                      else
                      {
                          NSLog(@"friends success %d", [friends count]);
                          // friends is an array of player identifiers of the user's friends
                          // Now would be a good time to copy or retain it.
                          
                          [GKPlayer loadPlayersForIdentifiers:friends withCompletionHandler:^(NSArray *players, NSError *error)
                          {
                              self.friends=players;
                              [self.friendsTable reloadData];
                          }];                          
                      }
                  } ];                 
             }
         }
     }];        
}

- (void)viewDidUnload
{
    [self setFriendsTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{  
    NSLog(@"prepare for segue");
    if([segue.identifier isEqualToString:@"Select Friend"])
    {
        NSLog(@"doing it");
        TransactionsViewController *dest=(TransactionsViewController *)segue.destinationViewController;
        detailView=dest;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Friend Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    GKPlayer *player=(GKPlayer *)[self.friends objectAtIndex:[indexPath indexAtPosition:1]];
    cell.textLabel.text=player.alias;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    Wallet *wallet=[Wallet instance];

    GKPlayer *player=(GKPlayer *)[self.friends objectAtIndex:[indexPath indexAtPosition:1]];    
    [Transaction send:self.coin from:[wallet getContact] to:player.playerID named:player.alias];
}

@end
