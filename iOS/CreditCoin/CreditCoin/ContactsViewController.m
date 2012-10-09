//
//  ContactsViewController.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactDetailViewController.h"
#import "Wallet.h"
#import "Contact.h"
#import "SSCrypto.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController
@synthesize contactsTable;

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

    NSLog(@"viewDidLoad cvc");
    wallet=[Wallet instance];
    contacts=[wallet getContacts];
    NSLog(@"viewDidLoad2");
    
    friends=[[NSMutableArray alloc] init];
    
    NSLog(@"loading accounts");
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        NSLog(@"granted?");
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] > 0) {
                // Grab the initial Twitter account to tweet from.
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                
                TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1.1/friends/ids.json"] parameters:[NSDictionary dictionaryWithObject:twitterAccount.username forKey:@"screen_name"] requestMethod:TWRequestMethodGET];
                
                // Set the account used to post the tweet.
                [postRequest setAccount:twitterAccount];

                NSLog(@"posting");
                // Perform the request created above and create a handler block to handle the response.
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError*error) {
                    NSLog(@"posted");
                    NSDictionary *responseResult=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
//                    NSLog(@"contactObjects %@", responseResult);
                    NSArray *ids=[responseResult objectForKey:@"ids"];
                    
                    for(int i=0; i<[ids count]/100; i++)
                    {
                        NSString *idstr=[[ids subarrayWithRange:NSMakeRange(i*100, (i+1)*100)] componentsJoinedByString:@","];
                        
                        TWRequest *getRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1.1/users/lookup.json"] parameters:[NSDictionary dictionaryWithObject:idstr forKey:@"user_id"] requestMethod:TWRequestMethodGET];
                        
                        // Set the account used to post the tweet.
                        [getRequest setAccount:twitterAccount];
                        
                        NSLog(@"posting");
                        // Perform the request created above and create a handler block to handle the response.
                        [getRequest performRequestWithHandler:^(NSData *responseData2, NSHTTPURLResponse *urlResponse2, NSError*error2) {
                            NSLog(@"posted");
                            NSArray *responseResult2=[NSJSONSerialization JSONObjectWithData:responseData2 options:0 error:nil];
//                            NSLog(@"contactObjects %@", responseResult2);
                            
                            for(int x=0; x<[responseResult2 count]; x++)
                            {
                                NSDictionary *user=[responseResult2 objectAtIndex:x];
                                NSNumber *userid=[user objectForKey:@"id"];
                                NSString *screenname=[user objectForKey:@"screen_name"];
                                NSString *name=[user objectForKey:@"name"];
                                NSLog(@"found user %@ : %@", userid, screenname);
                                NSMutableArray *userObject=[[NSMutableArray alloc] init];
                                [userObject addObject:userid];
                                [userObject addObject:screenname];
                                [userObject addObject:name];
                                [friends addObject:userObject];
                            }
                            
                            sortedFriends=[friends sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                NSArray *a1=(NSArray *)obj1;
                                NSArray *a2=(NSArray *)obj2;
                                
                                NSString *s1=[a1 objectAtIndex:2];
                                NSString *s2=[a2 objectAtIndex:2];
                                
                                return [s1 localizedCaseInsensitiveCompare:s2];
                            }];
                            [contactsTable reloadData];
                        }];
                    }
                }];
            }
        }
    }];
}

- (void)viewDidUnload
{
    [self setContactsTable:nil];
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
    if([segue.identifier isEqualToString:@"Contact Detail"])
    {
      NSLog(@"doing it");
      ContactDetailViewController *dest=(ContactDetailViewController *)segue.destinationViewController;
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
    return [friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Contact Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSLog(@"get cell");
    //    Contact *contact=[contacts objectAtIndex:[indexPath indexAtPosition:1]];
    NSArray *friend=[sortedFriends objectAtIndex:[indexPath indexAtPosition:1]];
    NSString *screenname=[friend objectAtIndex:1];
    NSString *name=[friend objectAtIndex:2];
    
    cell.textLabel.text=name;
    cell.detailTextLabel.text=[@"@" stringByAppendingString:screenname];
    
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
    NSLog(@"select cell");
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
     
     Contact *contact=[contacts objectAtIndex:[indexPath indexAtPosition:1]];
     detailView.contact=contact;
}

@end
