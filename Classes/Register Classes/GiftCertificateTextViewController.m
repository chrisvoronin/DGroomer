//
//  GiftCertificateTextViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GiftCertificate.h"
#import "GiftCertificateTextViewController.h"


@implementation GiftCertificateTextViewController

@synthesize certificate, editing, tvText;

- (void)viewDidLoad {
	// Background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	if( editing ) {
		// Done Button
		UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
		self.navigationItem.rightBarButtonItem = btnDone;
		[btnDone release];
		//
		tvText.editable = YES;
	} else {
		tvText.editable = NO;
	}
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( certificate ) {
		if( [self.title isEqualToString:@"Notes"] && certificate.notes ) {
			tvText.text = certificate.notes;
		} else if( [self.title isEqualToString:@"Message"] && certificate.message ) {
			tvText.text = certificate.message;
		}
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.tvText = nil;
	[certificate release];
    [super dealloc];
}

- (void) done {
	if( certificate ) {
		if( [self.title isEqualToString:@"Notes"] ) {
			certificate.notes = tvText.text;
		} else if( [self.title isEqualToString:@"Message"] ) {
			certificate.message = tvText.text;
		}
	}
	[self.navigationController popViewControllerAnimated:YES];
}

@end
