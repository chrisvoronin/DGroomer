//
//  ProductPriceController.m
//  myBusiness
//
//  Created by David J. Maier on 7/20/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Product.h"
#import "PSADataManager.h"
#import "ProductPriceViewController.h"


@implementation ProductPriceViewController

@synthesize prodCost, prodPrice, product, tax;


- (void)viewDidLoad {
	self.title = @"Prices";
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
	prodCost.frame = CGRectMake( prodCost.frame.origin.x, prodCost.frame.origin.y, prodCost.frame.size.width, 50);
	prodPrice.frame = CGRectMake( prodPrice.frame.origin.x, prodPrice.frame.origin.y, prodPrice.frame.size.width, 50);
	//
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	UILabel *lbCurrency = [[UILabel alloc] initWithFrame:CGRectMake( 0, 2, 20, 45)];
	UILabel *lbCurrency2 = [[UILabel alloc] initWithFrame:CGRectMake( 0, 2, 20, 45)];
	lbCurrency.font = prodCost.font;
	lbCurrency.text = [currencyFormatter currencySymbol];
	lbCurrency2.font = prodCost.font;
	lbCurrency2.text = [currencyFormatter currencySymbol];
	[currencyFormatter release];
	prodCost.leftView = lbCurrency;
	prodCost.leftViewMode = UITextFieldViewModeAlways;
	prodPrice.leftView = lbCurrency2;
	prodPrice.leftViewMode = UITextFieldViewModeAlways;
	[lbCurrency release];
	[lbCurrency2 release];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( product ) {
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[formatter setCurrencySymbol:@""];
		prodCost.text = [formatter stringFromNumber:product.productCost];
		prodPrice.text = [formatter stringFromNumber:product.productPrice];
		[formatter release];
		tax.on = product.productTaxable;
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[prodCost release];
	[prodPrice release];
	[tax release];
	[product release];
    [super dealloc];
}


- (void) save {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	
	// The formatter was adding a space before the number in the text field,
	// On < iOS 4.0 it doesn't convert the number with the space.
	if( [prodCost.text hasPrefix:@" "] ) {
		product.productCost = [formatter numberFromString:[prodCost.text substringFromIndex:1]];
	} else {
		product.productCost = [formatter numberFromString:prodCost.text];
	}
	
	if( [prodPrice.text hasPrefix:@" "] ) {
		product.productPrice = [formatter numberFromString:[prodPrice.text substringFromIndex:1]];
	} else {
		product.productPrice = [formatter numberFromString:prodPrice.text];
	}

	[formatter release];
	product.productTaxable = [tax isOn];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
