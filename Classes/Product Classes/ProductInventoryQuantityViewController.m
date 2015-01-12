//
//  ProductInventoryQuantityViewController.m
//  myBusiness
//
//  Created by David J. Maier on 1/12/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductAdjustment.h"
#import "ProductInventoryQuantityViewController.h"


@implementation ProductInventoryQuantityViewController

@synthesize adjustment, txtQuantity;

- (void)viewDidLoad {
	self.title = @"Quantity";
	//
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundRed.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Done Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	//
	txtQuantity.frame = CGRectMake( txtQuantity.frame.origin.x, txtQuantity.frame.origin.y, txtQuantity.frame.size.width, 60);
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( adjustment && adjustment.quantity > 0 ) {
		NSString *str = [[NSString alloc] initWithFormat:@"%d", adjustment.quantity];
		txtQuantity.text = str;
		[str release];
	} else {
		txtQuantity.text = @"1";
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[adjustment release];
	self.txtQuantity = nil;
    [super dealloc];
}

- (void) done {
	adjustment.quantity = [txtQuantity.text integerValue];
	if( adjustment.quantity > 0 ) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Quantity" message:@"Please enter a quantity greater than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if( textField.text.length <= 5 ) {
		return YES;
	}
	return NO;
}

@end
