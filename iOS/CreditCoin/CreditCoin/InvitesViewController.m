//
//  InvitesViewController.m
//  CreditCoin
//
//  Created by Brandon Wiley on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InvitesViewController.h"
#import "InviteDetailViewController.h"
#import "Invite.h"
#import "SScrypto.h"
#import <GameKit/GameKit.h>


@interface InvitesViewController ()

@end

@implementation InvitesViewController

@synthesize invitesTable=_invitesTable;
@synthesize invites=_invites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadMatches];    
}

- (void)loadMatches
{
    self.invites=[[NSMutableArray alloc] init];
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error)
     {
         for(int i=0; i<[matches count]; i++)
         {
             GKTurnBasedMatch *match=(GKTurnBasedMatch *)[matches objectAtIndex:i];
             GKTurnBasedParticipant *p=[match.participants objectAtIndex:0];
             GKTurnBasedParticipant *p2=[match.participants objectAtIndex:1];
             NSLog(@"ps: %@, %@", p, p2);
             [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error)
              {
                  Invite *invite=[Invite load:matchData];
                  [self.invites addObject:invite];
                  [self.invitesTable reloadData];
              }];
         }
     }];
}

- (void)viewDidUnload
{
    [self setInvitesTable:nil];
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
    if([segue.identifier isEqualToString:@"Invite Detail"])
    {
        NSLog(@"doing it");
        InviteDetailViewController *dest=(InviteDetailViewController *)segue.destinationViewController;
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
    return [self.invites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Invite Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Invite *invite=[self.invites objectAtIndex:[indexPath indexAtPosition:1]];
    NSString *label;
    if(invite.sender!=nil)
    {
        label=invite.sender.email;        
    }
    else
    {
        label=@"?";
    }
    
    label=[label stringByAppendingString:@" -> "];
    
    if(invite.receiver!=nil)
    {
        label=[label stringByAppendingString:invite.receiver.email];
    }
    else
    {
        label=[label stringByAppendingString:@"?"];
    }
    
    cell.textLabel.text=label;
    
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
    
    Invite *invite=[self.invites objectAtIndex:[indexPath indexAtPosition:1]];         
    detailView.invite=invite;
}

@end
