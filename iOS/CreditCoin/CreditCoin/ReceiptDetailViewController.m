//
//  ReceiptDetailViewController.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReceiptDetailViewController.h"

@interface ReceiptDetailViewController ()

@end

@implementation ReceiptDetailViewController

@synthesize receipt=_receipt;
@synthesize commandLabel = _commandLabel;

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
  [self setCommandLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setReceipt:(Receipt *)r
{
  _receipt=r;
  
  self.commandLabel.text=_receipt.command;
}

@end
