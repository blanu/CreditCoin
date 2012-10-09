//
//  TransactionsViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransactionDetailViewController;
@class Coin;

@interface TransactionsViewController : UITableViewController
{
    TransactionDetailViewController *detailView;
}

@property (weak, nonatomic) IBOutlet UITableView *transactionsTable;
@property (strong, nonatomic) NSMutableArray *transactions;

@end
