//
//  InvitesViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class InviteDetailViewController;
@class Contact;

@interface InvitesViewController : UITableViewController
{
    InviteDetailViewController *detailView;
}

@property (weak, nonatomic) IBOutlet UITableView *invitesTable;
@property (strong, nonatomic) NSMutableArray *invites;

@end
