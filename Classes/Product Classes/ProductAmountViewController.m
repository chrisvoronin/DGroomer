//
//  ProductAmountContoller.m
//  myBusiness
//
//  Created by David J. Maier on 7/20/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Product.h"
#import "PSADataManager.h"
#import "ProductAmountViewController.h"


@implementation ProductAmountViewController

@synthesize prodMin, prodMax, product;

- (void)viewDidLoad {
	self.title = @"Inventory";
	// Set the background color to a nice blue image
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundRed.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	//
	prodMax.frame = CGRectMake( prodMax.frame.origin.x, prodMax.frame.origin.y, prodMax.frame.size.width, 50);
	prodMin.frame = CGRectMake( prodMin.frame.origin.x, prodMin.frame.origin.y, prodMin.frame.size.width, 50);
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	NSString *num = [[NSString alloc] initWithFormat:@"%d", product.productMin];
	prodMin.text = num;
	[num release];
	num = [[NSString alloc] initWithFormat:@"%d", product.productMax];
	prodMax.text = num;
	[num release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[prodMin release];
	[prodMax release];
	[product release];
    [super dealloc];
}

- (void) save {
	product.productMax = [prodMax.text intValue];
	product.productMin = [prodMin.text intValue];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
