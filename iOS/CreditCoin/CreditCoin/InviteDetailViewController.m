//
//  InviteDetailViewController.m
//  CreditCoin
//
//  Created by Brandon Wiley on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InviteDetailViewController.h"
#import "Invite.h"

@interface InviteDetailViewController ()

@end

@implementation InviteDetailViewController

@synthesize invite=_invite;
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

- (void)setInvite:(Invite *)invite
{
    NSLog(@"setInvite");
    _invite=invite;
    
    self.fromLabel.text=invite.sender.email;
    self.toLabel.text=invite.receiver.email;
    self.phaseLabel.text=[invite getState];
}

@end
