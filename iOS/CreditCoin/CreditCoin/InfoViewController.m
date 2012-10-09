//
//  InfoViewController.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"
#import "Wallet.h"
#import "SSCrypto.h"
#import <GameKit/GameKit.h>

@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize publicKeyLabel;
@synthesize privateKeyLabel;

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
  
  NSLog(@"viewDidLoad");
  wallet=[Wallet instance];
  self.privateKeyLabel.text=[[wallet getPrivateKey] encodeBase64];
  self.publicKeyLabel.text=[[wallet getPublicKey] encodeBase64];  
  NSLog(@"set keys %@, %@", [[wallet getPrivateKey] encodeBase64], [[wallet getPublicKey] encodeBase64]);  
}

- (void)viewDidUnload
{
  [self setPrivateKeyLabel:nil];
  [self setPublicKeyLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clearPressed:(id)sender
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error)
    {
        for(int i=0; i<[matches count]; i++)
        {
            GKTurnBasedMatch *match=[matches objectAtIndex:i];
            [match removeWithCompletionHandler:^(NSError *error)
            {
                if(error==nil)
                {
                    NSLog(@"removal successful");
                }
                else
                {
                    NSLog(@"removal failed");
                }
            }];
        }
    }];
}

@end
