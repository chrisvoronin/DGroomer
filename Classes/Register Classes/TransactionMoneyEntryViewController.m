//
//  TransactionMoneyEntryViewController.m
//  myBusiness
//
//  Created by David J. Maier on 1/6/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import "TransactionMoneyEntryViewController.h"


@implementation TransactionMoneyEntryViewController

@synthesize delegate, lbBalance, value, txtAmount;

- (void)viewDidLoad {
	// Background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	UILabel *lbCurrency = [[UILabel alloc] initWithFrame:CGRectMake( 0, 2, 40, 55)];
	lbCurrency.font = txtAmount.font;
	lbCurrency.text = [currencyFormatter currencySymbol];
	[currencyFormatter release];
	txtAmount.leftView = lbCurrency;
	txtAmount.leftViewMode = UITextFieldViewModeAlways;
	[lbCurrency release];
	// Resize
	txtAmount.frame = CGRectMake( txtAmount.frame.origin.x, txtAmount.frame.origin.y, txtAmount.frame.size.width, 60);
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( value ) {
		txtAmount.text = value;
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.lbBalance = nil;
	self.txtAmount = nil;
	[value release];
    [super dealloc];
}


- (void) done {
	[self.delegate completedMoneyEntry:txtAmount.text title:self.title];
}


@end
