//
//  CoinDetailViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coin.h"

@interface CoinDetailViewController : UIViewController

@property (strong, nonatomic) Coin *coin;
@property (weak, nonatomic) IBOutlet UILabel *seedLabel;

@end
