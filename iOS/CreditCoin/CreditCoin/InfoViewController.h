//
//  InfoViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Wallet;

@interface InfoViewController : UIViewController
{
  Wallet *wallet;
}

@property (weak, nonatomic) IBOutlet UILabel *publicKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *privateKeyLabel;

@end
