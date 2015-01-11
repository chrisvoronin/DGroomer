//
//  GiftCertificateRecipientViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GiftCertificate.h"
#import "GiftCertificateRecipientViewController.h"


@implementation GiftCertificateRecipientViewController

@synthesize certificate, txtFirst, txtLast;

- (void)viewDidLoad {
	self.title = @"Recipient";
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
	txtFirst.frame = CGRectMake( txtFirst.frame.origin.x, txtFirst.frame.origin.y, txtFirst.frame.size.width, 55);
	txtLast.frame = CGRectMake( txtLast.frame.origin.x, txtLast.frame.origin.y, txtLast.frame.size.width, 55);
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( certificate ) {
		if( certificate.recipientFirst ) {
			txtFirst.text = certificate.recipientFirst;
		}
		if( certificate.recipientLast ) {
			txtLast.text = certificate.recipientLast;
		}
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.txtFirst = nil;
	self.txtLast = nil;
	[certificate release];
    [super dealloc];
}

- (void) done {
	if( certificate ) {
		if( txtFirst.text.length > 0 ) {
			certificate.recipientFirst = txtFirst.text;
		} else {
			certificate.recipientFirst = nil;
		}
		if( txtLast.text.length > 0 ) {
			certificate.recipientLast = txtLast.text;
		} else {
			certificate.recipientLast = nil;
		}
	}
	[self.navigationController popViewControllerAnimated:YES];
}


@end
