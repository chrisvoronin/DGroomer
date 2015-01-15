//
//  GiftCertificateExpirationViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GiftCertificate.h"
#import "GiftCertificateExpirationViewController.h"


@implementation GiftCertificateExpirationViewController

@synthesize certificate, datePicker;

- (void) viewDidLoad {
	self.title = @"EXPIRATION";
	// Background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	// Set the minimum date to today
	datePicker.minimumDate = [NSDate date];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	// Fixes the time zone issues in 4.0
	datePicker.calendar = [NSCalendar autoupdatingCurrentCalendar];
	//
	if( certificate ) {
		if( certificate.expiration ) {
			[datePicker setDate:certificate.expiration animated:NO];
		} else {
			NSDateComponents *comps = [[NSDateComponents alloc] init];
			[comps setYear:1];
			NSDate *exp = [[NSCalendar autoupdatingCurrentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
			[datePicker setDate:exp animated:NO];
			[comps release];
		}
	}
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[certificate release];
	self.datePicker = nil;
    [super dealloc];
}

- (void) done {
	if( certificate ) {
		certificate.expiration = datePicker.date;
	}
	[self.navigationController popViewControllerAnimated:YES];
}

@end
