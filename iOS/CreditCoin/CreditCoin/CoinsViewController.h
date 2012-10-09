//
//  CoinsViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Wallet;
@class Coin;
@class CoinDetailViewController;

@interface CoinsViewController : UITableViewController
{
  Wallet *wallet;
  NSArray *coins;
  CoinDetailViewController *detailView;
}

@property (weak, nonatomic) IBOutlet UITableView *coinsTable;

@end
