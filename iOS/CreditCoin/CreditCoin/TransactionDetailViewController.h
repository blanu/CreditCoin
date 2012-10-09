//
//  TransactionDetailViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Transaction;

@interface TransactionDetailViewController : UIViewController

@property (strong, nonatomic) Transaction *transaction;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *phaseLabel;

@end
