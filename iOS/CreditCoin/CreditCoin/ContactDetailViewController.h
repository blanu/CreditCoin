//
//  ContactDetailViewController.h
//  CreditCoin
//
//  Created by Brandon Wiley on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;

@interface ContactDetailViewController : UIViewController

@property (strong, nonatomic) Contact *contact;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubkeyLabel;

@end
