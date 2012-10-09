//
//  InviteDetailViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Invite;

@interface InviteDetailViewController : UIViewController

@property (strong, nonatomic) Invite *invite;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *phaseLabel;

@end