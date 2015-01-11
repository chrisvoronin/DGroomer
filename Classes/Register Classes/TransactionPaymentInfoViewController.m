//
//  TransactionPaymentInfoViewController.m
//  myBusiness
//
//  Created by David J. Maier on 1/6/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "TransactionPayment.h"
#import "TransactionPaymentInfoViewController.h"


@implementation TransactionPaymentInfoViewController

@synthesize lbFieldName, lbInstructions, payment, txtInfo;

- (void)viewDidLoad {
	self.title = @"Extra Info.";
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
	txtInfo.frame = CGRectMake( txtInfo.frame.origin.x, txtInfo.frame.origin.y, txtInfo.frame.size.width, 60);
	// Change the labels
	switch (payment.paymentType) {
		case PSATransactionPaymentGiftCertificate:
			lbFieldName.text = @"Certificate Number";
			break;
		case PSATransactionPaymentCheck:
			lbFieldName.text = @"Check Number";
			break;
		case PSATransactionPaymentCoupon:
			lbFieldName.text = @"Coupon Info.";
			break;
		case PSATransactionPaymentCredit:
			lbFieldName.text = @"Last 4 Digits";
			break;
	}
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( payment.extraInfo ) {
		txtInfo.text = payment.extraInfo;
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.lbFieldName = nil;
	self.lbInstructions = nil;
	self.txtInfo = nil;
	[payment release];
    [super dealloc];
}

- (void) done {
	payment.extraInfo = txtInfo.text;
	[self.navigationController popViewControllerAnimated:YES];
}

@end
