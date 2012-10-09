//
//  ReceiptsViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Wallet;
@class ReceiptDetailViewController;

@interface ReceiptsViewController : UITableViewController
{
  Wallet *wallet;
  NSArray *receipts;
  ReceiptDetailViewController *detailView;
}

@property (weak, nonatomic) IBOutlet UITableView *receiptsTable;

@end
