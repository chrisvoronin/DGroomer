//
//  GenericClientDetailViewController.m
//  myBusiness
//
//  Created by David J. Maier on 10/21/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "PSAAppDelegate.h"
#import "GenericClientDetailViewController.h"


@implementation GenericClientDetailViewController

@synthesize bbiBack, client;

- (void) viewDidLoad {
	// Set the background color to a nice yellow image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGold.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
	self.client = nil;
	self.bbiBack = nil;
	[super viewDidUnload];
}

- (void) dealloc {
    [super dealloc];
}


- (IBAction) goBackToClients {
	[(PSAAppDelegate*)[[UIApplication sharedApplication] delegate] swapClientTabWithNavigation];
}

@end
