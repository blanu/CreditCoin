//
//  TransactionsViewController.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TransactionsViewController.h"
#import "TransactionDetailViewController.h"
#import "Transaction.h"
#import "SScrypto.h"
#import <GameKit/GameKit.h>

@interface TransactionsViewController ()

@end

@implementation TransactionsViewController

@synthesize transactionsTable;
@synthesize transactions=_transactions;

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
    
    [self loadMatches];
}

- (void)loadMatches
{
    self.transactions=[[NSMutableArray alloc] init];
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
                Transaction *transaction=[Transaction load:matchData];
                [self.transactions addObject:transaction];
                [transactionsTable reloadData];
            }];
        }
    }];
}

- (void)viewDidUnload
{
    [self setTransactionsTable:nil];
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
    if([segue.identifier isEqualToString:@"Transaction Detail"])
    {
        NSLog(@"doing it");
        TransactionDetailViewController *dest=(TransactionDetailViewController *)segue.destinationViewController;
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
    return [self.transactions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Transaction Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Transaction *transaction=[self.transactions objectAtIndex:[indexPath indexAtPosition:1]];
    NSString *label;
    if(transaction.senderName!=nil)
    {
        label=transaction.senderName;        
    }
    else
    {
        label=@"?";
    }
    
    label=[label stringByAppendingString:@" -> "];
    
    if(transaction.receiverName!=nil)
    {
        label=[label stringByAppendingString:transaction.receiverName];
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
    
    Transaction *transaction=[self.transactions objectAtIndex:[indexPath indexAtPosition:1]];         
    detailView.transaction=transaction;
}

@end
