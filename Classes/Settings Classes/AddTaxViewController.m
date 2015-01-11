//
//  AddTaxViewController.m
//  PSA
//
//  Created by Michael Simone on 8/2/09.
//  Copyright 2009 Dropped Pin. All rights reserved.
//

#import "AddTaxViewController.h"


@implementation AddTaxViewController

@synthesize appDelegate, taxRate1, taxRate2;

- (IBAction)save:(id)sender {
	[self.view removeFromSuperview];
}

- (IBAction)back:(id)sender {
	[self.view removeFromSuperview];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PSA_SettingsOrange.png"]];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[taxRate1 release];
	[taxRate2 release];
	
    [super dealloc];
}


@end
