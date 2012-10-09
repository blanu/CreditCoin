//
//  ContactsViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@class Wallet;
@class Contact;
@class ContactDetailViewController;

@interface ContactsViewController : UITableViewController
{
  Wallet *wallet;
  NSArray *contacts;
  NSMutableArray *friends;
  NSArray *sortedFriends;
  ContactDetailViewController *detailView;
}

@property (weak, nonatomic) IBOutlet UITableView *contactsTable;

@end
