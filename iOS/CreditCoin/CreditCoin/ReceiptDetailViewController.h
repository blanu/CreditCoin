//
//  ReceiptDetailViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Receipt.h"

@interface ReceiptDetailViewController : UIViewController

@property (strong, nonatomic) Receipt *receipt;
@property (weak, nonatomic) IBOutlet UILabel *commandLabel;

@end
