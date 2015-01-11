//
//  ProductNameController.m
//  myBusiness
//
//  Created by David J. Maier on 7/20/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Product.h"
#import "PSADataManager.h"
#import "ProductNameViewController.h"


@implementation ProductNameViewController

@synthesize prodNum, prodName, product, swActive;

- (void)viewDidLoad {
	self.title = @"Name";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundRed.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
	// Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	//
	prodNum.frame = CGRectMake( prodNum.frame.origin.x, prodNum.frame.origin.y, prodNum.frame.size.width, 50);
	prodName.frame = CGRectMake( prodName.frame.origin.x, prodName.frame.origin.y, prodName.frame.size.width, 50);
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( product ) {
		if( product.productNumber ) {
			prodNum.text = product.productNumber;
		}
		swActive.on = product.isActive;
		prodName.text = product.productName;
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.swActive = nil;
	self.prodNum = nil;
	self.prodName = nil;
	[product release];
    [super dealloc];
}

- (void) save {
	product.productName = prodName.text;
	product.isActive = swActive.on;
	product.productNumber = prodNum.text;
	[self.navigationController popViewControllerAnimated:YES];
}

@end
