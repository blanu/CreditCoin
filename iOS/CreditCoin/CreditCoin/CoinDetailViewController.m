//
//  CoinDetailViewController.m
//  CreditCoin
//
//  Created by Brandon Wiley on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoinDetailViewController.h"
#import "FriendsViewController.h"
#import "Coin.h"
#import "Transaction.h"
#import "SSCrypto.h"

@interface CoinDetailViewController ()

@end

@implementation CoinDetailViewController

@synthesize coin=_coin;
@synthesize seedLabel = _seedLabel;

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
  [self setSeedLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setCoin:(Coin *)c
{
  NSLog(@"setCoin");
  _coin=c;
  
  NSLog(@"setting %@, %@, %@", _coin, [_coin getSeed], [[_coin getSeed] encodeBase64]);
  self.seedLabel.text=[[_coin getSeed] encodeBase64];
}

- (IBAction)sendPressed:(id)sender
{
  NSLog(@"send");
}

- (IBAction)destroyPressed:(id)sender
{
  NSLog(@"destroy");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{  
    NSLog(@"prepare for segue");
    if([segue.identifier isEqualToString:@"Send Coin"])
    {
        NSLog(@"doing it");
        FriendsViewController *dest=(FriendsViewController *)segue.destinationViewController;
        dest.coin=self.coin;
    }
}

@end
