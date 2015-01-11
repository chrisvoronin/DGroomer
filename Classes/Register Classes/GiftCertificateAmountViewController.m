//
//  GiftCertificateAmountViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GiftCertificate.h"
#import "GiftCertificateAmountViewController.h"


@implementation GiftCertificateAmountViewController

@synthesize certificate, txtAmount;

- (void)viewDidLoad {
	self.title = @"Amount";
	// Background
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	// Resize
	txtAmount.frame = CGRectMake( txtAmount.frame.origin.x, txtAmount.frame.origin.y, txtAmount.frame.size.width, 60);
	//
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	UILabel *lbCurrency = [[UILabel alloc] initWithFrame:CGRectMake( 0, 2, 20, 55)];
	lbCurrency.font = txtAmount.font;
	lbCurrency.text = [currencyFormatter currencySymbol];
	[currencyFormatter release];
	txtAmount.leftView = lbCurrency;
	txtAmount.leftViewMode = UITextFieldViewModeAlways;
	[lbCurrency release];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( certificate && certificate.amountPurchased ) {
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[formatter setCurrencySymbol:@""];
		txtAmount.text = [formatter stringFromNumber:certificate.amountPurchased];
		[formatter release];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.txtAmount = nil;
	[certificate release];
    [super dealloc];
}


- (void) done {
	if( certificate ) {
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		if( [txtAmount.text hasPrefix:@" "] ) {
			certificate.amountPurchased = [formatter numberFromString:[txtAmount.text substringFromIndex:1]];
		} else {
			certificate.amountPurchased = [formatter numberFromString:txtAmount.text];
		}
		[formatter release];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

@end
