//
//  ServiceCostController.m
//  myBusiness
//
//  Created by David J. Maier on 7/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Service.h"
#import "ServiceCostViewController.h"


@implementation ServiceCostViewController

@synthesize txtFee, txtCost, txtPrice, segFlatOrHourly, swTaxable, service;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"SERVICE COSTS";
	// Set the background color to a nice blue image
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundPurple.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
	txtCost.frame = CGRectMake( txtCost.frame.origin.x, txtCost.frame.origin.y, txtCost.frame.size.width, 40);
	txtFee.frame = CGRectMake( txtFee.frame.origin.x, txtFee.frame.origin.y, txtFee.frame.size.width, 40);
	txtPrice.frame = CGRectMake( txtPrice.frame.origin.x, txtPrice.frame.origin.y, txtPrice.frame.size.width, 40);
	//
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	UILabel *lbCurrency = [[UILabel alloc] initWithFrame:CGRectMake( 0, 2, 20, 35)];
	UILabel *lbCurrency2 = [[UILabel alloc] initWithFrame:CGRectMake( 0, 2, 20, 35)];
	UILabel *lbCurrency3 = [[UILabel alloc] initWithFrame:CGRectMake( 0, 2, 20, 35)];
	lbCurrency.font = txtCost.font;
	lbCurrency.text = [currencyFormatter currencySymbol];
	lbCurrency2.font = txtCost.font;
	lbCurrency2.text = [currencyFormatter currencySymbol];
	lbCurrency3.font = txtCost.font;
	lbCurrency3.text = [currencyFormatter currencySymbol];
	[currencyFormatter release];
	txtCost.leftView = lbCurrency;
	txtCost.leftViewMode = UITextFieldViewModeAlways;
	txtFee.leftView = lbCurrency2;
	txtFee.leftViewMode = UITextFieldViewModeAlways;
	txtPrice.leftView = lbCurrency3;
	txtPrice.leftViewMode = UITextFieldViewModeAlways;
	[lbCurrency release];
	[lbCurrency2 release];
	[lbCurrency3 release];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( service ) {
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[formatter setCurrencySymbol:@""];
		txtCost.text = [formatter stringFromNumber:service.serviceCost];
		txtFee.text = [formatter stringFromNumber:service.serviceSetupFee];
		txtPrice.text = [formatter stringFromNumber:service.servicePrice];
		[formatter release];
		if( service.serviceIsFlatRate ) {
			[segFlatOrHourly setSelectedSegmentIndex:0];
		} else {
			[segFlatOrHourly setSelectedSegmentIndex:1];
		}
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.txtCost = nil;
	self.txtFee = nil;
	self.txtPrice = nil;
	self.swTaxable = nil;
	self.segFlatOrHourly = nil;
	[service release];
    [super dealloc];
}


- (void) save {
	
	NSNumberFormatter *formatter2 = [[NSNumberFormatter alloc] init];
	
	// The formatter was adding a space before the number in the text field,
	// On < iOS 4.0 it doesn't convert the number with the space.
	if( [txtFee.text hasPrefix:@" "] ) {
		service.serviceSetupFee = [formatter2 numberFromString:[txtFee.text substringFromIndex:1]];
	} else {
		service.serviceSetupFee = [formatter2 numberFromString:txtFee.text];
	}
	
	if( [txtPrice.text hasPrefix:@" "] ) {
		service.servicePrice = [formatter2 numberFromString:[txtPrice.text substringFromIndex:1]];
	} else {
		service.servicePrice = [formatter2 numberFromString:txtPrice.text];
	}
	
	if( [txtCost.text hasPrefix:@" "] ) {
		service.serviceCost = [formatter2 numberFromString:[txtCost.text substringFromIndex:1]];
	} else {
		service.serviceCost = [formatter2 numberFromString:txtCost.text];
	}
	
	[formatter2 release];
	
	service.serviceIsFlatRate = (segFlatOrHourly.selectedSegmentIndex == 0) ? YES : NO;
	service.taxable = swTaxable.on;
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
