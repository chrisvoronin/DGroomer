//
//  ProjectDateEntryViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/21/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Project.h"
#import "ProjectInvoice.h"
#import "ProjectDateEntryViewController.h"


@implementation ProjectDateEntryViewController

@synthesize lbDescription, invoice, project, datePicker;


- (void)viewDidLoad {
	if( project ) {
		self.title = @"Due Date";
	} else {
		if( invoice.type == iBizProjectEstimate ) {
			self.title = @"Accept By";
			lbDescription.text = @"Select the date the client should accept the estimate by.";
		} else {
			self.title = @"Payment Due";
			lbDescription.text = @"Select when the payment for this invoice is due.";
		}
	}
    // Set the view background to match the grouped tables in the other views.
    UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	// Fixes the time zone issues in 4.0
	datePicker.calendar = [NSCalendar autoupdatingCurrentCalendar];
	//
	if( project.dateDue ) {
		[datePicker setDate:project.dateDue animated:NO];
	} else {
		NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
		[comps setSecond:0];
		[comps setHour:0];
		[comps setMinute:0];
		[datePicker setDate:[[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps] animated:NO];
	}
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.datePicker = nil;
	self.lbDescription = nil;
	[invoice release];
	[project release];
    [super dealloc];
}


- (void) done {
	if( project ) {
		project.dateDue = datePicker.date;
	} else if( invoice ) {
		invoice.dateDue = datePicker.date;
	}
	[self.navigationController popViewControllerAnimated:YES];
}


@end
