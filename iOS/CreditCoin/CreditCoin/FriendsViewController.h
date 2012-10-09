//
//  FriendsViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Coin;
@class TransactionsViewController;

@interface FriendsViewController : UITableViewController
{
    TransactionsViewController *detailView;
}

@property (copy, nonatomic) NSArray *friends;
@property (weak, nonatomic) IBOutlet UITableView *friendsTable;
@property (strong, nonatomic) Coin *coin;

@end
