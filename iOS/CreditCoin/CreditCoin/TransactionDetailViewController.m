//
//  TransactionDetailViewController.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TransactionDetailViewController.h"
#import "Transaction.h"

@interface TransactionDetailViewController ()

@end

@implementation TransactionDetailViewController

@synthesize transaction=_transaction;
@synthesize fromLabel = _fromLabel;
@synthesize toLabel = _toLabel;
@synthesize phaseLabel = _phaseLabel;

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
    [self setFromLabel:nil];
    [self setToLabel:nil];
    [self setPhaseLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setTransaction:(Transaction *)transaction
{
    NSLog(@"setTransaction");
    _transaction=transaction;
    
    self.fromLabel.text=transaction.senderName;
    self.toLabel.text=transaction.receiverName;
    self.phaseLabel.text=[transaction getState];
}

@end
