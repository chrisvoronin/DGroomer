//
//  AddRatesController.m
//  myBusiness
//
//  Created by David J. Maier on 8/2/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "Company.h"
#import "PSADataManager.h"
#import "Settings.h"
#import "Tax.h"
#import "CommissionTaxViewController.h"

@implementation CommissionTaxViewController

@synthesize saleTaxPercent;


- (void)viewDidLoad {
	// Nav Bar Title
	self.title = @"SALES TAX";
	// Set the background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundOrange.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Add Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	// Get the company
	company = [[PSADataManager sharedInstance] getCompany];
	//
	//commissionRate.frame = CGRectMake( commissionRate.frame.origin.x, commissionRate.frame.origin.y, commissionRate.frame.size.width, 50);
	saleTaxPercent.frame = CGRectMake( saleTaxPercent.frame.origin.x, saleTaxPercent.frame.origin.y, saleTaxPercent.frame.size.width, 50);
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( company != nil ) {
		// Set values
		if( company.salesTax ) {
			NSString *tax = [[NSString alloc] initWithFormat:@"%.2f", [company.salesTax doubleValue]];
			saleTaxPercent.text = tax;
			[tax release];
		}
		/*if( company.commissionRate ) {
			NSString *comm = [[NSString alloc] initWithFormat:@"%.2f", [company.commissionRate doubleValue]];
			commissionRate.text = comm;
			[comm release];
		}*/
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	//self.commissionRate = nil;
	self.saleTaxPercent = nil;
	[company release];
    [super dealloc];
}


- (void) save {
	//NSNumber *commission = [[NSNumber alloc] initWithDouble:[commissionRate.text doubleValue]];
	NSNumber *tax = [[NSNumber alloc] initWithDouble:[saleTaxPercent.text doubleValue]];
	//company.commissionRate = commission;
	company.salesTax = tax;
	//[commission release];
	[tax release];
	// Save object to DB
	[[PSADataManager sharedInstance] updateCompany:company];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
