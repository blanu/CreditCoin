//
//  ContactDetailViewController.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "Contact.h"
#import "SSCrypto.h"

@interface ContactDetailViewController ()

@end

@implementation ContactDetailViewController

@synthesize contact=_contact;
@synthesize emailLabel = _emailLabel;
@synthesize pubkeyLabel = _pubkeyLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
  [self setEmailLabel:nil];
  [self setPubkeyLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setContact:(Contact *)c
{
  _contact=c;
  
  self.emailLabel.text=_contact.email;
  self.pubkeyLabel.text=[_contact.publicKey encodeBase64];
}

@end
